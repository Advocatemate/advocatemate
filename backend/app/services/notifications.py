"""Notification history + push delivery.

History is always written to PostgreSQL. Push delivery uses Firebase Cloud
Messaging only when FCM_ENABLED=true and a service-account file is configured;
otherwise notifications are recorded with delivery_status="skipped".
"""

from __future__ import annotations

import logging
import uuid
from datetime import date

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.db.base import utcnow
from app.db.session import db_session
from app.models import (
    AdvocateProfile,
    Case,
    DeviceToken,
    FavouriteAdvocate,
    FavouriteCase,
    LexikaCaseStatusEnrichmentJob,
    Notification,
    NotificationPreference,
)

logger = logging.getLogger(__name__)

CATEGORY_PREF = {
    "cause_list_publication": "cause_list_publication",
    "favourite_advocate": "favourite_advocates",
    "case_update": "case_updates",
    "court_board": "court_board",
    "enrichment": "enrichment",
    "announcement": "announcements",
}


class PushSender:
    def __init__(self):
        self._app = None
        s = get_settings()
        self.enabled = bool(s.fcm_enabled and s.fcm_credentials_file)

    def _messaging(self):
        if self._app is None:
            import firebase_admin  # optional dependency (requirements-push.txt)
            from firebase_admin import credentials

            self._app = firebase_admin.initialize_app(credentials.Certificate(get_settings().fcm_credentials_file))
        from firebase_admin import messaging

        return messaging

    def send(self, tokens: list[str], title: str, body: str, data: dict[str, str]) -> tuple[int, list[str]]:
        """Returns (success_count, invalid_tokens)."""
        if not self.enabled or not tokens:
            return 0, []
        messaging = self._messaging()
        msg = messaging.MulticastMessage(
            tokens=tokens,
            notification=messaging.Notification(title=title, body=body),
            data=data,
            android=messaging.AndroidConfig(priority="high",
                                            notification=messaging.AndroidNotification(channel_id="advocatemate_updates")),
            apns=messaging.APNSConfig(payload=messaging.APNSPayload(aps=messaging.Aps(sound="default"))),
        )
        resp = messaging.send_each_for_multicast(msg)
        invalid = [
            tokens[i]
            for i, r in enumerate(resp.responses)
            if not r.success and type(r.exception).__name__ in ("UnregisteredError", "SenderIdMismatchError")
        ]
        return resp.success_count, invalid


_sender: PushSender | None = None


def sender() -> PushSender:
    global _sender
    if _sender is None:
        _sender = PushSender()
    return _sender


def _prefs(db: Session, user_id: uuid.UUID) -> NotificationPreference:
    p = db.get(NotificationPreference, user_id)
    if p is None:
        p = NotificationPreference(user_id=user_id)
        db.add(p)
        db.flush()
    return p


def notify(db: Session, user_id: uuid.UUID, *, category: str, title: str, body: str, dedupe_key: str,
           deep_link: str | None = None, data: dict | None = None) -> Notification | None:
    """Record (idempotently) and attempt delivery. Returns None if it was a duplicate."""
    n = Notification(user_id=user_id, category=category, title=title[:200], body=body, deep_link=deep_link,
                     data=data or {}, dedupe_key=dedupe_key[:160])
    try:
        with db.begin_nested():
            db.add(n)
            db.flush()
    except IntegrityError:
        return None
    pref_attr = CATEGORY_PREF.get(category)
    if pref_attr and not getattr(_prefs(db, user_id), pref_attr):
        n.delivery_status = "skipped"
        n.delivery_error = "preference_off"
        return n
    tokens = [t.token for t in db.scalars(
        select(DeviceToken).where(DeviceToken.user_id == user_id, DeviceToken.revoked_at.is_(None)))]
    if not sender().enabled:
        n.delivery_status, n.delivery_error = "skipped", "push_not_configured"
        return n
    if not tokens:
        n.delivery_status, n.delivery_error = "skipped", "no_device"
        return n
    try:
        payload = {"notification_id": str(n.id), "category": category, "deep_link": deep_link or ""}
        ok, invalid = sender().send(tokens, title, body, payload)
        for t in db.scalars(select(DeviceToken).where(DeviceToken.token.in_(invalid))):
            t.revoked_at = utcnow()
        n.delivery_status = "sent" if ok else "failed"
        n.delivery_error = None if ok else "no_successful_delivery"
    except Exception as e:  # noqa: BLE001
        logger.warning("push delivery failed: %s", type(e).__name__)
        n.delivery_status, n.delivery_error = "failed", type(e).__name__
    return n


# ----------------------------------------------------------------- triggers
def enrichment_finished(case_id: uuid.UUID, job_id: uuid.UUID, succeeded: bool) -> None:
    with db_session() as db:
        job = db.get(LexikaCaseStatusEnrichmentJob, job_id)
        case = db.get(Case, case_id)
        if not job or not case or not job.requested_by_user_id:
            return
        title = "Case details updated" if succeeded else "Case details could not be updated"
        body = (f"Latest details for {case.canonical_key} are now available."
                if succeeded else f"We could not retrieve details for {case.canonical_key}. Showing saved information.")
        notify(db, job.requested_by_user_id, category="enrichment", title=title, body=body,
               dedupe_key=f"enrich:{job_id}:{job.status}", deep_link=f"advocatemate://cases/{case_id}",
               data={"case_id": str(case_id)})


def publication_changes(db: Session, list_date: date, changes: list[tuple[str, str | None, str]]) -> int:
    """Tell users when any court's list for the date becomes UPLOADED (one message per date)."""
    if not any(new == "UPLOADED" and old != "UPLOADED" for _, old, new in changes):
        return 0
    count = 0
    for (user_id,) in db.execute(select(AdvocateProfile.user_id)):
        if notify(db, user_id, category="cause_list_publication",
                  title="Cause list published",
                  body=f"Cause lists for {list_date.strftime('%d-%m-%Y')} are being published by APHC.",
                  dedupe_key=f"publication:{list_date.isoformat()}",
                  deep_link=f"advocatemate://cause-list/daily?date={list_date.isoformat()}"):
            count += 1
    return count


def favourite_advocate_listed(db: Session, advocate_code: str, list_date: date, total: int) -> int:
    if total <= 0:
        return 0
    count = 0
    for fav in db.scalars(select(FavouriteAdvocate).where(FavouriteAdvocate.advocate_code == advocate_code)):
        if notify(db, fav.user_id, category="favourite_advocate",
                  title="Favourite advocate listed",
                  body=f"Advocate {advocate_code} has {total} listed matter(s) on {list_date.strftime('%d-%m-%Y')}.",
                  dedupe_key=f"favadv:{advocate_code}:{list_date.isoformat()}:{total}",
                  deep_link=f"advocatemate://cause-list/advocate/{advocate_code}?date={list_date.isoformat()}"):
            count += 1
    return count


def favourite_case_listed(db: Session, case_id: uuid.UUID, list_date: date, court_no: str, item_no: str) -> int:
    count = 0
    case = db.get(Case, case_id)
    for fav in db.scalars(select(FavouriteCase).where(FavouriteCase.case_id == case_id)):
        if notify(db, fav.user_id, category="case_update", title="Saved case listed",
                  body=f"{case.canonical_key} is listed in Court {court_no}, item {item_no} on "
                       f"{list_date.strftime('%d-%m-%Y')}.",
                  dedupe_key=f"favcase:{case_id}:{list_date.isoformat()}:{court_no}:{item_no}",
                  deep_link=f"advocatemate://cases/{case_id}"):
            count += 1
    return count
