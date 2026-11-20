"""Live court display board and cause-list publication status.

Only the backend polls APHC (Celery beat); mobile clients read the stored snapshot.
"""

from __future__ import annotations

import logging
from dataclasses import asdict
from datetime import timedelta

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import AppError, ServiceUnavailable
from app.db.base import as_utc, utcnow
from app.models import Court, PublicationStatus
from app.services import circuit, passed_over, sources
from app.services.upstream_errors import translate_upstream

logger = logging.getLogger(__name__)
BOARD_KEY = "live_board:displaytext"


def poll_display_board(db: Session) -> int:
    client = sources.aphc_client()
    try:
        with translate_upstream():
            rows = circuit.call(circuit.HCDBS_DISPLAY, client.display_board)
    finally:
        client.close()
    payload = {"rows": [asdict(r) for r in rows]}
    # Keep the snapshot long enough to show as stale, never as current.
    sources.cache_put(db, BOARD_KEY, payload, 24 * 3600)
    try:
        with db.begin_nested():
            passed_over.record_board(db, rows)
    except Exception:  # noqa: BLE001 - never lose the board snapshot because of the passed-over record
        logger.exception("could not record kept-back items from the display board")
    return len(rows)


def live_board(db: Session, court_no: str | None = None) -> dict:
    s = get_settings()
    payload, fetched_at, _ = sources.cache_get(db, BOARD_KEY, allow_stale=True)
    if payload is None:
        raise ServiceUnavailable("Live court display data has not been received yet.", code="board_unavailable")
    age = (utcnow() - fetched_at).total_seconds()
    stale = age > s.live_board_stale_seconds
    rows = payload["rows"]
    if court_no:
        rows = [r for r in rows if r["court_no"] == court_no]
    rows = sorted(rows, key=lambda r: int(r["court_no"]) if r["court_no"].isdigit() else 9999)
    return {
        "fetched_at": fetched_at,
        "age_seconds": int(age),
        "stale": stale,
        "is_current": not stale,
        "stale_after_seconds": s.live_board_stale_seconds,
        "source": "aphc.gov.in/Hcdbs/displaytext.jsp",
        "courts": rows,
        "note": None
        if not stale
        else "This display data is out of date. It is NOT the current court position.",
    }


# ------------------------------------------------------------------ publication
def poll_publication_status(db: Session) -> dict:
    client = sources.aphc_client()
    try:
        with translate_upstream():
            board = circuit.call(circuit.HCDBS_PUBLICATION, client.publication_board)
    finally:
        client.close()
    changes = []
    for r in board.rows:
        row = db.scalar(
            select(PublicationStatus).where(
                PublicationStatus.list_date == board.list_date, PublicationStatus.court_no == r.court_no
            )
        )
        if row is None:
            row = PublicationStatus(list_date=board.list_date, court_no=r.court_no, status=r.status)
            db.add(row)
            changes.append((r.court_no, None, r.status))
        elif row.status != r.status:
            changes.append((r.court_no, row.status, r.status))
        row.status = r.status
        row.bench_code = r.bench_code
        row.coram = r.coram
        row.uploaded_at_text = r.uploaded_at_text
        row.pdf_path = r.pdf_path
        row.fetched_at = utcnow()
        court = db.get(Court, r.court_no)
        if court is None:
            db.add(Court(court_no=r.court_no, bench_code=r.bench_code, coram=r.coram))
        else:
            court.bench_code, court.coram = r.bench_code, r.coram
    db.flush()
    return {"list_date": board.list_date, "changes": changes}


def publication_status(db: Session) -> dict:
    latest = db.scalar(select(PublicationStatus.list_date).order_by(PublicationStatus.list_date.desc()).limit(1))
    if latest is None:
        try:
            poll_publication_status(db)
        except AppError as e:
            raise ServiceUnavailable("Cause-list publication status is not available yet.", code="status_unavailable") from e
        latest = db.scalar(select(PublicationStatus.list_date).order_by(PublicationStatus.list_date.desc()).limit(1))
    rows = db.scalars(select(PublicationStatus).where(PublicationStatus.list_date == latest)).all()
    fetched = max((as_utc(r.fetched_at) for r in rows), default=None)
    stale = fetched is None or utcnow() - fetched > timedelta(minutes=get_settings().publication_poll_minutes * 3)
    counts: dict[str, int] = {}
    for r in rows:
        counts[r.status] = counts.get(r.status, 0) + 1
    return {
        "list_date": latest,
        "fetched_at": fetched,
        "stale": stale,
        "summary": counts,
        "courts": sorted(
            [
                {
                    "court_no": r.court_no,
                    "bench_code": r.bench_code,
                    "coram": r.coram,
                    "status": r.status,
                    "uploaded_at": r.uploaded_at_text,
                    "has_pdf": bool(r.pdf_path),
                }
                for r in rows
            ],
            key=lambda x: int(x["court_no"]),
        ),
        "source": "aphc.gov.in/Hcdbs/online_board.jsp",
    }
