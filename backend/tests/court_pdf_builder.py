"""Builds synthetic court cause-list PDFs in the APHC layout (fictional data only).

Geometry follows the official PDFs observed on 20-11-2026: A4, Helvetica 8 pt cells, bold headers,
a section header block printed only when a section starts, items that continue across page breaks and a
centred page number at the foot of each page.
"""

from __future__ import annotations

import io
from dataclasses import dataclass, field

from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas

PAGE_H = A4[1]
COL_X = {"case": 58.8, "party": 165.8, "pet": 272.8, "res": 379.8, "district": 486.8}
SNO_RIGHT = 49.0
HEADER_CENTRES = [("SNO", 43.4), ("CASE", 110.3), ("PARTY", 217.3), ("PETITIONER ADV.", 324.3),
                  ("RESPONDENT ADV.", 431.3), ("DISTRICT", 524.9)]
LINE = 8.0
TOP_START = 18.7
BOTTOM_LIMIT = 790.0


@dataclass
class Section:
    title: str  # e.g. "(DAILY LIST)"
    court: str = "COURT NO. 3"
    bench: str = "THE HONOURABLE SMT JUSTICE SAMPLE JUDGE"
    heard: str = "To be Heard on Wednesday The 18th day of November 2026(AT 10:30 AM)"


@dataclass
class Stage:
    text: str


@dataclass
class Note:
    text: str


@dataclass
class PageBreak:
    dx: float = 0.0  # shift the table on the next page (positions vary slightly between pages)


@dataclass
class Item:
    sno: str
    case: list[str]
    party: list[str] = field(default_factory=list)
    pet: list[str] = field(default_factory=list)
    res: list[str] = field(default_factory=list)
    district: list[str] = field(default_factory=list)
    break_after: int | None = None  # continue the item on a new page after this many lines
    dx_after_break: float = 0.0
    sno_wrap: str | None = None  # rest of a long item number, printed on the item's second line


class _Writer:
    def __init__(self):
        self.buf = io.BytesIO()
        self.c = canvas.Canvas(self.buf, pagesize=A4)
        self.page = 1
        self.top = TOP_START
        self.dx = 0.0

    def text(self, x: float, top: float, s: str, *, bold: bool = False, size: float = 8.0, centre: bool = False,
             right: bool = False) -> None:
        font = "Helvetica-Bold" if bold else "Helvetica"
        self.c.setFont(font, size)
        y = PAGE_H - top - size * 0.718
        if centre:
            self.c.drawCentredString(x, y, s)
        elif right:
            self.c.drawRightString(x, y, s)
        else:
            self.c.drawString(x, y, s)

    def new_page(self, dx: float = 0.0) -> None:
        self.text(297.5, 812.5, str(self.page), centre=True)
        self.c.showPage()
        self.page += 1
        self.top = TOP_START
        self.dx = dx

    def ensure(self, height: float) -> None:
        if self.top + height > BOTTOM_LIMIT:
            self.new_page()

    def finish(self) -> bytes:
        self.text(297.5, 812.5, str(self.page), centre=True)
        self.c.save()
        return self.buf.getvalue()


def build_court_pdf(events: list) -> bytes:
    w = _Writer()
    first = True
    for ev in events:
        if isinstance(ev, Section):
            if not first:
                w.new_page()
            first = False
            w.text(297.5, w.top + 30, ev.court, bold=True, size=11, centre=True)
            w.text(297.5, w.top + 45, ev.bench, bold=True, size=10, centre=True)
            w.text(49.7, w.top + 59, ev.heard, bold=True, size=10)
            w.text(297.5, w.top + 83, ev.title, bold=True, size=10, centre=True)
            for label, centre in HEADER_CENTRES:
                w.text(centre + w.dx, w.top + 97, label, bold=True, centre=True)
            w.top += 109
        elif isinstance(ev, Stage):
            w.ensure(12)
            w.text(32.0 + w.dx, w.top, ev.text, bold=True)
            w.top += 12
        elif isinstance(ev, Note):
            w.ensure(13)
            w.text(32.0 + w.dx, w.top, ev.text, bold=True, size=10)
            w.top += 13
        elif isinstance(ev, PageBreak):
            w.new_page(ev.dx)
        elif isinstance(ev, Item):
            cols = {k: getattr(ev, k) for k in COL_X}
            rows = max(len(v) for v in cols.values())
            if ev.break_after is None:
                w.ensure(rows * LINE)
            for i in range(rows):
                if ev.break_after is not None and i == ev.break_after:
                    w.new_page(ev.dx_after_break)
                if i == 0:
                    w.text(SNO_RIGHT + w.dx, w.top, ev.sno, right=True)
                elif i == 1 and ev.sno_wrap:
                    w.text(SNO_RIGHT + w.dx, w.top, ev.sno_wrap, right=True)
                for k, x in COL_X.items():
                    if i < len(cols[k]) and cols[k][i]:
                        w.text(x + w.dx, w.top, cols[k][i])
                w.top += LINE
            w.top += 8
    return w.finish()


def fixture_court3_pdf(*, item2_pet: str = "ADVOCATE THREE", extra_item: bool = False) -> bytes:
    """The same four items as tests/fixtures/hcdbs/court_list.html (court 3, 18-11-2026)."""
    events: list = [
        Section("(CAUSE LIST MOTION HEARING)"),
        Stage("ADMISSION (OTHER SUBJECTS)"),
        Item("1", ["WP/11111/2026", "IA 1/2026", "Direction Petition", "IA 2/2026", "Implead Petition"],
             ["PETITIONER ALPHA", "Vs", " THE STATE OF ANDHRA", "PRADESH"], ["ADVOCATE ONE"],
             ["GP FOR REVENUE", "ADVOCATE TWO"], ["GUNTUR"]),
        Item("2", ["WP(PIL)/22/2025"], ["PETITIONER BETA", "Vs", " RESPONDENT BETA"], [item2_pet],
             ["ADVOCATE FOUR"], ["KRISHNA"]),
        Section("(ADJOURNED MOTION LIST)",
                heard="To be Heard on Wednesday The 18th day of November 2026(AFTER MOTION LIST)"),
        Stage("ADMISSION (REVENUE)"),
        Item("59", ["WP/333/2017", "IA 1/2017(WPMP", "3456/2017)", "Direction Petition"],
             ["PETITIONER GAMMA", "Vs", " RESPONDENT GAMMA"], ["ADVOCATE FIVE"], ["GP FOR REVENUE (AP)"],
             ["VISAKHAPATNAM"]),
        Note("59.1 along with 59"),
        Item("59.1", ["WP/444/2018"], ["PETITIONER DELTA", "Vs", " RESPONDENT DELTA"], ["ADVOCATE FIVE"],
             ["GP FOR REVENUE (AP)"], ["VISAKHAPATNAM"]),
    ]
    if extra_item:
        events.append(Item("60", ["WP/555/2019"], ["PETITIONER EPSILON", "Vs", " RESPONDENT EPSILON"],
                           ["ADVOCATE SIX"], [], ["GUNTUR"]))
    return build_court_pdf(events)
