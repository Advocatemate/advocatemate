"""Parser for APHC court-wise cause-list PDFs (``/Hcdbs/upload/court{n}_{yyyymmdd}.pdf``).

Layout observed on 20-11-2026 (iText-generated, A4, Helvetica):

* A section header block (bold) starts each list section: ``COURT NO. n``, the bench, the "To be Heard
  on ..." note and the list title in brackets, e.g. ``(DAILY LIST)``, followed by the column header row
  ``SNO | CASE | PARTY | PETITIONER ADV. | RESPONDENT ADV. | DISTRICT``. The block is printed only when a
  section starts, NOT on every page; pages in between continue the table directly and an item can
  continue across a page break.
* Inside the table, bold full-width lines are stage headings (``FOR ORDERS``) or grouping notes
  (``6.1 along with 6``); regular-font lines are table cells. A new item starts where the SNO column holds
  an item number (``6``, ``6.1``).
* Each page ends with a centred page number.

Columns are assigned from word positions using the centres of the column-header words, and the last
known column positions are carried across pages that have no header. Text is never invented: cells keep
the source wording; advocate cells keep the PDF's printed lines (a long name can wrap onto two lines).
"""

from __future__ import annotations

import io
import re
from collections import Counter
from dataclasses import dataclass, field

from app.integrations.aphc.parsers import Application, ParsedCauseList, ParsedItem
from app.integrations.http import UpstreamParseError

PARSER_VERSION = "aphc-court-pdf/6"

_COLUMNS = ("sno", "case", "party", "pet_adv", "res_adv", "district")
_HEADER_KEYS = ("SNO", "CASE", "PARTY", "PETITIONER", "RESPONDENT", "DISTRICT")
_ITEM_NO_RE = re.compile(r"^\d{1,4}(\.\d{1,3})?$")
_GROUP_NOTE_RE = re.compile(r"along with", re.IGNORECASE)
_IA_RE = re.compile(r"^(IA|I\.A\.)[\s/]*\d", re.IGNORECASE)
# A main case number such as WP/13577/2026 or MACMA/18030/2011/ (Filing No.); never an IA.
_CASE_RE = re.compile(r"^[A-Z][A-Z.()&-]*\s*/\s*\d+\s*/\s*\d{4}", re.IGNORECASE)
_CASE_PREFIX_RE = re.compile(r"^[A-Z]{1,3}-?$")  # e.g. "X" of "X-OBJ/18/2022", printed on its own line
_CID_RE = re.compile(r"\(cid:\d+\)")  # glyphs the PDF does not map to text (e.g. a tab)
_LINE_TOLERANCE = 2.0  # points: words whose tops differ by less belong to one printed line
# Points. Inside a cell words are 2.2-5.6 pt apart; neighbouring cells are 7+ pt apart.
_RUN_GAP = 6.5
_AT_START = 1.5  # a word this close to a column's text start begins a new cell
_NEAR_START = 12.0  # a run this close to a column's text start belongs to that column
_START_SEARCH = 15.0  # how far real cell starts may sit from the header-based estimate
_FOOTER_ZONE = 45.0  # points above the bottom edge where the page number is printed
MAX_PAGES = 400


@dataclass
class _Word:
    text: str
    x0: float
    x1: float
    top: float
    bold: bool


@dataclass
class _Line:
    top: float
    words: list[_Word]

    @property
    def text(self) -> str:
        return " ".join(w.text for w in self.words)

    @property
    def bold(self) -> bool:
        return all(w.bold for w in self.words)


@dataclass
class _Cells:
    """Lines collected per column for one item, in printed order."""

    lines: dict[str, list[str]] = field(default_factory=lambda: {c: [] for c in _COLUMNS})
    first_page: int = 0
    last_page: int = 0
    printed_lines: int = 0


@dataclass
class PdfParseResult:
    parsed: ParsedCauseList
    page_count: int
    item_pages: dict[int, tuple[int, int]]  # sequence -> (first page, last page), 1-based


def _clean(text: str) -> str:
    return " ".join(text.split())


def _group_lines(words: list[_Word]) -> list[_Line]:
    lines: list[_Line] = []
    for w in sorted(words, key=lambda w: (w.top, w.x0)):
        if lines and abs(lines[-1].top - w.top) < _LINE_TOLERANCE:
            lines[-1].words.append(w)
        else:
            lines.append(_Line(top=w.top, words=[w]))
    for line in lines:
        line.words.sort(key=lambda w: w.x0)
    return lines


def _header_starts(line: _Line) -> list[float] | None:
    """Approximate start of the CASE..DISTRICT cell text, from the centred column-header words."""
    centres: list[float] = []
    words = line.words
    for key in _HEADER_KEYS:
        idx = next((i for i, w in enumerate(words) if w.text.upper().startswith(key)), None)
        if idx is None:
            return None
        # "PETITIONER ADV." / "RESPONDENT ADV." span two words.
        nxt = words[idx + 1] if idx + 1 < len(words) else None
        end = nxt.x1 if nxt is not None and nxt.text.upper().startswith("ADV") else words[idx].x1
        centres.append((words[idx].x0 + end) / 2)
    if centres != sorted(centres):
        return None
    # SNO is narrow, so the CASE column starts half a column-width left of its header centre; the other
    # columns start midway between neighbouring header centres. Cell text is padded ~2 pt from the edge.
    edges = [centres[1] - (centres[2] - centres[1]) / 2]
    edges += [(centres[i - 1] + centres[i]) / 2 for i in range(2, len(centres))]
    return [e + 2.0 for e in edges]


def _runs(words: list[_Word], starts: list[float] | None = None) -> list[list[_Word]]:
    """Words one space apart form a run (one cell's text on this line). A run also ends where the next
    word begins exactly at a column start."""
    runs: list[list[_Word]] = []
    for w in words:
        at_start = starts is not None and any(abs(w.x0 - s) <= _AT_START for s in starts)
        if runs and w.x0 - runs[-1][-1].x1 < _RUN_GAP and not at_start:
            runs[-1].append(w)
        else:
            runs.append([w])
    return runs


def _page_run_starts(lines: list[_Line]) -> Counter:
    """How often table text starts at each x position on a page (regular-font text only)."""
    counts: Counter = Counter()
    for line in lines:
        if line.bold:
            continue
        for run in _runs(line.words):
            counts[round(run[0].x0, 1)] += 1
    return counts


def _refine_starts(approx: list[float], counts: Counter) -> list[float]:
    """Use the positions where cell text actually starts on this page, near each header estimate."""
    out = []
    for a in approx:
        near = [(n, x) for x, n in counts.items() if n >= 2 and abs(x - a) <= _START_SEARCH]
        out.append(max(near)[1] if near else a)
    return out


def _is_column_header(line: _Line) -> bool:
    upper = [w.text.upper() for w in line.words]
    return bool(upper) and upper[0] == "SNO" and "CASE" in upper and "PARTY" in upper


def _split_cells(line: _Line, starts: list[float]) -> dict[str, str]:
    """Assign one printed line's words to the six columns. ``starts`` = CASE..DISTRICT text starts."""
    cells: dict[str, list[str]] = {c: [] for c in _COLUMNS}
    words = list(line.words)
    # Only a leading item number belongs in the narrow SNO column.
    if words and _ITEM_NO_RE.match(words[0].text) and words[0].x0 < starts[0] - 3:
        cells["sno"].append(words.pop(0).text)
    prev_col: int | None = None
    for run in _runs(words, starts):
        x = run[0].x0
        nearest = min(range(len(starts)), key=lambda i: abs(starts[i] - x))
        if abs(starts[nearest] - x) <= _NEAR_START:
            col = nearest + 1
        elif prev_col is not None:
            col = prev_col  # text that starts mid-column continues the previous cell
        else:
            col = 1 + max((i for i, s in enumerate(starts) if x >= s - _NEAR_START), default=0)
        cells[_COLUMNS[col]].extend(w.text for w in run)
        prev_col = col
    return {k: " ".join(v) for k, v in cells.items() if v}


def _applications(lines: list[str]) -> list[Application]:
    apps: list[Application] = []
    for raw in lines:
        line = _clean(raw)
        if not line:
            continue
        last = apps[-1] if apps else None
        if last is not None and last.number.count("(") > last.number.count(")"):
            last.number = f"{last.number} {line}" if not last.number.endswith("(") else last.number + line
            continue
        if line.startswith("(") and line.endswith(")") and not _IA_RE.match(line):
            apps.append(Application(number="ARISING FROM", description=line.strip("()").strip() or None))
        elif _IA_RE.match(line) or re.match(r"^[A-Z]{2,10}\s*\d+/\d{4}", line):
            apps.append(Application(number=line, description=None))
        elif last is not None and last.number != "ARISING FROM":
            last.description = f"{last.description} {line}" if last.description else line
        else:
            apps.append(Application(number=line, description=None))
    return apps


def _parties(lines: list[str]) -> tuple[str | None, str | None]:
    texts = [_clean(t) for t in lines if _clean(t)]
    if "Vs" in texts:
        k = texts.index("Vs")
        return (" ".join(texts[:k]) or None, " ".join(texts[k + 1 :]) or None)
    return (" ".join(texts) or None, None)


def _join_wrapped(lines: list[str]) -> list[str]:
    """Rejoin entries the PDF wrapped: inside an open bracket ('IA 1/2017(WPMP' + '49276/2017)') or after
    a short case-type prefix printed on its own line ('X' + 'OBJ/18/2022' -> 'X-OBJ/18/2022')."""
    out: list[str] = []
    for line in lines:
        if out and out[-1].count("(") > out[-1].count(")"):
            out[-1] = f"{out[-1]} {line}"
        elif len(out) == 1 and _CASE_PREFIX_RE.match(out[0]) and _CASE_RE.match(line):
            out[0] = f"{out[0].rstrip('-')}-{line}"
        else:
            out.append(line)
    return out


def _build_item(seq: int, cells: _Cells, *, section: str | None, stage: str | None, remark: str | None) -> ParsedItem:
    case_lines = _join_wrapped([_clean(t) for t in cells.lines["case"] if _clean(t)])
    # The main case is the first case number that is not an IA; some items print the IA above it.
    main = next((i for i, t in enumerate(case_lines) if _CASE_RE.match(t) and not _IA_RE.match(t)), 0)
    case_display = case_lines[main] if case_lines else ""
    others = case_lines[:main] + case_lines[main + 1 :]
    petitioner, respondent = _parties(cells.lines["party"])
    district = " ".join(_clean(t) for t in cells.lines["district"] if _clean(t)) or None
    return ParsedItem(
        sequence=seq,
        item_no=_clean(cells.lines["sno"][0]),
        case_display=case_display,
        applications=_applications(others),
        petitioner=petitioner,
        respondent=respondent,
        petitioner_advocates=[_clean(t) for t in cells.lines["pet_adv"] if _clean(t)],
        respondent_advocates=[_clean(t) for t in cells.lines["res_adv"] if _clean(t)],
        district=district,
        list_section=section,
        stage=stage,
        remarks=remark,
    )


def _page_words(page) -> list[_Word]:
    words = page.extract_words(extra_attrs=["fontname"], keep_blank_chars=False, x_tolerance=1.5, y_tolerance=2)
    out = []
    for w in words:
        text = _CID_RE.sub("", w["text"]).strip()
        if text:
            out.append(_Word(text=text, x0=float(w["x0"]), x1=float(w["x1"]), top=float(w["top"]),
                             bold="bold" in w["fontname"].lower()))
    return out


def parse_court_pdf(content: bytes) -> PdfParseResult:
    """Parse one court's cause-list PDF into the same item shape as the online (HTML) list."""
    try:
        import pdfplumber  # imported lazily: only the PDF jobs need it
    except ImportError as e:  # pragma: no cover - dependency is pinned in requirements.txt
        raise UpstreamParseError("PDF parser is not installed") from e
    if not content.startswith(b"%PDF"):
        raise UpstreamParseError("not a PDF document")

    result = ParsedCauseList(court_label=None, bench=None)
    item_pages: dict[int, tuple[int, int]] = {}
    approx: list[float] | None = None  # header-based column starts, carried across pages
    in_header = False
    section: str | None = None
    stage: str | None = None
    pending_remark: str | None = None
    current: _Cells | None = None
    current_meta: tuple[str | None, str | None, str | None] = (None, None, None)
    seq = 0

    def flush() -> None:
        nonlocal current, seq
        if current is None:
            return
        seq += 1
        sec, stg, rem = current_meta
        result.items.append(_build_item(seq, current, section=sec, stage=stg, remark=rem))
        item_pages[seq] = (current.first_page, current.last_page)
        current = None

    try:
        pdf = pdfplumber.open(io.BytesIO(content))
    except Exception as e:  # noqa: BLE001 - any pdfminer failure means the file is unreadable
        raise UpstreamParseError("PDF could not be opened") from e
    with pdf:
        page_count = len(pdf.pages)
        if page_count == 0 or page_count > MAX_PAGES:
            raise UpstreamParseError(f"unexpected PDF page count: {page_count}")
        for page_no, page in enumerate(pdf.pages, start=1):
            height = float(page.height)
            lines = _group_lines(_page_words(page))
            run_starts = _page_run_starts(lines)
            starts = _refine_starts(approx, run_starts) if approx else None
            for line in lines:
                text = _clean(line.text)
                if line.top > height - _FOOTER_ZONE and re.fullmatch(r"\d{1,4}", text):
                    continue  # page number
                upper = text.upper()
                if line.bold and upper.startswith("COURT NO"):
                    flush()
                    in_header = True
                    result.court_label = result.court_label or text
                    continue
                if _is_column_header(line):
                    found = _header_starts(line)
                    if found is None:
                        raise UpstreamParseError("column header found but columns could not be located")
                    approx = found
                    starts = _refine_starts(approx, run_starts)
                    in_header = False
                    stage = None
                    continue
                if in_header:
                    if upper.startswith(("THE HONOURABLE", "HON'BLE", "THE HON'BLE")):
                        result.bench = result.bench or text
                    elif text.startswith("(") and text.endswith(")"):
                        section = text.strip("()").strip()
                        if text not in result.headings:
                            result.headings.append(text)
                    elif result.headings and not result.headings[-1].startswith("(") and not upper.startswith("TO BE"):
                        # A heading that wrapped onto a second printed line.
                        result.headings[-1] = f"{result.headings[-1]} {text}"
                    elif text not in result.headings:
                        result.headings.append(text)
                    continue
                if starts is None:
                    continue  # text before the first table (e.g. a notice) is not an item
                if line.bold:
                    flush()
                    if _GROUP_NOTE_RE.search(text):
                        pending_remark = f"{pending_remark}; {text}" if pending_remark else text
                    else:
                        stage = text
                    continue
                cells = _split_cells(line, starts)
                sno = cells.get("sno", "")
                if (sno.isdigit() and current is not None and current.printed_lines == 1
                        and "." in current.lines["sno"][0]):
                    # A long item number wraps in the narrow column: "165.1" then "0" -> "165.10". Every
                    # item spans at least three lines (petitioner / Vs / respondent), so a number on an
                    # item's second line is never a new item.
                    current.lines["sno"][0] += sno
                    cells.pop("sno")
                    sno = ""
                if sno and _ITEM_NO_RE.match(sno):
                    flush()
                    current = _Cells(first_page=page_no, last_page=page_no)
                    current_meta = (section, stage, pending_remark)
                    pending_remark = None
                elif current is None:
                    continue
                current.last_page = page_no
                current.printed_lines += 1
                for col, value in cells.items():
                    current.lines[col].append(value)
        flush()

    if approx is None:
        raise UpstreamParseError("cause-list table header not found in PDF")
    return PdfParseResult(parsed=result, page_count=page_count, item_pages=item_pages)
