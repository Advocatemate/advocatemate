"""Favourites, devices and notifications - always scoped to the authenticated user."""

from __future__ import annotations

import uuid
from datetime import date

from fastapi import APIRouter, Depends, Query
from sqlalchemy import func, select, update
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.api.deps import CurrentUser, get_current_user
from app.core.errors import AppError, Conflict, NotFound
from app.db.base import utcnow
from app.db.session import get_db
from app.models import (
    Advocate,
    Case,
    DeviceToken,
    FavouriteAdvocate,
    FavouriteCase,
    LexikaCaseStatusCache,
    Notification,
    NotificationPreference,
)
from app.schemas import (
    DeviceIn,
    DeviceOut,
    FavouriteAdvocateIn,
    FavouriteAdvocateOut,
    FavouriteCaseIn,
    FavouriteCaseOut,
    MarkReadIn,
    NotificationPage,
    PreferencesIO,
)
from app.services import advocates
from app.services.cases import get_case_or_404, get_or_create_case, parse_identity_or_400

router = APIRouter()


# ------------------------------------------------------------------ favourites: advocates
def _fav_adv_out(db: Session, f: FavouriteAdvocate) -> dict:
    adv = db.get(Advocate, f.advocate_code)
    return {"id": str(f.id), "advocate_code": f.advocate_code, "advocate_name": adv.name if adv else None,
            "label": f.label, "created_at": f.created_at}


@router.get("/favourites/advocates", tags=["favourites"], response_model=list[FavouriteAdvocateOut])
def list_fav_advocates(current: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)):
    rows = db.scalars(select(FavouriteAdvocate).where(FavouriteAdvocate.user_id == current.id)
                      .order_by(FavouriteAdvocate.created_at.desc()))
    return [_fav_adv_out(db, f) for f in rows]


@router.post("/favourites/advocates", tags=["favourites"], response_model=FavouriteAdvocateOut, status_code=201)
def add_fav_advocate(body: FavouriteAdvocateIn, current: CurrentUser = Depends(get_current_user),
                     db: Session = Depends(get_db)):
    if db.scalar(select(func.count()).select_from(FavouriteAdvocate).where(FavouriteAdvocate.user_id == current.id)) >= 100:
        raise AppError("Favourite advocate limit reached (100)", code="limit_reached")
    advocates.lookup(db, body.advocate_code)  # must exist in the source
    fav = FavouriteAdvocate(user_id=current.id, advocate_code=body.advocate_code, label=body.label)
    try:
        with db.begin_nested():
            db.add(fav)
            db.flush()
    except IntegrityError as e:
        raise Conflict("Advocate is already in favourites", code="already_favourite") from e
    return _fav_adv_out(db, fav)


@router.delete("/favourites/advocates/{fav_id}", tags=["favourites"], status_code=204)
def delete_fav_advocate(fav_id: uuid.UUID, current: CurrentUser = Depends(get_current_user),
                        db: Session = Depends(get_db)):
    fav = db.get(FavouriteAdvocate, fav_id)
    if fav is None or fav.user_id != current.id:
        raise NotFound("Favourite not found")
    db.delete(fav)


@router.post("/favourites/advocates/{fav_id}/refresh-cause-list", tags=["favourites"])
def refresh_fav_advocate(fav_id: uuid.UUID, list_date: date | None = Query(None, alias="date"),
                         current: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)):
    fav = db.get(FavouriteAdvocate, fav_id)
    if fav is None or fav.user_id != current.id:
        raise NotFound("Favourite not found")
    from app.api.v1.court_data import _today

    return advocates.advocate_cause_list(db, fav.advocate_code, list_date or _today(), refresh=True)


# ------------------------------------------------------------------ favourites: cases
def _fav_case_out(db: Session, f: FavouriteCase) -> dict:
    case = db.get(Case, f.case_id)
    cache = db.scalar(select(LexikaCaseStatusCache).where(LexikaCaseStatusCache.case_id == f.case_id))
    return {"id": str(f.id), "case_id": str(f.case_id), "case_number": case.canonical_key, "note": f.note,
            "petitioner": cache.petitioner if cache else None, "respondent": cache.respondent if cache else None,
            "created_at": f.created_at}


@router.get("/favourites/cases", tags=["favourites"], response_model=list[FavouriteCaseOut])
def list_fav_cases(current: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)):
    rows = db.scalars(select(FavouriteCase).where(FavouriteCase.user_id == current.id)
                      .order_by(FavouriteCase.created_at.desc()))
    return [_fav_case_out(db, f) for f in rows]


@router.post("/favourites/cases", tags=["favourites"], response_model=FavouriteCaseOut, status_code=201)
def add_fav_case(body: FavouriteCaseIn, current: CurrentUser = Depends(get_current_user),
                 db: Session = Depends(get_db)):
    if body.case_id:
        try:
            case = get_case_or_404(db, uuid.UUID(body.case_id))
        except ValueError as e:
            raise AppError("Invalid case_id", status_code=422) from e
    elif body.case_number:
        case = get_or_create_case(db, parse_identity_or_400(body.case_number))
    else:
        raise AppError("Provide case_number or case_id", status_code=422)
    if db.scalar(select(func.count()).select_from(FavouriteCase).where(FavouriteCase.user_id == current.id)) >= 500:
        raise AppError("Favourite case limit reached (500)", code="limit_reached")
    fav = FavouriteCase(user_id=current.id, case_id=case.id, note=body.note)
    try:
        with db.begin_nested():
            db.add(fav)
            db.flush()
    except IntegrityError as e:
        raise Conflict("Case is already in favourites", code="already_favourite") from e
    return _fav_case_out(db, fav)


@router.delete("/favourites/cases/{fav_id}", tags=["favourites"], status_code=204)
def delete_fav_case(fav_id: uuid.UUID, current: CurrentUser = Depends(get_current_user),
                    db: Session = Depends(get_db)):
    fav = db.get(FavouriteCase, fav_id)
    if fav is None or fav.user_id != current.id:
        raise NotFound("Favourite not found")
    db.delete(fav)


# ------------------------------------------------------------------ devices
@router.post("/devices", tags=["notifications"], response_model=DeviceOut, status_code=201)
def register_device(body: DeviceIn, current: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)):
    dev = db.scalar(select(DeviceToken).where(DeviceToken.token == body.token))
    if dev is None:
        dev = DeviceToken(user_id=current.id, token=body.token, platform=body.platform)
        db.add(dev)
    dev.user_id = current.id  # a token moves with the device's current login
    dev.platform, dev.app_version, dev.locale = body.platform, body.app_version, body.locale
    dev.last_seen_at, dev.revoked_at = utcnow(), None
    db.flush()
    return {"id": str(dev.id), "platform": dev.platform, "created_at": dev.created_at}


@router.delete("/devices/{device_id}", tags=["notifications"], status_code=204)
def unregister_device(device_id: uuid.UUID, current: CurrentUser = Depends(get_current_user),
                      db: Session = Depends(get_db)):
    dev = db.get(DeviceToken, device_id)
    if dev is None or dev.user_id != current.id:
        raise NotFound("Device not found")
    dev.revoked_at = utcnow()


# ------------------------------------------------------------------ notifications
@router.get("/notifications", tags=["notifications"], response_model=NotificationPage)
def list_notifications(unread_only: bool = False, limit: int = Query(50, ge=1, le=200), offset: int = Query(0, ge=0),
                       current: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)):
    base = select(Notification).where(Notification.user_id == current.id)
    if unread_only:
        base = base.where(Notification.read_at.is_(None))
    total = db.scalar(select(func.count()).select_from(base.subquery()))
    unread = db.scalar(select(func.count()).select_from(Notification)
                       .where(Notification.user_id == current.id, Notification.read_at.is_(None)))
    items = db.scalars(base.order_by(Notification.created_at.desc()).limit(limit).offset(offset))
    return {"total": total, "unread_count": unread, "items": [
        {"id": str(n.id), "category": n.category, "title": n.title, "body": n.body, "deep_link": n.deep_link,
         "data": n.data or {}, "read": n.read_at is not None, "created_at": n.created_at} for n in items]}


@router.post("/notifications/read", tags=["notifications"], status_code=204)
def mark_read(body: MarkReadIn, current: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)):
    stmt = update(Notification).where(Notification.user_id == current.id, Notification.read_at.is_(None))
    if not body.all:
        try:
            ids = [uuid.UUID(i) for i in body.ids]
        except ValueError as e:
            raise AppError("Invalid notification id", status_code=422) from e
        if not ids:
            return
        stmt = stmt.where(Notification.id.in_(ids))
    db.execute(stmt.values(read_at=utcnow()))


@router.get("/notifications/preferences", tags=["notifications"], response_model=PreferencesIO)
def get_prefs(current: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)):
    p = db.get(NotificationPreference, current.id) or NotificationPreference(user_id=current.id)
    return {k: bool(getattr(p, k) if getattr(p, k) is not None else True) for k in PreferencesIO.model_fields}


@router.put("/notifications/preferences", tags=["notifications"], response_model=PreferencesIO)
def put_prefs(body: PreferencesIO, current: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)):
    p = db.get(NotificationPreference, current.id)
    if p is None:
        p = NotificationPreference(user_id=current.id)
        db.add(p)
    for k, v in body.model_dump().items():
        setattr(p, k, v)
    db.flush()
    return body
