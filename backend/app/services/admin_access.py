"""Admin portal access: authorised admin accounts, Google sign-in and server-side sessions.

Admins are independent of advocates and of the advocate registry. Only Google accounts listed (and
active) in ``admin_accounts`` can sign in; there is no self-registration. The Google ID token is verified
on the server by the same verifier the app uses (signature, issuer, expiry, audience, verified email).
"""

from __future__ import annotations

import hashlib
import hmac
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


NOT_VERIFIED = "Google sign-in could not be verified. Please try again."


def _nonce_matches(identity: google_identity.GoogleIdentity, expected: str | None = None,
                   expected_sha256: str | None = None) -> bool:
    """No expectation: the server-rendered portal (Google's double-submit cookie protects it).

    ``expected`` is the raw nonce (web Admin App cookie); ``expected_sha256`` the stored hash of a one-time
    challenge (phone app).
    """
    if expected is None and expected_sha256 is None:
        return True
    if not identity.nonce:
        return False
    if expected is not None:
        return hmac.compare_digest(identity.nonce, expected)
    return hmac.compare_digest(_hash_token(identity.nonce), expected_sha256 or "")


def verify_google_sign_in(db: Session, id_token: str, *, ip: str | None, audiences: list[str] | None = None,
                          expected_nonce: str | None = None,
                          expected_nonce_sha256: str | None = None) -> google_identity.GoogleIdentity:
    """Step 1 of every admin sign-in: Google's checks (signature, issuer, expiry, audience, verified email) and the
    nonce. Refusals are audited and committed before the error is raised."""
    try:
        identity = google_identity.verify_id_token(id_token, audiences=audiences)
    except Exception as e:  # noqa: BLE001 - every verifier failure is a refusal
        audit.record(db, "admin_login_denied", ip=ip, reason=getattr(e, "code", "google_token_invalid"))
        db.commit()
        raise AdminAccessError("google_token_invalid", NOT_VERIFIED) from e
    if not _nonce_matches(identity, expected_nonce, expected_nonce_sha256):
        audit.record(db, "admin_login_denied", ip=ip, reason="nonce_mismatch")
        db.commit()
        raise AdminAccessError("google_token_invalid", NOT_VERIFIED)
    return identity


def authorise_identity(db: Session, identity: google_identity.GoogleIdentity, *, ip: str | None) -> AdminAccount:
    """Step 2: the verified Google account must be an active admin (bound to this Google account after first use)."""
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
    acct.last_login_at = utcnow()
    return acct


def sign_in(db: Session, id_token: str, *, ip: str | None, user_agent: str | None,
            expected_nonce: str | None = None) -> NewSession:
    """Verify the Google ID token on the server and open a browser session for an authorised, active admin.

    ``expected_nonce``: the admin web app passes the nonce it issued to this browser; the token must carry it.
    """
    identity = verify_google_sign_in(db, id_token, ip=ip, expected_nonce=expected_nonce)
    acct = authorise_identity(db, identity, ip=ip)
    now = utcnow()
    token = secrets.token_urlsafe(32)
    s = get_settings()
    sess = AdminSession(admin_account_id=acct.id, token_hash=_hash_token(token), csrf_token=secrets.token_urlsafe(32),
                        created_at=now, last_seen_at=now, reauth_at=now,
                        expires_at=now + timedelta(hours=s.admin_session_max_hours),
                        ip_hash=hash_ip(ip), user_agent=(user_agent or "")[:255] or None, client="browser")
    db.add(sess)
    db.flush()
    audit.record(db, "admin_login", actor_admin=acct.id, target_type="admin_account", target_id=str(acct.id), ip=ip)
    return NewSession(token=token, session=sess, account=acct)


def reauthenticate(db: Session, sess: AdminSession, acct: AdminAccount, id_token: str, *, ip: str | None,
                   expected_nonce: str | None = None, expected_nonce_sha256: str | None = None,
                   audiences: list[str] | None = None) -> None:
    """Fresh Google sign-in by the same admin, required before sensitive actions."""
    try:
        identity = google_identity.verify_id_token(id_token, audiences=audiences)
    except Exception as e:  # noqa: BLE001
        raise AdminAccessError("google_token_invalid", NOT_VERIFIED) from e
    if not _nonce_matches(identity, expected_nonce, expected_nonce_sha256):
        audit.record(db, "admin_reauth_denied", actor_admin=acct.id, ip=ip, reason="nonce_mismatch")
        raise AdminAccessError("google_token_invalid", NOT_VERIFIED)
    if identity.sub != acct.google_sub:
        audit.record(db, "admin_reauth_denied", actor_admin=acct.id, ip=ip, reason="different_account")
        raise AdminAccessError("different_account", "Please confirm with the same Google account you signed in with.")
    sess.reauth_at = utcnow()
    audit.record(db, "admin_reauth", actor_admin=acct.id, ip=ip)


def check_live(db: Session, sess: AdminSession) -> AdminAccount | None:
    """The session's admin when the session may still be used (idle and absolute limits, active account);
    otherwise None, after recording why it ended. Counts this request as activity."""
    if sess.revoked_at is not None:
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
    return acct


def load_session(db: Session, token: str | None) -> tuple[AdminSession, AdminAccount] | None:
    """Return the live browser session for a cookie token, enforcing idle (30 min) and absolute (8 h) expiry.

    Phone-app sessions are never accepted here (their tokens only work as bearer tokens on /admin-mobile).
    """
    if not token or len(token) > 128:
        return None
    sess = db.scalar(select(AdminSession).where(AdminSession.token_hash == _hash_token(token),
                                                AdminSession.client != "mobile"))
    if sess is None:
        return None
    acct = check_live(db, sess)
    return (sess, acct) if acct is not None else None


def reauth_fresh(sess: AdminSession, now: datetime | None = None) -> bool:
    window = timedelta(minutes=get_settings().admin_reauth_minutes)
    return (now or utcnow()) - as_utc(sess.reauth_at) <= window


def revoke(sess: AdminSession, reason: str) -> None:
    """End one session (any client); its refresh tokens stop working with it."""
    _revoke(sess, reason)


def _revoke(sess: AdminSession, reason: str) -> None:
    if sess.revoked_at is None:
        sess.revoked_at = utcnow()
        sess.revoke_reason = reason


def sign_out(db: Session, sess: AdminSession, acct: AdminAccount, *, ip: str | None) -> None:
    _revoke(sess, "signed_out")
    audit.record(db, "admin_logout", actor_admin=acct.id, ip=ip)


def list_live_sessions(db: Session, admin_id: uuid.UUID) -> list[AdminSession]:
    """Sessions of one admin that are neither revoked nor past their absolute expiry, newest first."""
    rows = db.scalars(select(AdminSession).where(AdminSession.admin_account_id == admin_id,
                                                 AdminSession.revoked_at.is_(None))
                      .order_by(AdminSession.created_at.desc()))
    now = utcnow()
    return [r for r in rows if as_utc(r.expires_at) > now]


def revoke_session(db: Session, target: AdminSession, acct: AdminAccount, *, ip: str | None) -> None:
    """An admin ends one of their own sessions (for example a forgotten browser)."""
    if target.admin_account_id != acct.id:
        raise AdminAccessError("not_found", "That session does not exist.")
    _revoke(target, "revoked_by_admin")
    audit.record(db, "admin_session_revoked", actor_admin=acct.id, target_type="admin_session",
                 target_id=str(target.id), ip=ip)


def revoke_all(db: Session, admin_id: uuid.UUID, reason: str) -> None:
    db.execute(update(AdminSession).where(AdminSession.admin_account_id == admin_id,
                                          AdminSession.revoked_at.is_(None))
               .values(revoked_at=utcnow(), revoke_reason=reason))
