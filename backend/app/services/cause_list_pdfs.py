"""Official court cause-list PDFs: read them, check the online list against them, fall back to them.

The online (HTML) court list stays the primary source. The PDF published for the same court and date is
read into the same item shape and used to:

* verify the online list item by item (case number, parties, advocates, district), and
* serve a clearly labelled fallback when the online list cannot be read or is empty.

PDF-derived data never overwrites the online list.
"""

from __future__ import annotations

import logging
import re
from dataclasses import asdict
from datetime import date
from pathlib import Path

from sqlalchemy import func, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.errors import AppError
from app.db.base import as_utc, utcnow
from app.integrations.aphc import pdf_parser
from app.integrations.http import UpstreamParseError
from app.models import CauseList, CauseListPdfParse, PublicationStatus
from app.services import pdfs

logger = logging.getLogger(__name__)

PDF_LIST_TYPE = "D"  # court PDFs linked from the online board are the daily list for that date
SOURCE = "aphc.gov.in official court cause-list PDF"
_FIELDS = (
    ("case_number", "case_display"),
    ("petitioner", "petitioner"),
    ("respondent", "respondent"),
    ("petitioner_advocates", "petitioner_advocates"),
    ("respondent_advocates", "respondent_advocates"),
    ("district", "district"),
)


# ------------------------------------------------------------------ comparison
def _get(obj, name: str):
    return obj.get(name) if isinstance(obj, dict) else getattr(obj, name, None)


def _norm(value) -> str:
    """Compare text only: case, spacing, punctuation and line wrapping are ignored."""
    if isinstance(value, list | tuple):
        value = " ".join(str(v) for v in value if v)
    return re.sub(r"[^A-Z0-9]", "", str(value or "").upper())


def _keyed(items) -> dict[tuple[str, int], object]:
    """Key items by (item number, occurrence): numbering restarts in some courts' later sections."""
    seen: dict[str, int] = {}
    out = {}
    for it in items:
        no = str(_get(it, "item_no") or "").strip()
        seen[no] = seen.get(no, 0) + 1
        out[(no, seen[no])] = it
    return out


def compare(online_items, pdf_items) -> dict:
    """Compare online items (ORM rows or dicts) with PDF items (dicts) by item number and order."""
    online = _keyed(online_items)
    pdf = _keyed(pdf_items)
    per_item: dict[int, dict] = {}
    counts = {"matched": 0, "differs": 0, "not_in_pdf": 0}
    for key, it in online.items():
        p = pdf.get(key)
        seq = _get(it, "sequence")
        if p is None:
            per_item[seq] = {"status": "not_in_pdf", "fields": []}
            counts["not_in_pdf"] += 1
            continue
        diffs = [label for label, attr in _FIELDS if _norm(_get(it, attr)) != _norm(_get(p, attr))]
        per_item[seq] = {"status": "differs" if diffs else "match", "fields": diffs}
        counts["differs" if diffs else "matched"] += 1
    pdf_only = [p for key, p in pdf.items() if key not in online]
    return {"per_item": per_item, **counts, "pdf_only": pdf_only}


# ------------------------------------------------------------------ reading PDFs
def _item_dict(item, pages: tuple[int, int] | None) -> dict:
    d = asdict(item)
    d["pages"] = list(pages) if pages else None
    return d


def _row(db: Session, list_type: str, list_date: date, court_no: str) -> CauseListPdfParse | None:
    return db.scalar(
        select(CauseListPdfParse).where(
            CauseListPdfParse.list_type == list_type,
            CauseListPdfParse.list_date == list_date,
            CauseListPdfParse.court_no == court_no,
        )
    )


def parse_court_pdf(db: Session, list_date: date, court_no: str, *, force: bool = False) -> CauseListPdfParse | None:
    """Download (or reuse) the court's official PDF and read it. None when APHC published no PDF."""
    pub = db.scalar(
        select(PublicationStatus).where(PublicationStatus.list_date == list_date, PublicationStatus.court_no == court_no)
    )
    if pub is None or not pub.pdf_path:
        return None
    doc = pdfs.court_cause_list_pdf(db, list_date, court_no)  # AppError if APHC is unreachable
    row = _row(db, PDF_LIST_TYPE, list_date, court_no)
    if row is not None and not force and row.sha256 == doc.sha256 and row.parser_version == pdf_parser.PARSER_VERSION:
        return row
    status, error_code, result = "parsed", None, None
    try:
        result = pdf_parser.parse_court_pdf(Path(doc.storage_path).read_bytes())
        if not result.parsed.items:
            status = "empty"
    except UpstreamParseError as e:
        status, error_code = "failed", "parser_failure"
        logger.warning("court PDF could not be read: court=%s date=%s (%s)", court_no, list_date, e)
    if row is None:
        row = CauseListPdfParse(list_type=PDF_LIST_TYPE, list_date=list_date, court_no=court_no, sha256=doc.sha256,
                                parser_version=pdf_parser.PARSER_VERSION, status=status)
        try:
            with db.begin_nested():
                db.add(row)
                db.flush()
        except IntegrityError:
            row = _row(db, PDF_LIST_TYPE, list_date, court_no)
    row.source_url = doc.source_url
    row.sha256 = doc.sha256
    row.pdf_document_id = doc.id
    row.parser_version = pdf_parser.PARSER_VERSION
    row.status = status
    row.error_code = error_code
    row.parsed_at = utcnow()
    if result is not None:
        p = result.parsed
        row.page_count = result.page_count
        row.item_count = len(p.items)
        row.bench = p.bench
        row.headings = p.headings
        row.items = [_item_dict(it, result.item_pages.get(it.sequence)) for it in p.items]
    else:
        row.page_count, row.item_count, row.items = 0, 0, []
    db.flush()
    return row


def parse_published_pdfs(db_factory, list_date: date | None = None) -> dict:
    """Background job: read every court PDF APHC has published for the latest (or given) list date."""
    with db_factory() as db:
        if list_date is None:
            list_date = db.scalar(select(func.max(PublicationStatus.list_date)))
        if list_date is None:
            return {"list_date": None, "parsed": 0, "unchanged": 0, "failed": 0}
        courts = list(db.scalars(
            select(PublicationStatus.court_no).where(PublicationStatus.list_date == list_date,
                                                     PublicationStatus.pdf_path.is_not(None))
        ))
    out = {"list_date": list_date.isoformat(), "parsed": 0, "unchanged": 0, "failed": 0, "errors": []}
    for court_no in courts:
        try:
            with db_factory() as db:
                before = _row(db, PDF_LIST_TYPE, list_date, court_no)
                before_key = (before.sha256, before.parser_version) if before else None
                row = parse_court_pdf(db, list_date, court_no)
                if row is None:
                    continue
                if row.status == "failed":
                    out["failed"] += 1
                elif before_key == (row.sha256, row.parser_version) and before is not None:
                    out["unchanged"] += 1
                else:
                    out["parsed"] += 1
        except AppError as e:
            out["errors"].append({"court_no": court_no, "error": e.code})
            if e.code in ("source_paused", "upstream_disabled", "upstream_unavailable", "upstream_blocked"):
                break
    return out


# ------------------------------------------------------------------ serving
def _ensure(db: Session, list_date: date, court_no: str) -> CauseListPdfParse | None:
    row = _row(db, PDF_LIST_TYPE, list_date, court_no)
    if row is not None and row.parser_version == pdf_parser.PARSER_VERSION:
        return row
    try:  # not read yet, or read by an older parser version: read it (again)
        return parse_court_pdf(db, list_date, court_no) or row
    except AppError as e:
        logger.info("court PDF not available for checking: court=%s date=%s (%s)", court_no, list_date, e.code)
        return row


def serialize_pdf_item(d: dict) -> dict:
    return {
        "sequence": d.get("sequence"),
        "item_no": d.get("item_no"),
        "case_id": None,
        "case_number": d.get("case_display"),
        "applications": d.get("applications") or [],
        "petitioner": d.get("petitioner"),
        "respondent": d.get("respondent"),
        "petitioner_advocates": d.get("petitioner_advocates") or [],
        "respondent_advocates": d.get("respondent_advocates") or [],
        "district": d.get("district"),
        "list_section": d.get("list_section"),
        "stage": d.get("stage"),
        "remarks": d.get("remarks"),
        "pdf_pages": d.get("pages"),
    }


def verification(db: Session, cl: CauseList) -> tuple[dict | None, dict[int, dict]]:
    """Summary of the PDF check for an online list, plus the per-item results keyed by sequence."""
    if cl.list_type != PDF_LIST_TYPE:
        return None, {}
    row = _ensure(db, cl.list_date, cl.court_no)
    if row is None:
        return {"status": "not_available", "source": SOURCE}, {}
    base = {
        "source": SOURCE,
        "source_url": row.source_url,
        "checked_at": as_utc(row.parsed_at),
        "parser_version": row.parser_version,
        "pdf_items": row.item_count,
        "pdf_pages": row.page_count,
    }
    if row.status != "parsed":
        return {**base, "status": "failed" if row.status == "failed" else "pdf_empty", "error_code": row.error_code}, {}
    result = compare(cl.items, row.items or [])
    clean = not result["differs"] and not result["not_in_pdf"] and not result["pdf_only"]
    summary = {
        **base,
        "status": "verified" if clean else "differences",
        "matched": result["matched"],
        "differs": result["differs"],
        "not_in_pdf": result["not_in_pdf"],
        "pdf_only": len(result["pdf_only"]),
        "pdf_only_items": [serialize_pdf_item(d) for d in result["pdf_only"]],
    }
    return summary, result["per_item"]


def fallback_listing(db: Session, list_type: str, list_date: date, court_no: str, *, reason: str) -> dict | None:
    """The court list read from the official PDF, for when the online list is unavailable or empty."""
    if list_type != PDF_LIST_TYPE:
        return None
    row = _ensure(db, list_date, court_no)
    if row is None or row.status != "parsed" or not row.items:
        return None
    return {
        "list_type": list_type,
        "list_date": list_date,
        "court_no": court_no,
        "bench": row.bench,
        "headings": row.headings or [],
        "status": "synced",
        "total_cases": row.item_count,
        "fetched_at": as_utc(row.parsed_at),
        "stale": False,
        "source": SOURCE,
        "items_source": "official_pdf",
        "fallback_reason": reason,
        "pdf_verification": None,
        "items": [serialize_pdf_item(d) for d in row.items],
    }
