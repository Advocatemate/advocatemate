"""Daily / weekly / supplementary cause lists from APHC Hcdbs (court-wise flow)."""

from __future__ import annotations

import logging
from dataclasses import asdict
from datetime import date, timedelta

from sqlalchemy import delete, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import AppError
from app.db.base import as_utc, utcnow
from app.integrations.aphc import parsers
from app.integrations.aphc.client import LIST_TYPES
from app.models import CauseList, CauseListItem, Court
from app.services import circuit, sources
from app.services.cases import get_or_create_case
from app.services.upstream_errors import translate_upstream
from app.utils.case_identity import CaseIdentity, InvalidCaseIdentity

logger = logging.getLogger(__name__)
MIN_FORCED_REFRESH = timedelta(minutes=5)


def validate_list_type(list_type: str) -> str:
    lt = (list_type or "").upper()
    if lt in ("DAILY", "WEEKLY", "SUPPLEMENTARY"):
        lt = lt[0]
    if lt not in LIST_TYPES:
        raise AppError("list_type must be D (daily), W (weekly) or S (supplementary)", status_code=422)
    return lt


# ------------------------------------------------------------------ dates
def available_dates(db: Session, list_type: str) -> dict:
    lt = validate_list_type(list_type)
    key = f"dates:{lt}"
    payload, fetched_at, fresh = sources.cache_get(db, key, allow_stale=True)
    if not fresh:
        try:
            with translate_upstream():
                client = sources.aphc_client()
                try:
                    dates = circuit.call(circuit.HCDBS_CAUSE_LIST, lambda: client.list_dates(lt))
                finally:
                    client.close()
            payload = {"dates": [d.isoformat() for d in dates]}
            fetched_at = sources.cache_put(db, key, payload, get_settings().cause_list_cache_minutes * 60)
            fresh = True
        except AppError:
            if payload is None:
                raise
    return {"list_type": lt, "dates": payload["dates"], "fetched_at": fetched_at, "stale": not fresh}


# ------------------------------------------------------------------ courts
def courts_for(db: Session, list_type: str, list_date: date) -> dict:
    lt = validate_list_type(list_type)
    key = f"courts:{lt}:{list_date.isoformat()}"
    payload, fetched_at, fresh = sources.cache_get(db, key, allow_stale=True)
    if not fresh:
        try:
            with translate_upstream():
                def fetch():
                    with sources.aphc_client().session(lt, list_date) as sess:
                        return sess.courts()

                options = circuit.call(circuit.HCDBS_CAUSE_LIST, fetch)
            payload = {"courts": [asdict(o) for o in options]}
            fetched_at = sources.cache_put(db, key, payload, get_settings().cause_list_cache_minutes * 60)
            fresh = True
        except AppError:
            if payload is None:
                raise
    # Attach case counts for courts we have already synced.
    synced = {
        cl.court_no: cl
        for cl in db.scalars(select(CauseList).where(CauseList.list_type == lt, CauseList.list_date == list_date))
    }
    courts = []
    for c in payload["courts"]:
        cl = synced.get(c["court_no"])
        courts.append(
            {
                "court_no": c["court_no"],
                "court_name": c["court_name"],
                "case_count": cl.item_count if cl and cl.status != "failed" else None,
                "bench": cl.bench if cl else None,
                "synced_at": as_utc(cl.fetched_at) if cl else None,
            }
        )
    return {"list_type": lt, "list_date": list_date, "courts": courts, "fetched_at": fetched_at, "stale": not fresh}


# ------------------------------------------------------------------ court listing
def _store(db: Session, lt: str, list_date: date, court_no: str, parsed: parsers.ParsedCauseList) -> CauseList:
    cl = db.scalar(
        select(CauseList)
        .where(CauseList.list_type == lt, CauseList.list_date == list_date, CauseList.court_no == court_no)
        .with_for_update()
    )
    if cl is None:
        cl = CauseList(list_type=lt, list_date=list_date, court_no=court_no)
        try:
            with db.begin_nested():
                db.add(cl)
                db.flush()
        except IntegrityError:
            cl = db.scalar(
                select(CauseList)
                .where(CauseList.list_type == lt, CauseList.list_date == list_date, CauseList.court_no == court_no)
                .with_for_update()
            )
    new_hash = parsed.content_hash()
    cl.bench = parsed.bench
    cl.headings = parsed.headings
    cl.fetched_at = utcnow()
    cl.error = None
    cl.status = "synced" if parsed.items else "empty"
    if cl.content_hash == new_hash and cl.item_count == len(parsed.items):
        return cl
    db.execute(delete(CauseListItem).where(CauseListItem.cause_list_id == cl.id))
    for it in parsed.items:
        case_id = None
        try:
            case_id = get_or_create_case(db, CaseIdentity.parse_slash(it.case_display)).id
        except InvalidCaseIdentity:
            logger.info("cause list row without parseable case number kept as display-only")
        db.add(
            CauseListItem(
                cause_list_id=cl.id,
                sequence=it.sequence,
                item_no=it.item_no,
                list_section=it.list_section,
                stage=it.stage,
                case_id=case_id,
                case_display=it.case_display[:64],
                applications=[asdict(a) for a in it.applications],
                petitioner=it.petitioner,
                respondent=it.respondent,
                petitioner_advocates=it.petitioner_advocates,
                respondent_advocates=it.respondent_advocates,
                district=it.district,
                remarks=it.remarks,
            )
        )
    cl.content_hash = new_hash
    cl.item_count = len(parsed.items)
    court = db.get(Court, court_no)
    if court is None:
        db.add(Court(court_no=court_no, coram=parsed.bench))
    elif parsed.bench:
        court.coram = parsed.bench
    db.flush()
    return cl


def sync_court(db: Session, list_type: str, list_date: date, court_no: str, session=None) -> CauseList:
    lt = validate_list_type(list_type)

    def fetch():
        if session is not None:
            return session.court_list(court_no)
        with sources.aphc_client().session(lt, list_date) as sess:
            return sess.court_list(court_no)

    with translate_upstream():
        parsed = circuit.call(circuit.HCDBS_CAUSE_LIST, fetch)
    return _store(db, lt, list_date, court_no, parsed)


def get_court_listing(db: Session, list_type: str, list_date: date, court_no: str, refresh: bool = False) -> dict:
    lt = validate_list_type(list_type)
    if not court_no.isdigit():
        raise AppError("court_no must be numeric", status_code=422)
    cl = db.scalar(
        select(CauseList).where(CauseList.list_type == lt, CauseList.list_date == list_date, CauseList.court_no == court_no)
    )
    ttl = timedelta(minutes=get_settings().cause_list_cache_minutes)
    age = utcnow() - as_utc(cl.fetched_at) if cl else None
    needs = cl is None or age > ttl or (refresh and age > MIN_FORCED_REFRESH)
    stale = False
    if needs:
        try:
            cl = sync_court(db, lt, list_date, court_no)
        except AppError:
            if cl is None:
                raise
            stale = True
    return serialize_cause_list(cl, stale=stale)


def serialize_item(it: CauseListItem) -> dict:
    return {
        "sequence": it.sequence,
        "item_no": it.item_no,
        "case_id": str(it.case_id) if it.case_id else None,
        "case_number": it.case_display,
        "applications": it.applications or [],
        "petitioner": it.petitioner,
        "respondent": it.respondent,
        "petitioner_advocates": it.petitioner_advocates or [],
        "respondent_advocates": it.respondent_advocates or [],
        "district": it.district,
        "list_section": it.list_section,
        "stage": it.stage,
        "remarks": it.remarks,
    }


def serialize_cause_list(cl: CauseList, *, stale: bool = False) -> dict:
    return {
        "list_type": cl.list_type,
        "list_date": cl.list_date,
        "court_no": cl.court_no,
        "bench": cl.bench,
        "headings": cl.headings or [],
        "status": cl.status,
        "total_cases": cl.item_count,
        "fetched_at": as_utc(cl.fetched_at),
        "stale": stale,
        "source": "aphc.gov.in/Hcdbs (court-wise cause list)",
        "items": [serialize_item(i) for i in cl.items],
    }


def sync_all_courts(db_factory, list_type: str, list_date: date) -> dict:
    """Background sync of every court for one list (one upstream session, throttled)."""
    lt = validate_list_type(list_type)
    ok, failed = 0, []
    client = sources.aphc_client()
    with client.session(lt, list_date) as sess:
        options = circuit.call(circuit.HCDBS_CAUSE_LIST, sess.courts)
        for opt in options:
            try:
                with db_factory() as db:
                    sync_court(db, lt, list_date, opt.court_no, session=sess)
                ok += 1
            except AppError as e:
                failed.append({"court_no": opt.court_no, "error": e.code})
                if e.code in ("source_paused",):
                    break
    return {"list_type": lt, "list_date": list_date.isoformat(), "synced": ok, "failed": failed}
