from __future__ import annotations

import logging
import socket
import uuid
from datetime import datetime, time, timedelta
from zoneinfo import ZoneInfo

from sqlalchemy import delete, select

from app.core.errors import AppError
from app.db.base import utcnow
from app.db.session import db_session
from app.models import (
    AdvocateCaseLink,
    CauseListPdfParse,
    FavouriteAdvocate,
    FavouriteCase,
    OtpRecord,
    PassedOverItem,
    PdfDocument,
    RefreshToken,
    SourceCache,
)
from app.services import cause_list_pdfs, cause_lists, enrichment, live_board, notifications
from app.workers.celery_app import celery_app

logger = logging.getLogger(__name__)
IST = ZoneInfo("Asia/Kolkata")


def _owner() -> str:
    return f"{socket.gethostname()}:{uuid.uuid4().hex[:8]}"


def court_hours(now: datetime | None = None) -> bool:
    now = (now or datetime.now(IST)).astimezone(IST)
    return now.weekday() < 6 and time(9, 30) <= now.time() <= time(18, 0)


@celery_app.task(name="app.tasks.jobs.dispatch_enrichment")
def dispatch_enrichment() -> int:
    """Lease due jobs and fan them out; leases protect against double execution."""
    owner = _owner()
    ids = enrichment.claim_due_jobs(owner)
    for job_id in ids:
        run_enrichment_job.delay(str(job_id), owner)
    return len(ids)


@celery_app.task(name="app.tasks.jobs.run_enrichment_job")
def run_enrichment_job(job_id: str, owner: str) -> str:
    return enrichment.run_job(uuid.UUID(job_id), owner)


@celery_app.task(name="app.tasks.jobs.poll_display_board")
def poll_display_board(force: bool = False) -> int | str:
    if not force and not court_hours():
        return "outside_court_hours"
    try:
        with db_session() as db:
            return live_board.poll_display_board(db)
    except AppError as e:
        logger.warning("display board poll failed: %s", e.code)
        return e.code


@celery_app.task(name="app.tasks.jobs.poll_publication_status")
def poll_publication_status() -> dict | str:
    try:
        with db_session() as db:
            result = live_board.poll_publication_status(db)
            notifications.publication_changes(db, result["list_date"], result["changes"])
            return {"list_date": result["list_date"].isoformat(), "changes": len(result["changes"])}
    except AppError as e:
        logger.warning("publication poll failed: %s", e.code)
        return e.code


@celery_app.task(name="app.tasks.jobs.parse_cause_list_pdfs")
def parse_cause_list_pdfs() -> dict | str:
    """Read the court cause-list PDFs APHC has published, to check and back up the online lists."""
    try:
        return cause_list_pdfs.parse_published_pdfs(db_session)
    except AppError as e:
        logger.warning("cause-list PDF parsing failed: %s", e.code)
        return e.code


@celery_app.task(name="app.tasks.jobs.sync_latest_daily_lists")
def sync_latest_daily_lists() -> dict | str:
    try:
        with db_session() as db:
            dates = cause_lists.available_dates(db, "D")["dates"]
        if not dates:
            return "no_dates"
        from datetime import date

        return cause_lists.sync_all_courts(db_session, "D", date.fromisoformat(dates[0]))
    except AppError as e:
        logger.warning("daily list sync failed: %s", e.code)
        return e.code


@celery_app.task(name="app.tasks.jobs.notify_favourites")
def notify_favourites() -> dict:
    """For the next list date: favourite advocates' listings + saved cases appearing in synced lists."""
    from datetime import date

    from app.models import CauseList, CauseListItem
    from app.services import advocates

    sent = {"advocates": 0, "cases": 0}
    with db_session() as db:
        try:
            dates = cause_lists.available_dates(db, "D")["dates"]
        except AppError:
            return sent
    if not dates:
        return sent
    target = date.fromisoformat(dates[0])
    with db_session() as db:
        codes = sorted(set(db.scalars(select(FavouriteAdvocate.advocate_code))))
    for code in codes[:200]:
        try:
            with db_session() as db:
                result = advocates.advocate_cause_list(db, code, target)
                sent["advocates"] += notifications.favourite_advocate_listed(db, code, target, result["total_cases"])
        except AppError:
            continue
    with db_session() as db:
        rows = db.execute(
            select(CauseListItem.case_id, CauseList.court_no, CauseListItem.item_no)
            .join(CauseList).where(CauseList.list_date == target,
                                   CauseListItem.case_id.in_(select(FavouriteCase.case_id)))).all()
        for case_id, court_no, item_no in rows:
            sent["cases"] += notifications.favourite_case_listed(db, case_id, target, court_no, item_no)
    return sent


@celery_app.task(name="app.tasks.jobs.housekeeping")
def housekeeping() -> dict:
    """Retention: expired OTPs (1 day), refresh tokens (expired 7 days), source cache (2 days),
    expired generated PDFs, advocate-case links older than 180 days, PDF reads older than 60 days,
    passed-over records older than 180 days."""
    now = utcnow()
    with db_session() as db:
        r = {
            "otps": db.execute(delete(OtpRecord).where(OtpRecord.created_at < now - timedelta(days=1))).rowcount,
            "refresh_tokens": db.execute(delete(RefreshToken)
                                         .where(RefreshToken.expires_at < now - timedelta(days=7))).rowcount,
            "source_cache": db.execute(delete(SourceCache)
                                       .where(SourceCache.expires_at < now - timedelta(days=2))).rowcount,
            "links": db.execute(delete(AdvocateCaseLink)
                                .where(AdvocateCaseLink.fetched_at < now - timedelta(days=180))).rowcount,
        }
        from pathlib import Path

        expired = db.scalars(select(PdfDocument).where(PdfDocument.kind == "case_summary_generated",
                                                       PdfDocument.expires_at < now)).all()
        for doc in expired:
            Path(doc.storage_path).unlink(missing_ok=True)
            db.delete(doc)
        r["generated_pdfs"] = len(expired)
        r["pdf_parses"] = db.execute(delete(CauseListPdfParse)
                                     .where(CauseListPdfParse.parsed_at < now - timedelta(days=60))).rowcount
        r["passed_over"] = db.execute(delete(PassedOverItem)
                                      .where(PassedOverItem.last_seen_at < now - timedelta(days=180))).rowcount
    return r
