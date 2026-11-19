"""Sessions and tokens (shared by every sign-in method).

Sign-in itself is Google + automatic advocate-registry verification (services/google_auth.py).
The earlier advocate-code + mobile-OTP login is retired.

* Access token: JWT (HS256), short-lived, bound to a live session row.
* Refresh token: opaque, stored only as an HMAC, single-use (rotation). Re-using a spent token
  revokes the whole session.
* Every refresh - and every authenticated request (api/deps.py) - re-checks that the account is
  still linked and the advocate is still eligible in the registry.
"""

from __future__ import annotations

import uuid
from datetime import timedelta

from sqlalchemy import select, update
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import Unauthorized
from app.core.security import create_access_token, hash_token, new_refresh_token
from app.db.base import as_utc, utcnow
from app.models import AdvocateProfile, AuthSession, RefreshToken, User
from app.services import audit


def mask_phone(phone: str) -> str:
    return f"{phone[:3]}******{phone[-4:]}"


def issue_session(db: Session, user: User, *, device_label: str | None, user_agent: str | None) -> dict:
    session = AuthSession(user_id=user.id, device_label=(device_label or "")[:120] or None,
                          user_agent=(user_agent or "")[:255] or None)
    db.add(session)
    db.flush()
    return _issue_tokens(db, user, session)


def _issue_tokens(db: Session, user: User, session: AuthSession) -> dict:
    access, ttl = create_access_token(user_id=user.id, session_id=session.id, role=user.role)
    refresh_value = new_refresh_token()
    db.add(RefreshToken(session_id=session.id, token_hash=hash_token(refresh_value),
                        expires_at=utcnow() + timedelta(days=get_settings().refresh_token_ttl_days)))
    db.flush()
    return {"access_token": access, "token_type": "bearer", "expires_in": ttl, "refresh_token": refresh_value,
            "session_id": str(session.id)}


def revoke_session(db: Session, session_id: uuid.UUID, reason: str) -> None:
    session = db.get(AuthSession, session_id)
    if session and session.revoked_at is None:
        session.revoked_at = utcnow()
        session.revoke_reason = reason[:64]
        db.execute(update(RefreshToken).where(RefreshToken.session_id == session_id, RefreshToken.revoked_at.is_(None))
                   .values(revoked_at=utcnow()))


def revoke_all_sessions(db: Session, user_id: uuid.UUID, reason: str) -> None:
    for (sid,) in db.execute(select(AuthSession.id).where(AuthSession.user_id == user_id,
                                                          AuthSession.revoked_at.is_(None))):
        revoke_session(db, sid, reason)


def refresh(db: Session, refresh_token: str) -> dict:
    """Rotate: each refresh token is single-use. Reuse revokes the whole session."""
    from app.services import google_auth  # local import: google_auth imports this module

    row = db.scalar(select(RefreshToken).where(RefreshToken.token_hash == hash_token(refresh_token or ""))
                    .with_for_update())
    if row is None:
        raise Unauthorized("Invalid refresh token", code="invalid_refresh")
    session = db.get(AuthSession, row.session_id)
    if row.used_at is not None or row.revoked_at is not None:
        if session and session.revoked_at is None:
            revoke_session(db, session.id, "refresh_token_reuse")
            audit.record(db, "refresh_reuse_detected", actor=session.user_id)
            db.commit()
        raise Unauthorized("Refresh token already used", code="refresh_reused")
    if as_utc(row.expires_at) < utcnow() or session is None or session.revoked_at is not None:
        raise Unauthorized("Session expired. Please sign in again.", code="session_expired")
    user = db.get(User, session.user_id)
    if user is None or user.status != "active" or user.deleted_at is not None:
        raise Unauthorized("Account is not active", code="account_inactive")
    profile = db.scalar(select(AdvocateProfile).where(AdvocateProfile.user_id == user.id))
    google_auth.assert_access_allowed(db, profile, session_id=session.id)
    row.used_at = utcnow()
    session.last_seen_at = utcnow()
    return _issue_tokens(db, user, session)


def logout(db: Session, session_id: uuid.UUID, user_id: uuid.UUID) -> None:
    session = db.get(AuthSession, session_id)
    if session and session.user_id == user_id and session.revoked_at is None:
        revoke_session(db, session_id, "logout")
        audit.record(db, "logout", actor=user_id)
