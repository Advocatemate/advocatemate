"""Google sign-in + automatic advocate verification against the advocate registry.

There is no manual or admin approval. Access is granted only when a server-verified Google
identity matches the authoritative advocate registry, and the resulting link is strictly
one Google account <-> one user <-> one advocate code.

Step 1  POST /auth/google        verify the Google ID token on the server.
        * Google account already linked and still eligible  -> session   (Scenario B)
        * otherwise -> short-lived, single-use, server-signed link token (nothing stored)
Step 2  POST /auth/google/link   link token + advocate code, checked in one locked transaction:
        C invalid code . F Google account linked elsewhere . G not eligible . (no registered email)
        D email mismatch . E advocate linked to another Google account
        A all good -> link + session
"""

from __future__ import annotations

import logging
import secrets
import uuid
from datetime import UTC, datetime, timedelta

import jwt
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core import rate_limit
from app.core.config import get_settings
from app.core.errors import AppError, Conflict, NotFound, Unauthorized
from app.core.logging import log_event
from app.db.base import utcnow
from app.integrations import google_identity
from app.integrations.google_identity import GoogleIdentity
from app.models import Advocate, AdvocateProfile, AdvocateRegistryEntry, NotificationPreference, User
from app.services import audit, sources
from app.services.auth import issue_session, revoke_all_sessions, revoke_session

logger = logging.getLogger(__name__)
LINK_TOKEN_TYPE = "google_link"  # noqa: S105 - JWT "typ" value, not a secret
VERIFICATION_METHOD = "registry_email_match"

MESSAGES = {
    "invalid_advocate_code": "Invalid Advocate Code. Please check your code and try again.",
    "advocate_not_eligible": "This advocate code is not active for AdvocateMate access.",
    "registry_email_missing": ("This advocate code has no registered email address, so it cannot be verified. "
                               "Please update your registered email with the issuing authority."),
    "email_mismatch": ("Your Google account email does not match the email registered for this advocate code. "
                       "Please sign in with your registered email address."),
    "advocate_already_linked": "This advocate code is already linked to a different Google account.",
    "google_account_linked_elsewhere": "This Google account is already linked to a different advocate code.",
}


def _deny(code: str, status: int) -> AppError:
    return AppError(MESSAGES[code], code=code, status_code=status)


# ------------------------------------------------------------------ link token
def _issue_link_token(identity: GoogleIdentity) -> tuple[str, int]:
    s = get_settings()
    ttl = s.google_link_token_minutes * 60
    now = datetime.now(UTC)
    payload = {
        "typ": LINK_TOKEN_TYPE,
        "iss": s.jwt_issuer,
        "sub": identity.sub,
        "email": identity.email,
        "iat": int(now.timestamp()),
        "exp": int((now + timedelta(seconds=ttl)).timestamp()),
        "jti": secrets.token_hex(12),
    }
    return jwt.encode(payload, s.jwt_secret, algorithm=s.jwt_algorithm), ttl


def _read_link_token(db: Session, token: str) -> tuple[GoogleIdentity, str]:
    s = get_settings()
    try:
        claims = jwt.decode(token, s.jwt_secret, algorithms=[s.jwt_algorithm], issuer=s.jwt_issuer,
                            options={"require": ["exp", "sub", "email", "jti", "typ"]})
    except jwt.ExpiredSignatureError as e:
        raise Unauthorized("Your Google sign-in expired. Please sign in again.", code="link_token_expired") from e
    except jwt.PyJWTError as e:
        raise Unauthorized("Please sign in with Google again.", code="link_token_invalid") from e
    if claims.get("typ") != LINK_TOKEN_TYPE:
        raise Unauthorized("Please sign in with Google again.", code="link_token_invalid")
    payload, _, _ = sources.cache_get(db, f"auth:used_link:{claims['jti']}")
    if payload is not None:
        raise Unauthorized("This sign-in was already used. Please sign in again.", code="link_token_used")
    return GoogleIdentity(sub=claims["sub"], email=claims["email"], email_verified=True), claims["jti"]


# ------------------------------------------------------------------ eligibility
def assert_access_allowed(db: Session, profile: AdvocateProfile | None, *, session_id: uuid.UUID | None = None) -> None:
    """Called on refresh and on every authenticated request."""
    if profile is None or not profile.google_sub:
        # e.g. a profile from the retired mobile-OTP login: must sign in with Google.
        if session_id:
            revoke_session(db, session_id, "google_link_required")
            db.commit()
        raise Unauthorized("Please sign in with Google.", code="google_link_required")
    entry = db.get(AdvocateRegistryEntry, profile.advocate_code)
    if entry is None or not entry.is_eligible:
        if session_id:
            revoke_session(db, session_id, "advocate_not_eligible")
            audit.record(db, "access_revoked_not_eligible", actor=profile.user_id, target_type="advocate",
                         target_id=profile.advocate_code)
            db.commit()
        raise _deny("advocate_not_eligible", 403)


# ------------------------------------------------------------------ step 1
def sign_in_with_google(db: Session, id_token: str, *, device_label: str | None, user_agent: str | None,
                        ip: str | None) -> dict:
    rate_limit.hit(f"google-signin-ip:{ip or 'unknown'}", 30, 600)
    identity = google_identity.verify_id_token(id_token)

    profile = db.scalar(select(AdvocateProfile).where(AdvocateProfile.google_sub == identity.sub))
    if profile is not None:  # Scenario B: already linked
        user = db.get(User, profile.user_id)
        if user is None or user.status != "active" or user.deleted_at is not None:
            raise Unauthorized("Account is not active", code="account_inactive")
        assert_access_allowed(db, profile)
        profile.google_email = identity.email  # informational; identity is the stable `sub`
        user.last_login_at = utcnow()
        tokens = issue_session(db, user, device_label=device_label, user_agent=user_agent)
        audit.record(db, "login_google", actor=user.id, ip=ip, advocate_code=profile.advocate_code)
        return {"status": "signed_in", **tokens}

    link_token, ttl = _issue_link_token(identity)
    audit.record(db, "google_verified_needs_advocate_code", ip=ip)
    return {"status": "advocate_code_required", "link_token": link_token, "link_expires_in": ttl,
            "google_email": identity.email}


# ------------------------------------------------------------------ step 2
def link_advocate(db: Session, link_token: str, advocate_code: str, *, device_label: str | None,
                  user_agent: str | None, ip: str | None) -> dict:
    identity, jti = _read_link_token(db, link_token)
    rate_limit.hit(f"advocate-link:{identity.sub}", 10, 3600)
    rate_limit.hit(f"advocate-link-ip:{ip or 'unknown'}", 30, 3600)
    code = (advocate_code or "").strip()

    def outcome(result: str) -> None:
        audit.record(db, "advocate_link_attempt", ip=ip, target_type="advocate", target_id=code[:16] or None,
                     result=result)
        log_event(logger, logging.INFO, "advocate link attempt", result=result)

    # Lock the registry row so two attempts on the same code are serialised.
    entry = db.get(AdvocateRegistryEntry, code, with_for_update=True) if code.isdigit() else None
    if entry is None:  # Scenario C
        outcome("invalid_advocate_code")
        db.commit()
        raise NotFound(MESSAGES["invalid_advocate_code"], code="invalid_advocate_code")
    # Scenario F first: a Google account already linked to one advocate can never take a second,
    # whatever the second code's registry data says.
    by_sub = db.scalar(select(AdvocateProfile).where(AdvocateProfile.google_sub == identity.sub))
    if by_sub is not None and by_sub.advocate_code != code:
        outcome("google_account_linked_elsewhere")
        db.commit()
        raise Conflict(MESSAGES["google_account_linked_elsewhere"], code="google_account_linked_elsewhere")
    if not entry.is_eligible:  # Scenario G
        outcome("advocate_not_eligible")
        db.commit()
        raise _deny("advocate_not_eligible", 403)
    if not entry.email_normalized:
        outcome("registry_email_missing")
        db.commit()
        raise _deny("registry_email_missing", 403)
    if entry.email_normalized != identity.email:  # Scenario D
        outcome("email_mismatch")
        db.commit()
        raise _deny("email_mismatch", 403)

    profile = db.scalar(select(AdvocateProfile).where(AdvocateProfile.advocate_code == code).with_for_update())
    if profile is not None and profile.google_sub and profile.google_sub != identity.sub:  # Scenario E
        outcome("advocate_already_linked")
        db.commit()
        raise Conflict(MESSAGES["advocate_already_linked"], code="advocate_already_linked")

    # Scenario A (or a repeat of an already-completed link for the same pair).
    now = utcnow()
    try:
        with db.begin_nested():
            if db.get(Advocate, code) is None:  # public directory row needed by the FK; never overwritten
                db.add(Advocate(advocate_code=code, name=entry.full_name, source="advocate_registry", fetched_at=now))
            if profile is None:
                user = User(role="advocate", status="active")
                db.add(user)
                db.flush()
                profile = AdvocateProfile(user_id=user.id, advocate_code=code, source_name=entry.full_name)
                db.add(profile)
                db.add(NotificationPreference(user_id=user.id))
            else:
                user = db.get(User, profile.user_id)
                if not profile.google_sub:
                    # Existing profile from the retired OTP login: keep its favourites/history, but end
                    # every session that was not created through this verified Google link.
                    revoke_all_sessions(db, user.id, "relinked_with_google")
            profile.google_sub = identity.sub
            profile.google_email = identity.email
            profile.linked_at = profile.linked_at or now
            profile.verification_method = VERIFICATION_METHOD
            profile.identity_verification = "registry_verified"
            profile.identity_verified_at = now
            profile.source_name = entry.full_name
            db.flush()
    except IntegrityError as e:  # a concurrent link won the race on google_sub / advocate_code
        db.rollback()
        raise Conflict(MESSAGES["google_account_linked_elsewhere"], code="google_account_linked_elsewhere") from e

    if user is None or user.status != "active" or user.deleted_at is not None:
        raise Unauthorized("Account is not active", code="account_inactive")
    user.last_login_at = now
    sources.cache_put(db, f"auth:used_link:{jti}", {"used": True}, get_settings().google_link_token_minutes * 60 + 60)
    tokens = issue_session(db, user, device_label=device_label, user_agent=user_agent)
    outcome("linked")
    audit.record(db, "account_linked_google", actor=user.id, target_type="advocate", target_id=code, ip=ip)
    return {"status": "signed_in", **tokens}
