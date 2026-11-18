"""Case search over data AdvocateMate has retrieved from APHC sources.

Search runs against PostgreSQL (synced cause lists + enriched case cache). It
does not query APHC per keystroke. An exact case number not yet known locally
can still be opened via /case-details, which triggers retrieval.
"""

from __future__ import annotations

import uuid

from sqlalchemy import String, cast, func, or_, select
from sqlalchemy.orm import Session

from app.core.errors import AppError
from app.models import Case, CauseList, CauseListItem, LexikaCaseStatusCache, SearchHistory
from app.utils.case_identity import CaseIdentity, InvalidCaseIdentity


def _like(term: str) -> str:
    escaped = term.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_")
    return f"%{escaped}%"


def search_cases(db: Session, *, user_id: uuid.UUID | None, q: str | None = None, case_type: str | None = None,
                 case_number: str | None = None, case_year: int | None = None, party: str | None = None,
                 advocate: str | None = None, limit: int = 25, offset: int = 0) -> dict:
    q = (q or "").strip()
    if not any([q, case_type, case_number, case_year, party, advocate]):
        raise AppError("Provide a search term or at least one filter", code="empty_search", status_code=422)
    if q and len(q) < 3:
        raise AppError("Search term must be at least 3 characters", code="search_too_short", status_code=422)

    exact: CaseIdentity | None = None
    if q:
        try:
            exact = CaseIdentity.parse(q)
        except InvalidCaseIdentity:
            exact = None

    stmt = select(Case).outerjoin(LexikaCaseStatusCache, LexikaCaseStatusCache.case_id == Case.id)
    conds = []
    if exact:
        conds.append(Case.canonical_key == exact.canonical)
    if case_type:
        conds.append(Case.case_type == case_type.strip().upper())
    if case_number:
        conds.append(Case.case_number == case_number.strip())
    if case_year:
        conds.append(Case.case_year == case_year)

    text_terms = []
    if q and not exact:
        text_terms.append(("any", q))
    if party:
        text_terms.append(("party", party.strip()))
    if advocate:
        text_terms.append(("advocate", advocate.strip()))
    for kind, term in text_terms:
        like = _like(term)
        item_match = select(CauseListItem.case_id).where(CauseListItem.case_id.is_not(None))
        cache_cols = []
        if kind in ("any", "party"):
            item_match = item_match.where(or_(CauseListItem.petitioner.ilike(like, escape="\\"),
                                              CauseListItem.respondent.ilike(like, escape="\\"),
                                              *( [CauseListItem.case_display.ilike(like, escape="\\")] if kind == "any" else [])))
            cache_cols += [LexikaCaseStatusCache.petitioner, LexikaCaseStatusCache.respondent]
        if kind == "advocate" or kind == "any":
            adv_item = select(CauseListItem.case_id).where(
                or_(cast(CauseListItem.petitioner_advocates, String).ilike(like, escape="\\"),
                    cast(CauseListItem.respondent_advocates, String).ilike(like, escape="\\")))
            item_match = item_match.union(adv_item) if kind == "any" else adv_item
            cache_cols += [LexikaCaseStatusCache.petitioner_advocate, LexikaCaseStatusCache.respondent_advocate]
        conds.append(or_(Case.id.in_(item_match), *[c.ilike(like, escape="\\") for c in cache_cols]))

    stmt = stmt.where(*conds)
    total = db.scalar(select(func.count()).select_from(stmt.subquery()))
    cases = db.scalars(stmt.order_by(Case.case_year.desc(), Case.case_type, Case.case_number)
                       .limit(min(limit, 100)).offset(offset)).all()

    results = []
    for c in cases:
        cache = db.scalar(select(LexikaCaseStatusCache).where(LexikaCaseStatusCache.case_id == c.id))
        latest = db.execute(select(CauseListItem, CauseList).join(CauseList)
                            .where(CauseListItem.case_id == c.id).order_by(CauseList.list_date.desc()).limit(1)).first()
        item, cl = (latest if latest else (None, None))
        results.append({
            "case_id": str(c.id),
            "case_number": c.canonical_key,
            "petitioner": (cache.petitioner if cache and cache.petitioner else item.petitioner if item else None),
            "respondent": (cache.respondent if cache and cache.respondent else item.respondent if item else None),
            "status": cache.status if cache else None,
            "last_listed": {"list_date": cl.list_date, "court_no": cl.court_no, "item_no": item.item_no} if cl else None,
        })

    if user_id and (q or party or advocate):
        db.add(SearchHistory(user_id=user_id, query=(q or party or advocate)[:120],
                             filters={k: v for k, v in {"case_type": case_type, "case_number": case_number,
                                                        "case_year": case_year, "party": party,
                                                        "advocate": advocate}.items() if v}))
    return {
        "total": total,
        "results": results,
        "exact_case_number": exact.slash if exact else None,
        "exact_case_known": bool(exact and total),
        "hint": None if not exact or total else "Not found in saved data - open it to fetch details from APHC.",
    }


def history(db: Session, user_id: uuid.UUID, limit: int = 20) -> list[dict]:
    rows = db.scalars(select(SearchHistory).where(SearchHistory.user_id == user_id)
                      .order_by(SearchHistory.created_at.desc()).limit(limit))
    out, seen = [], set()
    for r in rows:
        if r.query in seen:
            continue
        seen.add(r.query)
        out.append({"query": r.query, "filters": r.filters, "created_at": r.created_at})
    return out


def suggestions(db: Session, prefix: str, limit: int = 8) -> list[str]:
    prefix = prefix.strip().upper()
    if len(prefix) < 2:
        return []
    return list(db.scalars(select(Case.canonical_key).where(Case.canonical_key.like(f"{prefix.replace('%', '')}%"))
                           .order_by(Case.canonical_key).limit(limit)))
