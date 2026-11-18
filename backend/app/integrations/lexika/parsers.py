"""Parsers for the APHC "Lexika" chatbot (``https://aphc.gov.in/chatbot.php``).

Lexika is the AP High Court website's own chatbot. It answers POSTs with HTML
fragments. Formats below were captured in a controlled run on 2026-11-18.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from datetime import date, datetime

from lxml import html as lxml_html

from app.integrations.http import UpstreamNotFound, UpstreamParseError
from app.utils.case_identity import CaseIdentity, InvalidCaseIdentity, ListedMatter, parse_listed_matter

PARSER_VERSION = "1.0"


def _frag(body: str):
    body = body.strip()
    if not body:
        raise UpstreamParseError("empty Lexika response")
    return lxml_html.fragment_fromstring(body, create_parent="div")


def _clean(s: str | None) -> str:
    return " ".join((s or "").split())


# ------------------------------------------------------------ case types
def parse_case_type_options(body: str) -> dict[str, str]:
    """Op 1 ("Case Status"): ``<select id="case_type"><option value="WP-63">WP</option>...``

    Returns {display type -> submit value}, e.g. {"WP": "WP-63"}.
    """
    root = _frag(body)
    options = root.xpath("//select[@id='case_type']/option[@value!='']")
    mapping = {}
    for opt in options:
        label = _clean(opt.text_content())
        value = (opt.get("value") or "").strip()
        if label and value:
            mapping[label.upper()] = value
    if not mapping:
        raise UpstreamParseError("case type list not found in Lexika response")
    return mapping


# ------------------------------------------------------------ selection
def parse_case_selection(body: str) -> tuple[CaseIdentity, list[str]]:
    """Op 2: ``<li id="case_status_menu"><p><span>WP</span> 11111/2026</p> ...menu items``"""
    root = _frag(body)
    menu = root.xpath("//li[@id='case_status_menu']")
    if not menu:
        text = _clean(root.text_content())
        if re.search(r"(no|not)\s+(record|case|data|details)\s*(found)?", text, re.IGNORECASE):
            raise UpstreamNotFound("case not found in Lexika")
        raise UpstreamParseError("case selection menu not found")
    p = menu[0].xpath(".//p")
    if not p:
        raise UpstreamNotFound("case header missing - case probably not found")
    try:
        identity = CaseIdentity.parse_spaced(_clean(p[0].text_content()))
    except InvalidCaseIdentity as e:
        raise UpstreamParseError("could not read case identity from selection") from e
    options = [_clean(d.text_content()) for d in menu[0].xpath("./div")]
    return identity, [o for o in options if o and "Back to" not in o]


# ------------------------------------------------------------ primary
_DATE_DMY = re.compile(r"^\d{2}/\d{2}/\d{4}$")


def parse_dmy(value: str | None) -> date | None:
    v = _clean(value)
    if not v or not _DATE_DMY.match(v):
        return None
    d = datetime.strptime(v, "%d/%m/%Y").date()
    # Sentinel values used by APHC for "no date".
    if d.year in (1900, 5000):
        return None
    return d


def parse_primary_details(body: str) -> dict[str, dict[str, str]]:
    """Op 3: section titles followed by ``<div><span>Label</span><b>Value</b></div>`` pairs.

    Returns {section_title: {label: value}} preserving the source's own labels.
    """
    root = _frag(body)
    menu = root.xpath("//li[@id='case_status_menu']")
    if not menu:
        raise UpstreamParseError("primary details block not found")
    sections: dict[str, dict[str, str]] = {}
    current = None
    for el in menu[0].iter("div"):
        spans = el.findall("span")
        bolds = el.findall("b")
        children = [c for c in el if isinstance(c.tag, str)]
        if spans and bolds and len(children) <= 3:
            label = _clean(spans[0].text_content())
            value = _clean(bolds[0].text_content())
            if label:
                sections.setdefault(current or "PRIMARY DETAILS", {})[label] = value
        elif not children:
            title = _clean(el.text_content())
            if title and title.isupper() and "BACK TO" not in title:
                current = title
    if not sections:
        raise UpstreamParseError("no label/value pairs in primary details")
    return sections


# ------------------------------------------------------------ vakalath
@dataclass
class VakalathEntry:
    side: str
    party_no: str
    advocate_name: str
    advocate_code: str | None


_ADV_WITH_CODE = re.compile(r"^(.*?)\s*\((\d{1,8})\)\s*$")


def parse_vakalath(body: str) -> list[VakalathEntry]:
    """Op 4: repeating blocks of ``P/R No.`` (number + P/R) and ``Advocate Name`` ("NAME (code)")."""
    root = _frag(body)
    menu = root.xpath("//li[@id='case_status_menu']")
    if not menu:
        raise UpstreamParseError("vakalath block not found")
    out: list[VakalathEntry] = []
    pending: tuple[str, str] | None = None
    for el in menu[0].iter("div"):
        children = [c for c in el if isinstance(c.tag, str)]
        if (
            len(children) == 2
            and children[0].tag == "div"
            and _clean(children[0].text_content()).upper().startswith("P/R NO")
        ):
            vals = [_clean(x.text_content()) for x in children[1] if isinstance(x.tag, str)]
            if len(vals) >= 2 and vals[1].upper() in ("P", "R"):
                pending = (vals[1].upper(), vals[0])
            continue
        spans, bolds = el.findall("span"), el.findall("b")
        if spans and bolds and _clean(spans[0].text_content()).lower() == "advocate name":
            raw = _clean(bolds[0].text_content())
            if not raw:
                continue
            m = _ADV_WITH_CODE.match(raw)
            name, code = (m.group(1).strip(), m.group(2)) if m else (raw, None)
            side, no = pending if pending else ("?", "")
            out.append(VakalathEntry(side=side, party_no=no, advocate_name=name, advocate_code=code))
            pending = None
    return out


# ------------------------------------------------------------ parties
@dataclass
class PartyEntry:
    party_no: int
    name: str
    description: str | None


def parse_parties(body: str, expected_title: str) -> list[PartyEntry]:
    """Ops 5/6: ``PETITIONER(S)`` / ``RESPONDENT(S)`` with numbered name/description blocks."""
    root = _frag(body)
    menu = root.xpath("//li[@id='case_status_menu']")
    if not menu:
        raise UpstreamParseError(f"{expected_title} block not found")
    text = _clean(menu[0].text_content()).upper()
    if expected_title.upper() not in text:
        raise UpstreamParseError(f"{expected_title} heading missing")
    out: list[PartyEntry] = []
    for el in menu[0].iter("div"):
        children = [c for c in el if isinstance(c.tag, str)]
        if len(children) == 2 and children[0].tag == "div" and children[1].tag == "div":
            num = _clean(children[0].text_content())
            if not num.isdigit():
                continue
            b = children[1].find("b")
            p = children[1].find("p")
            name = _clean(b.text_content()) if b is not None else ""
            if not name:
                continue
            desc = _clean(p.text_content()) if p is not None else None
            out.append(PartyEntry(party_no=int(num), name=name, description=desc or None))
    return out


# ------------------------------------------------------------ advocate search
@dataclass
class AdvocateLookup:
    advocate_code: str
    name: str
    available_dates: list[date] = field(default_factory=list)


# Observed text: "I searched everywhere, but couldn not find any advocate linked to that code."
_NOT_FOUND_RE = re.compile(r"find\s+any\s+advocate\s+linked", re.IGNORECASE)


def parse_advocate_lookup(body: str, requested_code: str) -> AdvocateLookup:
    """``chat_input={code}``: ``<li>12345 - ADVOCATE ONE</li> ... Cause List Dated : dd-mm-yyyy``"""
    if _NOT_FOUND_RE.search(body):
        raise UpstreamNotFound("advocate code not found")
    root = _frag(body)
    name = None
    for li in root.xpath("//li"):
        t = _clean(li.text_content())
        m = re.match(rf"^{re.escape(requested_code)}\s*-\s*(.+)$", t)
        if m:
            name = m.group(1).strip()
            break
    if not name:
        raise UpstreamParseError("advocate name line not found")
    dates = []
    for d in root.xpath("//li[@id='adv_date_menu']//div"):
        m = re.search(r"Cause List Dated\s*:\s*(\d{2}-\d{2}-\d{4})", _clean(d.text_content()))
        if m:
            dates.append(datetime.strptime(m.group(1), "%d-%m-%Y").date())
    return AdvocateLookup(advocate_code=requested_code, name=name, available_dates=dates)


@dataclass
class AdvocateListing:
    item_no: str
    court_no: str
    list_type: str
    raw_case: str
    matter: ListedMatter | None


_COURT_RE = re.compile(r"^CH\s*-\s*(\d+)$", re.IGNORECASE)


def parse_advocate_cause_list(body: str) -> list[AdvocateListing]:
    """``query={date}``: table with Item No. / Case No. / Court No. / List Type."""
    root = _frag(body)
    tables = root.xpath("//table")
    if not tables:
        text = _clean(root.text_content()).lower()
        if "no" in text and ("case" in text or "list" in text):
            return []
        raise UpstreamParseError("advocate cause list table not found")
    headers = [_clean(th.text_content()).lower() for th in tables[0].xpath(".//th")]
    expected = ["item no.", "case no.", "court no.", "list type"]
    if headers[:4] != expected:
        raise UpstreamParseError(f"advocate cause list headers changed: {headers}")
    out = []
    for tr in tables[0].xpath(".//tr[td]"):
        tds = [_clean(td.text_content()) for td in tr.findall("td")]
        if len(tds) < 4:
            continue
        m = _COURT_RE.match(tds[2])
        court = m.group(1) if m else tds[2]
        try:
            matter = parse_listed_matter(tds[1])
        except InvalidCaseIdentity:
            matter = None
        out.append(AdvocateListing(item_no=tds[0], court_no=court, list_type=tds[3], raw_case=tds[1], matter=matter))
    return out
