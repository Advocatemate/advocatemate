"""Advocate lookup and advocate-wise ("My") cause list via the Lexika chatbot."""

from __future__ import annotations

from datetime import date, timedelta

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import AppError, NotFound
from app.db.base import as_utc, utcnow
from app.models import Advocate, AdvocateCaseLink, CauseList, CauseListItem
from app.services import circuit, sources
from app.services.cases import get_or_create_case
from app.services.upstream_errors import translate_upstream

SOURCE = "aphc_lexika_chatbot"


def validate_code(code: str) -> str:
    code = (code or "").strip()
    if not code.isdigit() or not 1 <= len(code) <= 8:
        raise AppError("Advocate code must be numeric", code="invalid_advocate_code", status_code=422)
    return code


def lookup(db: Session, code: str, *, force: bool = False) -> tuple[Advocate, list[date]]:
    """Return the advocate (cached) plus the cause-list dates Lexika currently offers."""
    code = validate_code(code)
    adv = db.get(Advocate, code)
    key = f"advocate_dates:{code}"
    cached, _, fresh = sources.cache_get(db, key)
    ttl = timedelta(hours=get_settings().advocate_lookup_cache_hours)
    if adv and cached and fresh and not force and utcnow() - as_utc(adv.fetched_at) < ttl:
        return adv, [date.fromisoformat(d) for d in cached["dates"]]
    with translate_upstream():
        result = circuit.call(circuit.LEXIKA, lambda: sources.lexika_client().advocate_lookup(code))
    adv = upsert_advocate(db, code, result.name)
    sources.cache_put(db, key, {"dates": [d.isoformat() for d in result.available_dates]}, 30 * 60)
    return adv, result.available_dates


def upsert_advocate(db: Session, code: str, name: str) -> Advocate:
    adv = db.get(Advocate, code)
    if adv is None:
        adv = Advocate(advocate_code=code, name=name, source=SOURCE, fetched_at=utcnow())
        try:
            with db.begin_nested():
                db.add(adv)
                db.flush()
        except IntegrityError:
            adv = db.get(Advocate, code)
    else:
        adv.name = name
        adv.fetched_at = utcnow()
    return adv


def advocate_cause_list(db: Session, code: str, list_date: date, *, refresh: bool = False) -> dict:
    code = validate_code(code)
    key = f"advocate_list:{code}:{list_date.isoformat()}"
    payload, fetched_at, fresh = sources.cache_get(db, key, allow_stale=True)
    stale = False
    if payload is None or not fresh or refresh:
        try:
            payload, fetched_at = _fetch_and_store(db, code, list_date)
        except AppError:
            if payload is None:
                raise
            stale = True
    adv = db.get(Advocate, code)
    return _render(db, code, adv.name if adv else None, list_date, payload, fetched_at, stale)


def _fetch_and_store(db: Session, code: str, list_date: date):
    with translate_upstream():
        lookup_result, rows = circuit.call(
            circuit.LEXIKA, lambda: sources.lexika_client().advocate_cause_list(code, list_date)
        )
    upsert_advocate(db, code, lookup_result.name)
    stored = []
    for r in rows:
        entry = {
            "item_no": r.item_no,
            "court_no": r.court_no,
            "list_type": r.list_type,
            "raw_case": r.raw_case,
            "case_number": r.matter.main_case.slash if r.matter else None,
            "application": r.matter.application.slash if r.matter and r.matter.application else None,
            "application_description": r.matter.application_description if r.matter else None,
        }
        if r.matter:
            case = get_or_create_case(db, r.matter.main_case)
            entry["case_id"] = str(case.id)
            app_key = entry["application"] or ""
            exists = db.scalar(
                select(AdvocateCaseLink.id).where(
                    AdvocateCaseLink.advocate_code == code,
                    AdvocateCaseLink.case_id == case.id,
                    AdvocateCaseLink.list_date == list_date,
                    AdvocateCaseLink.court_no == r.court_no,
                    AdvocateCaseLink.item_no == r.item_no,
                    AdvocateCaseLink.application_key == app_key,
                )
            )
            if not exists:
                db.add(
                    AdvocateCaseLink(
                        advocate_code=code,
                        case_id=case.id,
                        list_date=list_date,
                        court_no=r.court_no,
                        item_no=r.item_no,
                        list_type=r.list_type,
                        application_key=app_key,
                        application_description=entry["application_description"],
                        source=SOURCE,
                    )
                )
        stored.append(entry)
    payload = {
        "available_dates": [d.isoformat() for d in lookup_result.available_dates],
        "date_offered": list_date in lookup_result.available_dates,
        "rows": stored,
    }
    fetched_at = sources.cache_put(db, f"advocate_list:{code}:{list_date.isoformat()}", payload,
                                   get_settings().cause_list_cache_minutes * 60)
    db.flush()
    return payload, fetched_at


_LIST_TYPE_CODE = {"daily": "D", "weekly": "W", "supplementary": "S"}


def _render(db: Session, code: str, name: str | None, list_date: date, payload: dict, fetched_at, stale: bool):
    """Group rows by court and enrich with party names from synced court lists (same source date)."""
    courts: dict[str, list[dict]] = {}
    for row in payload["rows"]:
        item = dict(row)
        item.update({"petitioner": None, "respondent": None, "petitioner_advocates": [], "respondent_advocates": []})
        lt = _LIST_TYPE_CODE.get((row.get("list_type") or "").lower())
        if row.get("case_id") and lt:
            match = db.execute(
                select(CauseListItem)
                .join(CauseList, CauseList.id == CauseListItem.cause_list_id)
                .where(
                    CauseList.list_type == lt,
                    CauseList.list_date == list_date,
                    CauseList.court_no == row["court_no"],
                    CauseListItem.item_no == row["item_no"],
                    CauseListItem.case_display == row["case_number"],
                )
            ).scalars().first()
            if match:
                item.update(
                    petitioner=match.petitioner,
                    respondent=match.respondent,
                    petitioner_advocates=match.petitioner_advocates or [],
                    respondent_advocates=match.respondent_advocates or [],
                    district=match.district,
                    stage=match.stage,
                )
        courts.setdefault(row["court_no"], []).append(item)

    def court_key(c: str):
        return (0, int(c)) if c.isdigit() else (1, c)

    groups = [{"court_no": c, "cases": courts[c]} for c in sorted(courts, key=court_key)]
    return {
        "advocate_code": code,
        "advocate_name": name,
        "list_date": list_date,
        "date_offered_by_source": payload.get("date_offered", True),
        "available_dates": payload.get("available_dates", []),
        "total_cases": sum(len(g["cases"]) for g in groups),
        "courts": groups,
        "fetched_at": fetched_at,
        "stale": stale,
        "source": "aphc.gov.in Lexika chatbot - Advocate Code Wise Search",
        "association_note": "Cases are listed because the APHC source returned them for this advocate code.",
    }


def get_profile(db: Session, code: str) -> dict:
    adv = db.get(Advocate, validate_code(code))
    if adv is None:
        adv, _ = lookup(db, code)
    if adv is None:
        raise NotFound("Advocate not found")
    return {
        "advocate_code": adv.advocate_code,
        "name": adv.name,
        "source": adv.source,
        "fetched_at": as_utc(adv.fetched_at),
    }
