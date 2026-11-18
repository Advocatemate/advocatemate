"""Parsers for APHC Hcdbs cause-list resources.

Every format handled here was observed on aphc.gov.in on 2026-11-18 (see
docs/APHC_INTEGRATION.md). Parsers are strict about structure and raise
UpstreamParseError when the expected anchors are missing, so a layout change
surfaces as a parser failure instead of silently producing empty data.
"""

from __future__ import annotations

import base64
import hashlib
import json
import re
from dataclasses import asdict, dataclass, field
from datetime import date, datetime

from lxml import html as lxml_html

from app.integrations.http import UpstreamNotFound, UpstreamParseError

PARSER_VERSION = "1.0"

_DATE_RE = re.compile(r"^\d{2}-\d{2}-\d{4}$")

# getdates.jsp / courtlist.jsp return these numeric codes on error (from the page JS).
_DATES_ERRORS = {"0": "no lists found", "1": "invalid request", "2": "invalid list type"}
_COURTLIST_ERRORS = {
    "0": "only POST allowed",
    "1": "list type required",
    "2": "list date required",
    "3": "list date length must be 10",
    "4": "list type invalid",
    "5": "list date invalid",
    "6": "list type invalid",
}


def parse_ddmmyyyy(value: str) -> date:
    return datetime.strptime(value.strip(), "%d-%m-%Y").date()


def format_ddmmyyyy(value: date) -> str:
    return value.strftime("%d-%m-%Y")


# --------------------------------------------------------------------- dates
def parse_list_dates(body: str) -> list[date]:
    """``getdates.jsp?listtype=X`` -> ``18-11-2026@17-11-2026@...``"""
    text = body.strip()
    if text in _DATES_ERRORS:
        if text == "0":
            return []
        raise UpstreamParseError(f"getdates error: {_DATES_ERRORS[text]}")
    parts = [p.strip() for p in text.split("@") if p.strip()]
    if not parts or not all(_DATE_RE.match(p) for p in parts):
        raise UpstreamParseError("unexpected getdates payload")
    return [parse_ddmmyyyy(p) for p in parts]


# -------------------------------------------------------------------- courts
@dataclass
class CourtOption:
    court_no: str
    court_name: str


def parse_court_list(body: str) -> list[CourtOption]:
    """``courtlist.jsp`` returns base64-encoded JSON ``[{court_code, court_name}]``."""
    text = body.strip()
    if text in _COURTLIST_ERRORS:
        raise UpstreamParseError(f"courtlist error: {_COURTLIST_ERRORS[text]}")
    try:
        data = json.loads(base64.b64decode(text, validate=True))
    except Exception as e:  # noqa: BLE001
        raise UpstreamParseError("courtlist payload is not base64 JSON") from e
    if not isinstance(data, list):
        raise UpstreamParseError("courtlist payload is not a list")
    out = []
    for row in data:
        code = str(row.get("court_code", "")).strip()
        if not code.isdigit():
            continue
        out.append(CourtOption(court_no=code, court_name=str(row.get("court_name", "")).strip()))
    return out


# ---------------------------------------------------------- court cause list
@dataclass
class Application:
    number: str
    description: str | None


@dataclass
class ParsedItem:
    sequence: int
    item_no: str
    case_display: str
    applications: list[Application]
    petitioner: str | None
    respondent: str | None
    petitioner_advocates: list[str]
    respondent_advocates: list[str]
    district: str | None
    list_section: str | None
    stage: str | None
    remarks: str | None = None


@dataclass
class ParsedCauseList:
    court_label: str | None
    bench: str | None
    headings: list[str] = field(default_factory=list)
    items: list[ParsedItem] = field(default_factory=list)

    def content_hash(self) -> str:
        blob = json.dumps([asdict(i) for i in self.items], sort_keys=True, default=str)
        return hashlib.sha256(blob.encode()).hexdigest()


def _lines(el) -> list[str]:
    return [" ".join(t.split()) for t in el.itertext() if t and t.strip()]


_COLUMN_HEADER = ("S.No", "Case")
_GROUP_NOTE_RE = re.compile(r"along with", re.IGNORECASE)


def parse_court_cause_list(page: str | bytes) -> ParsedCauseList:
    doc = lxml_html.fromstring(page)
    tables = doc.xpath("//table[@id='clisttable']")
    if not tables:
        if b"clisttable" not in (page if isinstance(page, bytes) else page.encode()):
            raise UpstreamParseError("cause-list table not found")
    table = tables[0]
    result = ParsedCauseList(court_label=None, bench=None)
    in_items = False
    list_section: str | None = None
    stage: str | None = None
    seq = 0
    last_item: ParsedItem | None = None

    for tr in table.iter("tr"):
        ths = tr.findall("th")
        tds = tr.findall("td")
        if ths and not tds:
            texts = [" ".join(th.text_content().split()) for th in ths]
            if len(ths) >= 5 and texts[0] == _COLUMN_HEADER[0]:
                in_items = True
                stage = None
                continue
            text = texts[0] if texts else ""
            if not text:
                continue
            if text.upper().startswith("COURT NO"):
                in_items = False
                result.court_label = result.court_label or text
                continue
            if not in_items:
                if text.upper().startswith(("THE HONOURABLE", "HON'BLE", "THE HON'BLE")) and not result.bench:
                    result.bench = text
                elif text.upper().startswith(("THE HONOURABLE", "HON'BLE", "THE HON'BLE")):
                    pass
                elif text.startswith("(") and text.endswith(")"):
                    list_section = text.strip("()").strip()
                    if text not in result.headings:
                        result.headings.append(text)
                else:
                    if text not in result.headings:
                        result.headings.append(text)
                continue
            if _GROUP_NOTE_RE.search(text):
                if last_item is not None:
                    last_item.remarks = f"{last_item.remarks}; {text}" if last_item.remarks else text
                continue
            stage = text
            continue

        if len(tds) < 5:
            continue
        cells = {td.get("data-label", f"col{i}"): td for i, td in enumerate(tds)}
        sno_td = cells.get("S.No", tds[0])
        item_no = " ".join(sno_td.text_content().split())
        if not item_no:
            continue
        case_td = cells.get("Case Det", tds[1])
        anchors = case_td.xpath(".//a")
        if anchors:
            case_display = " ".join(anchors[0].text_content().split())
        else:
            first = _lines(case_td)
            case_display = first[0] if first else ""
        rest = _lines(case_td)
        if rest and rest[0] == case_display:
            rest = rest[1:]
        apps: list[Application] = []
        i = 0
        while i < len(rest):
            number = rest[i]
            desc = None
            if i + 1 < len(rest) and not re.match(r"^[A-Z]{1,10}\s*\d", rest[i + 1]):
                desc = rest[i + 1]
                i += 1
            apps.append(Application(number=number, description=desc))
            i += 1

        party_lines = _lines(cells.get("Party", tds[2]))
        petitioner = respondent = None
        if party_lines:
            if "Vs" in party_lines:
                k = party_lines.index("Vs")
                petitioner = " ".join(party_lines[:k]) or None
                respondent = " ".join(party_lines[k + 1 :]) or None
            else:
                petitioner = " ".join(party_lines)

        pet_adv = _lines(cells.get("Pet Adv", tds[3]))
        res_adv = _lines(cells.get("Res Adv", tds[4]))
        district_td = next((td for k, td in cells.items() if str(k).startswith("District")), None)
        if district_td is None and len(tds) > 5:
            district_td = tds[5]
        district = " ".join(district_td.text_content().split()) if district_td is not None else None

        seq += 1
        last_item = ParsedItem(
            sequence=seq,
            item_no=item_no,
            case_display=case_display,
            applications=apps,
            petitioner=petitioner,
            respondent=respondent,
            petitioner_advocates=pet_adv,
            respondent_advocates=res_adv,
            district=district or None,
            list_section=list_section,
            stage=stage,
        )
        result.items.append(last_item)

    if result.court_label is None and not result.items:
        raise UpstreamParseError("cause-list page had no court header and no items")
    return result


# --------------------------------------------------------- publication board
@dataclass
class PublicationRow:
    court_no: str
    bench_code: str | None
    coram: str | None
    status: str
    uploaded_at_text: str | None
    pdf_path: str | None


@dataclass
class PublicationBoard:
    list_date: date
    rows: list[PublicationRow]


def parse_online_board(page: str | bytes) -> PublicationBoard:
    """``online_board.jsp``. Meeting IDs / pass-codes / VC links are intentionally dropped."""
    doc = lxml_html.fromstring(page)
    text = " ".join(doc.text_content().split())
    m = re.search(r"CAUSE LIST DATE\s*:\s*(\d{2}-\d{2}-\d{4})", text, re.IGNORECASE)
    if not m:
        raise UpstreamParseError("cause list date not found on online board")
    table = doc.xpath("//table[@id='display']")
    if not table:
        raise UpstreamParseError("online board table not found")
    headers = [" ".join(th.text_content().split()).lower() for th in table[0].xpath(".//thead//th")]

    def col(name: str) -> int | None:
        for i, h in enumerate(headers):
            if name in h:
                return i
        return None

    i_court, i_bench, i_coram = col("court hall"), col("bench"), col("coram")
    i_status, i_uploaded, i_pdf = col("status"), col("uploaded"), col("pdf")
    if i_court is None or i_status is None:
        raise UpstreamParseError("online board headers changed")
    rows: list[PublicationRow] = []
    for tr in table[0].xpath(".//tr[td]"):
        tds = tr.findall("td")
        if len(tds) <= max(i for i in (i_court, i_status) if i is not None):
            continue

        def cell(i, tds=tds):
            return " ".join(tds[i].text_content().split()) if i is not None and i < len(tds) else None

        court_no = cell(i_court)
        if not court_no or not court_no.isdigit():
            continue
        pdf_path = None
        if i_pdf is not None and i_pdf < len(tds):
            hrefs = tds[i_pdf].xpath(".//a/@href")
            if hrefs and hrefs[0].lower().endswith(".pdf") and hrefs[0].startswith("/Hcdbs/upload/"):
                pdf_path = hrefs[0]
        rows.append(
            PublicationRow(
                court_no=court_no,
                bench_code=cell(i_bench) or None,
                coram=cell(i_coram) or None,
                status=(cell(i_status) or "").upper(),
                uploaded_at_text=cell(i_uploaded) or None,
                pdf_path=pdf_path,
            )
        )
    return PublicationBoard(list_date=parse_ddmmyyyy(m.group(1)), rows=rows)


# ------------------------------------------------------------- display board
@dataclass
class DisplayBoardRow:
    court_no: str
    state: str  # not_in_session | session_started | in_progress
    current_item: str | None
    kept_back: str | None
    pending_serials: list[str]
    coram: str | None


def parse_display_text(body: str) -> list[DisplayBoardRow]:
    """``displaytext.jsp``: records split by ``$``, fields by ``@``.

    Field meaning follows the official displayboard.jsp renderer:
    [0] court, [2] item ('-' = not in session, 'D-0' = session started),
    [4] kept-back cases, [5] pending serials (tooltip), [6] coram.
    """
    text = body.strip()
    if not text:
        return []
    rows: list[DisplayBoardRow] = []
    for rec in text.split("$"):
        rec = rec.strip()
        if not rec:
            continue
        f = rec.split("@")
        if len(f) < 7 or not f[0].strip().isdigit():
            raise UpstreamParseError("unexpected display board record")

        def val(i, f=f):
            v = f[i].strip()
            return None if v in ("", "-", "null") else v

        item = f[2].strip()
        if item == "-":
            state, current = "not_in_session", None
        elif item == "D-0":
            state, current = "session_started", None
        else:
            state, current = "in_progress", item
        pending = [p.strip() for p in (val(5) or "").split(",") if p.strip()]
        rows.append(
            DisplayBoardRow(
                court_no=f[0].strip(),
                state=state,
                current_item=current,
                kept_back=val(4),
                pending_serials=pending,
                coram=val(6),
            )
        )
    return rows


def ensure_found(items: list) -> list:
    if not items:
        raise UpstreamNotFound("no data")
    return items
