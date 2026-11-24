"""Admin portal access: authorised admin accounts, Google sign-in and server-side sessions.

Admins are independent of advocates and of the advocate registry. Only Google accounts listed (and
active) in ``admin_accounts`` can sign in; there is no self-registration. The Google ID token is verified
on the server by the same verifier the app uses (signature, issuer, expiry, audience, verified email).
"""

from __future__ import annotations

import hashlib
import secrets
import uuid
from dataclasses import dataclass
from datetime import datetime, timedelta

from sqlalchemy import func, select, update
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.security import hash_ip
from app.db.base import as_utc, utcnow
from app.integrations import google_identity
from app.models import ADMIN_ROLES, AdminAccount, AdminSession
from app.services import audit


class AdminAccessError(Exception):
    """Sign-in or account-management refusal with a message that is safe to show."""

    def __init__(self, code: str, message: str):
        super().__init__(message)
        self.code = code
        self.message = message


DENIED = "This Google account is not authorised to use the AdvocateMate admin portal."


def _norm_email(email: str) -> str:
    return (email or "").strip().lower()


def _hash_token(token: str) -> str:
    return hashlib.sha256(token.encode()).hexdigest()


# ------------------------------------------------------------------ accounts
def get_by_email(db: Session, email: str) -> AdminAccount | None:
    return db.scalar(select(AdminAccount).where(AdminAccount.email == _norm_email(email)))


def list_accounts(db: Session) -> list[AdminAccount]:
    return list(db.scalars(select(AdminAccount).order_by(AdminAccount.is_active.desc(), AdminAccount.email)))


def _active_owners(db: Session) -> int:
    return db.scalar(select(func.count()).select_from(AdminAccount)
                     .where(AdminAccount.role == "owner", AdminAccount.is_active.is_(True))) or 0


def create_account(db: Session, email: str, role: str, *, by: AdminAccount | None = None, via: str = "portal",
                   display_name: str | None = None, ip: str | None = None) -> AdminAccount:
    email = _norm_email(email)
    if "@" not in email or len(email) > 320:
        raise AdminAccessError("invalid_email", "Enter a valid Google account email address.")
    if role not in ADMIN_ROLES:
        raise AdminAccessError("invalid_role", "Choose owner, admin or support.")
    if get_by_email(db, email) is not None:
        raise AdminAccessError("already_exists", "This email already has an admin account.")
    acct = AdminAccount(email=email, role=role, is_active=True, display_name=display_name,
                        added_by_admin_id=by.id if by else None, added_via=via)
    db.add(acct)
    db.flush()
    audit.record(db, "admin_account_created", actor_admin=by.id if by else None, target_type="admin_account",
                 target_id=str(acct.id), ip=ip, role=role, via=via)
    return acct


def set_role(db: Session, acct: AdminAccount, role: str, *, by: AdminAccount | None, ip: str | None = None) -> None:
    if role not in ADMIN_ROLES:
        raise AdminAccessError("invalid_role", "Choose owner, admin or support.")
    if acct.role == role:
        return
    if acct.role == "owner" and acct.is_active and _active_owners(db) <= 1:
        raise AdminAccessError("last_owner", "There must always be at least one active owner.")
    before = acct.role
    acct.role = role
    audit.record(db, "admin_role_changed", actor_admin=by.id if by else None, target_type="admin_account",
                 target_id=str(acct.id), ip=ip, before=before, after=role)


def set_active(db: Session, acct: AdminAccount, active: bool, *, by: AdminAccount | None,
               ip: str | None = None) -> None:
    if acct.is_active == active:
        return
    if not active and acct.role == "owner" and _active_owners(db) <= 1:
        raise AdminAccessError("last_owner", "There must always be at least one active owner.")
    if by is not None and by.id == acct.id and not active:
        raise AdminAccessError("self_deactivate", "You cannot deactivate your own admin account.")
    acct.is_active = active
    if not active:
        revoke_all(db, acct.id, "account_deactivated")
    audit.record(db, "admin_account_activated" if active else "admin_account_deactivated",
                 actor_admin=by.id if by else None, target_type="admin_account", target_id=str(acct.id), ip=ip)


# ------------------------------------------------------------------ sign-in and sessions
@dataclass
class NewSession:
    token: str  # raw value for the cookie; only its hash is stored
    session: AdminSession
    account: AdminAccount


def sign_in(db: Session, id_token: str, *, ip: str | None, user_agent: str | None) -> NewSession:
    """Verify the Google ID token on the server and open a session for an authorised, active admin."""
    try:
        identity = google_identity.verify_id_token(id_token)
    except Exception as e:  # noqa: BLE001 - every verifier failure is a refusal
        audit.record(db, "admin_login_denied", ip=ip, reason=getattr(e, "code", "google_token_invalid"))
        db.commit()
        raise AdminAccessError("google_token_invalid", "Google sign-in could not be verified. Please try again.") \
            from e
    acct = db.scalar(select(AdminAccount).where(AdminAccount.google_sub == identity.sub)) \
        or get_by_email(db, identity.email)
    if acct is None or not acct.is_active or (acct.google_sub and acct.google_sub != identity.sub) \
            or _norm_email(identity.email) != acct.email:
        audit.record(db, "admin_login_denied", ip=ip, reason="not_authorised" if acct is None or not acct.is_active
                     else "account_mismatch")
        db.commit()
        raise AdminAccessError("not_authorised", DENIED)
    if acct.google_sub is None:
        acct.google_sub = identity.sub  # bind the Google account at first sign-in
    if identity.name and not acct.display_name:
        acct.display_name = identity.name
    now = utcnow()
    acct.last_login_at = now
    token = secrets.token_urlsafe(32)
    s = get_settings()
    sess = AdminSession(admin_account_id=acct.id, token_hash=_hash_token(token), csrf_token=secrets.token_urlsafe(32),
                        created_at=now, last_seen_at=now, reauth_at=now,
                        expires_at=now + timedelta(hours=s.admin_session_max_hours),
                        ip_hash=hash_ip(ip), user_agent=(user_agent or "")[:255] or None)
    db.add(sess)
    db.flush()
    audit.record(db, "admin_login", actor_admin=acct.id, target_type="admin_account", target_id=str(acct.id), ip=ip)
    return NewSession(token=token, session=sess, account=acct)


def reauthenticate(db: Session, sess: AdminSession, acct: AdminAccount, id_token: str, *, ip: str | None) -> None:
    """Fresh Google sign-in by the same admin, required before sensitive actions."""
    try:
        identity = google_identity.verify_id_token(id_token)
    except Exception as e:  # noqa: BLE001
        raise AdminAccessError("google_token_invalid", "Google sign-in could not be verified. Please try again.") \
            from e
    if identity.sub != acct.google_sub:
        audit.record(db, "admin_reauth_denied", actor_admin=acct.id, ip=ip, reason="different_account")
        raise AdminAccessError("different_account", "Please confirm with the same Google account you signed in with.")
    sess.reauth_at = utcnow()
    audit.record(db, "admin_reauth", actor_admin=acct.id, ip=ip)


def load_session(db: Session, token: str | None) -> tuple[AdminSession, AdminAccount] | None:
    """Return the live session for a cookie token, enforcing idle (30 min) and absolute (8 h) expiry."""
    if not token or len(token) > 128:
        return None
    sess = db.scalar(select(AdminSession).where(AdminSession.token_hash == _hash_token(token)))
    if sess is None or sess.revoked_at is not None:
        return None
    now = utcnow()
    s = get_settings()
    if as_utc(sess.expires_at) <= now:
        _revoke(sess, "expired")
        return None
    if now - as_utc(sess.last_seen_at) > timedelta(minutes=s.admin_session_idle_minutes):
        _revoke(sess, "idle_timeout")
        return None
    acct = db.get(AdminAccount, sess.admin_account_id)
    if acct is None or not acct.is_active:
        _revoke(sess, "account_inactive")
        return None
    sess.last_seen_at = now
    return sess, acct


def reauth_fresh(sess: AdminSession, now: datetime | None = None) -> bool:
    window = timedelta(minutes=get_settings().admin_reauth_minutes)
    return (now or utcnow()) - as_utc(sess.reauth_at) <= window


def _revoke(sess: AdminSession, reason: str) -> None:
    if sess.revoked_at is None:
        sess.revoked_at = utcnow()
        sess.revoke_reason = reason


def sign_out(db: Session, sess: AdminSession, acct: AdminAccount, *, ip: str | None) -> None:
    _revoke(sess, "signed_out")
    audit.record(db, "admin_logout", actor_admin=acct.id, ip=ip)


def revoke_all(db: Session, admin_id: uuid.UUID, reason: str) -> None:
    db.execute(update(AdminSession).where(AdminSession.admin_account_id == admin_id,
                                          AdminSession.revoked_at.is_(None))
               .values(revoked_at=utcnow(), revoke_reason=reason))
