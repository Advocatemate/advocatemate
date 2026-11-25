"""Sign-in and sessions for the AdvocateMate Admin phone app (Android / iOS).

Same admins, roles, Google verification, session limits and audit trail as the browser portal
(``admin_access``); only the way the session travels differs:

* sign-in uses a one-time server challenge: the app puts its nonce into Google's sign-in request, and the
  ID token must carry it, so a token cannot be replayed or brought from elsewhere;
* the app holds a short-lived **access token** (sent as ``Authorization: Bearer``) and a single-use
  **refresh token** kept in the phone's Keychain / Keystore. Only hashes are stored here. Using a refresh token
  twice ends the whole session (a copy is in someone else's hands);
* the session itself still ends after the idle limit or the absolute limit, on sign-out or deactivation.
"""

from __future__ import annotations

import hashlib
import secrets
import uuid
from dataclasses import dataclass
from datetime import timedelta

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.security import hash_ip
from app.db.base import as_utc, utcnow
from app.models import AdminAccount, AdminAuthChallenge, AdminRefreshToken, AdminSession
from app.services import admin_access, audit
from app.services.admin_access import AdminAccessError

MOBILE = "mobile"
SIGN_IN_EXPIRED = "This sign-in attempt expired. Please try again."
SESSION_ENDED = "Your session ended. Please sign in again."


def _hash(value: str) -> str:
    return hashlib.sha256(value.encode()).hexdigest()


@dataclass(frozen=True)
class DeviceInfo:
    installation_id: str
    platform: str  # android | ios
    device_name: str | None = None
    app_version: str | None = None


@dataclass
class MobileTokens:
    access_token: str
    refresh_token: str
    session: AdminSession
    account: AdminAccount


# ------------------------------------------------------------------ challenges
def create_challenge(db: Session, purpose: str, *, ip: str | None,
                     session: AdminSession | None = None) -> tuple[AdminAuthChallenge, str]:
    """A one-time nonce for a Google sign-in (``signin``) or a re-authentication of ``session`` (``reauth``)."""
    nonce = secrets.token_urlsafe(32)
    now = utcnow()
    challenge = AdminAuthChallenge(nonce_hash=_hash(nonce), purpose=purpose,
                                   admin_session_id=session.id if session else None, created_at=now,
                                   expires_at=now + timedelta(minutes=get_settings().admin_challenge_minutes),
                                   ip_hash=hash_ip(ip))
    db.add(challenge)
    db.flush()
    return challenge, nonce


def consume_challenge(db: Session, challenge_id: str, purpose: str, *,
                      session: AdminSession | None = None) -> AdminAuthChallenge:
    """Use up a challenge (whatever happens next, it never works again)."""
    try:
        cid = uuid.UUID(challenge_id)
    except (ValueError, TypeError):
        cid = None
    challenge = db.scalar(select(AdminAuthChallenge).where(AdminAuthChallenge.id == cid).with_for_update()) \
        if cid else None
    if challenge is None or challenge.purpose != purpose or challenge.used_at is not None \
            or as_utc(challenge.expires_at) <= utcnow() \
            or (session is not None and challenge.admin_session_id != session.id):
        raise AdminAccessError("sign_in_expired", SIGN_IN_EXPIRED)
    challenge.used_at = utcnow()
    db.flush()
    return challenge


# ------------------------------------------------------------------ sessions
def _issue_tokens(db: Session, sess: AdminSession) -> tuple[str, str]:
    """New access token (replaces the previous one) and a new single-use refresh token."""
    now = utcnow()
    access = secrets.token_urlsafe(32)
    refresh = secrets.token_urlsafe(48)
    sess.token_hash = _hash(access)
    sess.token_expires_at = min(now + timedelta(minutes=get_settings().admin_access_token_minutes),
                                as_utc(sess.expires_at))
    db.add(AdminRefreshToken(admin_session_id=sess.id, token_hash=_hash(refresh), created_at=now,
                             expires_at=sess.expires_at))
    db.flush()
    return access, refresh


def sign_in(db: Session, challenge_id: str, id_token: str, device: DeviceInfo, *, ip: str | None,
            user_agent: str | None) -> MobileTokens:
    """Challenge -> Google ID token (admin app audience, carrying the challenge nonce) -> authorised admin ->
    new phone session."""
    challenge = consume_challenge(db, challenge_id, "signin")
    identity = admin_access.verify_google_sign_in(db, id_token, ip=ip,
                                                  audiences=get_settings().admin_mobile_audiences,
                                                  expected_nonce_sha256=challenge.nonce_hash)
    acct = admin_access.authorise_identity(db, identity, ip=ip)
    now = utcnow()
    s = get_settings()
    sess = AdminSession(admin_account_id=acct.id, token_hash=_hash(secrets.token_urlsafe(32)),
                        csrf_token=secrets.token_urlsafe(32),  # unused by bearer clients; column is required
                        created_at=now, last_seen_at=now, reauth_at=now,
                        expires_at=now + timedelta(hours=s.admin_session_max_hours), ip_hash=hash_ip(ip),
                        user_agent=(user_agent or "")[:255] or None, client=MOBILE, platform=device.platform,
                        device_name=device.device_name, app_version=device.app_version,
                        installation_id=device.installation_id)
    db.add(sess)
    db.flush()
    access, refresh = _issue_tokens(db, sess)
    audit.record(db, "admin_login", actor_admin=acct.id, target_type="admin_account", target_id=str(acct.id), ip=ip,
                 client=MOBILE, platform=device.platform)
    return MobileTokens(access, refresh, sess, acct)


def refresh(db: Session, refresh_token: str, *, ip: str | None) -> MobileTokens:
    """Exchange a refresh token for a new pair. Each refresh token works once; reuse ends the session."""
    row = db.scalar(select(AdminRefreshToken).where(AdminRefreshToken.token_hash == _hash(refresh_token or ""))
                    .with_for_update()) if refresh_token and len(refresh_token) <= 256 else None
    if row is None:
        raise AdminAccessError("invalid_refresh", SESSION_ENDED)
    sess = db.get(AdminSession, row.admin_session_id)
    if sess is None or sess.client != MOBILE:
        raise AdminAccessError("invalid_refresh", SESSION_ENDED)
    if row.used_at is not None:
        if sess.revoked_at is None:
            admin_access.revoke(sess, "refresh_token_reuse")
            audit.record(db, "admin_refresh_reuse_detected", actor_admin=sess.admin_account_id,
                         target_type="admin_session", target_id=str(sess.id), ip=ip)
        db.commit()
        raise AdminAccessError("refresh_reused", SESSION_ENDED)
    acct = admin_access.check_live(db, sess)
    if acct is None:
        db.commit()  # keep the reason the session ended
        raise AdminAccessError("session_expired", SESSION_ENDED)
    row.used_at = utcnow()
    access, new_refresh = _issue_tokens(db, sess)
    return MobileTokens(access, new_refresh, sess, acct)


def authenticate(db: Session, access_token: str) -> tuple[AdminSession, AdminAccount]:
    """The live phone session for a bearer access token.

    Raises ``token_expired`` when only the access token is out of date (the app refreshes and retries) and
    ``session_expired`` when the session itself is over.
    """
    sess = db.scalar(select(AdminSession).where(AdminSession.token_hash == _hash(access_token),
                                                AdminSession.client == MOBILE)) \
        if access_token and len(access_token) <= 128 else None
    if sess is None or sess.revoked_at is not None:
        raise AdminAccessError("session_expired", SESSION_ENDED)
    if sess.token_expires_at is None or as_utc(sess.token_expires_at) <= utcnow():
        raise AdminAccessError("token_expired", "Access token expired.")
    acct = admin_access.check_live(db, sess)
    if acct is None:
        raise AdminAccessError("session_expired", SESSION_ENDED)
    return sess, acct


def reauthenticate(db: Session, sess: AdminSession, acct: AdminAccount, challenge_id: str, id_token: str, *,
                   ip: str | None) -> None:
    """Fresh Google sign-in by the same admin before a sensitive action, bound to this session's challenge."""
    challenge = consume_challenge(db, challenge_id, "reauth", session=sess)
    admin_access.reauthenticate(db, sess, acct, id_token, ip=ip, audiences=get_settings().admin_mobile_audiences,
                                expected_nonce_sha256=challenge.nonce_hash)


def purge_expired(db: Session) -> int:
    """Housekeeping: drop used/expired challenges and refresh tokens of ended sessions."""
    now = utcnow()
    n = db.query(AdminAuthChallenge).filter(AdminAuthChallenge.expires_at < now - timedelta(days=1)).delete()
    ended = select(AdminSession.id).where(AdminSession.client == MOBILE, (AdminSession.revoked_at.is_not(None))
                                          | (AdminSession.expires_at < now))
    n += db.query(AdminRefreshToken).filter(AdminRefreshToken.admin_session_id.in_(ended)) \
        .delete(synchronize_session=False)
    return n
