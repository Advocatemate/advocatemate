"""Advocates, cause lists, cases, PDFs, live courts and search."""

from __future__ import annotations

import uuid
from datetime import date

from fastapi import APIRouter, Depends, Query
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session

from app.api.deps import CurrentUser, get_current_user
from app.core import rate_limit
from app.core.errors import AppError, NotFound, RateLimited
from app.db.session import get_db
from app.services import (
    advocates,
    case_details,
    cause_lists,
    enrichment,
    live_board,
    passed_over,
    pdfs,
    search,
)
from app.services.cases import get_case_or_404, get_or_create_case, parse_identity_or_400

router = APIRouter(dependencies=[Depends(get_current_user)])
OTHER_ADVOCATE_LOOKUPS_PER_10_MIN = 60  # date changes count too; the user's own code is not limited


def _today() -> date:
    from datetime import datetime
    from zoneinfo import ZoneInfo

    return datetime.now(ZoneInfo("Asia/Kolkata")).date()


# ------------------------------------------------------------------ advocates
def _limit_other_advocate_lookups(current: CurrentUser, advocate_code: str) -> None:
    """Looking up other advocates' codes goes to the High Court's Lexika service: cap it per user."""
    own = current.profile.advocate_code if current.profile else None
    if advocate_code.strip() != own:
        try:
            rate_limit.hit(f"advocate-lookup:{current.id}", OTHER_ADVOCATE_LOOKUPS_PER_10_MIN, 600)
        except RateLimited as e:
            raise RateLimited("Too many advocate lookups. Please wait a few minutes and try again.",
                              code="advocate_lookup_limited") from e


@router.get("/advocates/{advocate_code}", tags=["advocates"])
def get_advocate(advocate_code: str, db: Session = Depends(get_db), current: CurrentUser = Depends(get_current_user)):
    _limit_other_advocate_lookups(current, advocate_code)
    adv, dates = advocates.lookup(db, advocate_code)
    return {"advocate_code": adv.advocate_code, "name": adv.name, "available_cause_list_dates": dates,
            "source": "aphc.gov.in Lexika"}


@router.get("/advocates/{advocate_code}/profile", tags=["advocates"])
def get_advocate_profile(advocate_code: str, db: Session = Depends(get_db)):
    return advocates.get_profile(db, advocate_code)


# ------------------------------------------------------------------ cause lists
@router.get("/cause-list/advocate/{advocate_code}", tags=["cause lists"], summary="My / advocate cause list")
def advocate_cause_list(advocate_code: str, list_date: date | None = Query(None, alias="date"),
                        refresh: bool = False, db: Session = Depends(get_db),
                        current: CurrentUser = Depends(get_current_user)):
    _limit_other_advocate_lookups(current, advocate_code)
    return advocates.advocate_cause_list(db, advocate_code, list_date or _today(), refresh=refresh)


@router.get("/cause-list/passed-over", tags=["cause lists"], summary="Passed-over (kept back) items")
def passed_over_list(list_date: date | None = Query(None, alias="date"), db: Session = Depends(get_db)):
    """Items courts kept back, from "Kept Back Cases" on the APHC display board, with their cases."""
    try:
        board = live_board.live_board(db)
    except AppError:
        board = None
    return passed_over.passed_over_list(db, list_date, board=board)


@router.get("/cause-list/dates", tags=["cause lists"], summary="Dates APHC currently offers for a list type")
def cause_list_dates(list_type: str = Query("D", description="D, W or S"), db: Session = Depends(get_db)):
    return cause_lists.available_dates(db, list_type)


@router.get("/cause-list/courts", tags=["cause lists"])
def cause_list_courts(list_type: str = "D", list_date: date | None = Query(None, alias="date"),
                      db: Session = Depends(get_db)):
    return cause_lists.courts_for(db, list_type, list_date or _today())


@router.get("/cause-list/court/{court_no}", tags=["cause lists"])
def court_cause_list(court_no: str, list_type: str = "D", list_date: date | None = Query(None, alias="date"),
                     refresh: bool = False, db: Session = Depends(get_db)):
    return cause_lists.get_court_listing(db, list_type, list_date or _today(), court_no, refresh=refresh)


@router.get("/cause-list", tags=["cause lists"], summary="Overview of a list (dates + courts) for one type/date")
def cause_list_overview(list_type: str = "D", list_date: date | None = Query(None, alias="date"),
                        db: Session = Depends(get_db)):
    dates = cause_lists.available_dates(db, list_type)
    chosen = list_date
    if chosen is None:
        chosen = date.fromisoformat(dates["dates"][0]) if dates["dates"] else _today()
    offered = chosen.isoformat() in dates["dates"]
    courts = cause_lists.courts_for(db, list_type, chosen) if offered else None
    return {"list_type": dates["list_type"], "list_date": chosen, "date_offered_by_source": offered,
            "available_dates": dates["dates"], "courts": courts["courts"] if courts else [],
            "fetched_at": (courts or dates)["fetched_at"], "stale": (courts or dates)["stale"]}


@router.get("/cause-list/status", tags=["cause lists"], summary="Court-wise publication status (online board)")
def cause_list_status(db: Session = Depends(get_db)):
    return live_board.publication_status(db)


@router.get("/cause-list/weekly.pdf", tags=["pdf"], response_class=FileResponse,
            summary="Official weekly cause-list PDF (proxied from APHC)")
def weekly_pdf(db: Session = Depends(get_db)):
    doc = pdfs.weekly_cause_list_pdf(db)
    return _pdf_response(doc, "weekly-cause-list.pdf")


@router.get("/cause-list/court/{court_no}/pdf", tags=["pdf"], response_class=FileResponse,
            summary="Official court-wise cause-list PDF as linked from APHC online board")
def court_pdf(court_no: str, list_date: date | None = Query(None, alias="date"), db: Session = Depends(get_db)):
    d = list_date or _today()
    doc = pdfs.court_cause_list_pdf(db, d, court_no)
    return _pdf_response(doc, f"court-{court_no}-{d.isoformat()}.pdf")


def _pdf_response(doc, filename: str) -> FileResponse:
    path = pdfs.require_file(doc)
    return FileResponse(path, media_type="application/pdf", filename=filename, headers={
        "X-Document-Official": "true" if doc.is_official else "false",
        "X-Document-Kind": doc.kind,
        "X-Source-Url": doc.source_url or "",
        "Cache-Control": "private, max-age=300",
    })


# ------------------------------------------------------------------ cases
@router.get("/case-details", tags=["cases"], summary="Case details by case number (triggers async enrichment)")
def case_details_by_number(case_number: str = Query(..., examples=["WP/32115/2023"]),
                           current: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)):
    identity = parse_identity_or_400(case_number)
    case = get_or_create_case(db, identity)
    return case_details.build(db, case, user_id=current.id)


@router.get("/cases/{case_id}", tags=["cases"])
def case_by_id(case_id: uuid.UUID, current: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)):
    return case_details.build(db, get_case_or_404(db, case_id), user_id=current.id)


@router.get("/cases/{case_id}/enrichment-status", tags=["cases"])
def case_enrichment_status(case_id: uuid.UUID, db: Session = Depends(get_db)):
    return enrichment.status_payload(db, get_case_or_404(db, case_id))


@router.post("/cases/{case_id}/refresh", tags=["cases"], status_code=202, summary="Request fresh enrichment")
def case_refresh(case_id: uuid.UUID, current: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)):
    rate_limit.hit(f"case-refresh:{current.id}", 20, 3600)
    case = get_case_or_404(db, case_id)
    enrichment.request_enrichment(db, case, user_id=current.id, force=True)
    return enrichment.status_payload(db, case)


@router.get("/cases/{case_id}/pdf", tags=["pdf"], response_class=FileResponse,
            summary="AdvocateMate-generated case summary PDF (NOT an official court document)")
def case_pdf(case_id: uuid.UUID, kind: str = Query("summary", pattern="^(summary|order)$"),
             db: Session = Depends(get_db)):
    case = get_case_or_404(db, case_id)
    if kind == "order":
        raise NotFound("Official order PDFs are not available: no verified APHC order retrieval path exists yet.",
                       code="official_order_unavailable")
    details = case_details.build(db, case, request_enrichment=False)
    doc = pdfs.case_summary_pdf(db, case, details)
    return _pdf_response(doc, f"case-summary-{case.compact_key}-advocatemate-generated.pdf")


# ------------------------------------------------------------------ live courts
@router.get("/live-courts", tags=["live courts"])
def live_courts(court_no: str | None = None, db: Session = Depends(get_db)):
    if court_no is not None and not court_no.isdigit():
        raise AppError("court_no must be numeric", status_code=422)
    return live_board.live_board(db, court_no)


# ------------------------------------------------------------------ search
@router.get("/search/cases", tags=["search"])
def search_cases(q: str | None = Query(None, max_length=80), case_type: str | None = Query(None, max_length=20),
                 case_number: str | None = Query(None, pattern=r"^\d{1,8}$"),
                 case_year: int | None = Query(None, ge=1900, le=2100),
                 party: str | None = Query(None, min_length=3, max_length=80),
                 advocate: str | None = Query(None, min_length=3, max_length=80),
                 limit: int = Query(25, ge=1, le=100), offset: int = Query(0, ge=0),
                 current: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)):
    return search.search_cases(db, user_id=current.id, q=q, case_type=case_type, case_number=case_number,
                               case_year=case_year, party=party, advocate=advocate, limit=limit, offset=offset)


@router.get("/search/history", tags=["search"])
def search_history(current: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)):
    return {"items": search.history(db, current.id)}


@router.delete("/search/history", tags=["search"], status_code=204)
def clear_search_history(current: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)):
    from sqlalchemy import delete

    from app.models import SearchHistory

    db.execute(delete(SearchHistory).where(SearchHistory.user_id == current.id))


@router.get("/search/suggestions", tags=["search"])
def search_suggestions(prefix: str = Query(..., min_length=2, max_length=30), db: Session = Depends(get_db)):
    return {"items": search.suggestions(db, prefix)}
