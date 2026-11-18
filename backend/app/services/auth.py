"""Advocate registration / login.

Flow: register(advocate_code) -> source lookup (Lexika) -> user confirms identity
-> send_otp(advocate_code, mobile) -> verify_otp -> session + JWT access/refresh.

Honest limits (docs/AUTHENTICATION.md):
* No authorised source of advocates' mobile numbers was found. The OTP proves
  possession of the mobile number only; the advocate-code claim is recorded as
  ``self_declared`` until an administrator verifies it out of band.
* Once a code is bound to an account, logins for that code are only possible via
  OTP to that account's verified mobile.
* OTP delivery requires an SMS provider; ``OTP_PROVIDER=disabled`` makes send-otp
  return 503 rather than pretending a message was sent.
"""

from __future__ import annotations

import re
import secrets
import uuid
from datetime import timedelta

from sqlalchemy import select, update
from sqlalchemy.orm import Session

from app.core import rate_limit
from app.core.config import get_settings
from app.core.errors import AppError, Conflict, ServiceUnavailable, Unauthorized
from app.core.security import (
    constant_time_equals,
    create_access_token,
    generate_otp,
    hash_otp,
    hash_token,
    new_refresh_token,
)
from app.db.base import as_utc, utcnow
from app.models import (
    AdvocateProfile,
    AuthSession,
    NotificationPreference,
    OtpRecord,
    RefreshToken,
    User,
    VerifiedMobile,
)
from app.services import advocates, audit

_PHONE_RE = re.compile(r"^(?:\+?91)?(\d{10})$")


def normalise_phone(raw: str) -> str:
    digits = re.sub(r"[\s\-()]", "", raw or "")
    m = _PHONE_RE.match(digits)
    if not m or m.group(1)[0] not in "6789":
        raise AppError("Enter a valid 10-digit Indian mobile number", code="invalid_mobile", status_code=422)
    return f"+91{m.group(1)}"


def mask_phone(phone: str) -> str:
    return f"{phone[:3]}******{phone[-4:]}"


def register(db: Session, advocate_code: str) -> dict:
    adv, _ = advocates.lookup(db, advocate_code)
    profile = db.scalar(select(AdvocateProfile).where(AdvocateProfile.advocate_code == adv.advocate_code))
    mobile_hint = None
    if profile:
        m = db.scalar(select(VerifiedMobile).where(VerifiedMobile.user_id == profile.user_id,
                                                   VerifiedMobile.is_primary.is_(True)))
        mobile_hint = mask_phone(m.phone_e164) if m else None
    return {
        "advocate_code": adv.advocate_code,
        "advocate_name": adv.name,
        "source": "aphc.gov.in (Lexika)",
        "already_registered": profile is not None,
        "registered_mobile_hint": mobile_hint,
        "otp_available": get_settings().otp_provider != "disabled",
        "identity_note": "Please confirm this is you. Advocate codes are public, so we verify your mobile by OTP.",
    }


def send_otp(db: Session, advocate_code: str, mobile: str, ip: str | None) -> dict:
    s = get_settings()
    code = advocates.validate_code(advocate_code)
    phone = normalise_phone(mobile)
    rate_limit.hit(f"otp-send:{phone}", s.otp_max_sends_per_hour, 3600)
    rate_limit.hit(f"otp-send-ip:{ip or 'unknown'}", s.otp_max_sends_per_hour * 4, 3600)

    if s.otp_provider == "disabled":
        raise ServiceUnavailable("OTP delivery is not configured for this environment.", code="otp_unavailable")

    adv, _ = advocates.lookup(db, code)
    profile = db.scalar(select(AdvocateProfile).where(AdvocateProfile.advocate_code == code))
    if profile is not None:
        bound = db.scalar(select(VerifiedMobile).where(VerifiedMobile.user_id == profile.user_id,
                                                       VerifiedMobile.phone_e164 == phone))
        if bound is None:
            raise Conflict("This advocate code is registered with a different mobile number.",
                           code="mobile_mismatch")

    # Invalidate previous unconsumed OTPs for this phone.
    db.execute(update(OtpRecord).where(OtpRecord.phone_e164 == phone, OtpRecord.consumed_at.is_(None))
               .values(consumed_at=utcnow()))
    otp = generate_otp(s.otp_length)
    salt = secrets.token_hex(8)
    rec = OtpRecord(phone_e164=phone, advocate_code=code, purpose="login" if profile else "register",
                    code_hash=f"{salt}${hash_otp(phone, otp, salt)}",
                    expires_at=utcnow() + timedelta(seconds=s.otp_ttl_seconds))
    db.add(rec)
    audit.record(db, "otp_sent", target_type="advocate", target_id=code, ip=ip)
    resp = {"otp_id": str(rec.id), "expires_in": s.otp_ttl_seconds, "sent_to": mask_phone(phone),
            "advocate_name": adv.name}
    if s.otp_provider == "dev_echo" and s.is_dev_like:
        resp["dev_otp"] = otp  # development/test only - never enabled in staging/production
    return resp


def verify_otp(db: Session, advocate_code: str, mobile: str, otp: str, *, device_label: str | None,
               user_agent: str | None, ip: str | None) -> dict:
    s = get_settings()
    code = advocates.validate_code(advocate_code)
    phone = normalise_phone(mobile)
    rate_limit.hit(f"otp-verify:{phone}", s.otp_max_verify_attempts * 3, 3600)
    rec = db.scalar(select(OtpRecord).where(OtpRecord.phone_e164 == phone, OtpRecord.advocate_code == code,
                                            OtpRecord.consumed_at.is_(None))
                    .order_by(OtpRecord.created_at.desc()).limit(1).with_for_update())
    if rec is None or as_utc(rec.expires_at) < utcnow():
        raise Unauthorized("OTP expired or not requested. Please request a new OTP.", code="otp_expired")
    if rec.attempts >= s.otp_max_verify_attempts:
        rec.consumed_at = utcnow()
        raise Unauthorized("Too many incorrect attempts. Please request a new OTP.", code="otp_locked")
    rec.attempts += 1
    salt, digest = rec.code_hash.split("$", 1)
    if not (otp or "").isdigit() or not constant_time_equals(hash_otp(phone, otp, salt), digest):
        audit.record(db, "otp_failed", target_type="advocate", target_id=code, ip=ip)
        db.commit()  # persist the attempt counter even though we raise
        raise Unauthorized("Incorrect OTP", code="otp_invalid")
    rec.consumed_at = utcnow()

    adv = advocates.lookup(db, code)[0]
    profile = db.scalar(select(AdvocateProfile).where(AdvocateProfile.advocate_code == code).with_for_update())
    if profile is None:
        user = User(role="advocate", status="active")
        db.add(user)
        db.flush()
        profile = AdvocateProfile(user_id=user.id, advocate_code=code, source_name=adv.name,
                                  identity_verification="self_declared")
        db.add(profile)
        db.add(VerifiedMobile(user_id=user.id, phone_e164=phone, is_primary=True))
        db.add(NotificationPreference(user_id=user.id))
        audit.record(db, "account_registered", actor=user.id, target_type="advocate", target_id=code, ip=ip)
    else:
        user = db.get(User, profile.user_id)
        if not db.scalar(select(VerifiedMobile).where(VerifiedMobile.user_id == user.id,
                                                      VerifiedMobile.phone_e164 == phone)):
            raise Conflict("This advocate code is registered with a different mobile number.", code="mobile_mismatch")
        if user.status != "active":
            raise Unauthorized("Account is disabled", code="account_inactive")
        profile.source_name = adv.name
    user.last_login_at = utcnow()
    db.flush()
    tokens = _issue_session(db, user, device_label=device_label, user_agent=user_agent)
    audit.record(db, "login", actor=user.id, ip=ip)
    return tokens


def _issue_session(db: Session, user: User, *, device_label: str | None, user_agent: str | None) -> dict:
    session = AuthSession(user_id=user.id, device_label=(device_label or "")[:120] or None,
                          user_agent=(user_agent or "")[:255] or None)
    db.add(session)
    db.flush()
    return _issue_tokens(db, user, session)


def _issue_tokens(db: Session, user: User, session: AuthSession) -> dict:
    access, ttl = create_access_token(user_id=user.id, session_id=session.id, role=user.role)
    refresh = new_refresh_token()
    db.add(RefreshToken(session_id=session.id, token_hash=hash_token(refresh),
                        expires_at=utcnow() + timedelta(days=get_settings().refresh_token_ttl_days)))
    db.flush()
    return {"access_token": access, "token_type": "bearer", "expires_in": ttl, "refresh_token": refresh,
            "session_id": str(session.id)}


def refresh(db: Session, refresh_token: str) -> dict:
    """Rotate: each refresh token is single-use. Reuse revokes the whole session."""
    row = db.scalar(select(RefreshToken).where(RefreshToken.token_hash == hash_token(refresh_token or ""))
                    .with_for_update())
    if row is None:
        raise Unauthorized("Invalid refresh token", code="invalid_refresh")
    session = db.get(AuthSession, row.session_id)
    if row.used_at is not None or row.revoked_at is not None:
        if session and session.revoked_at is None:
            session.revoked_at = utcnow()
            session.revoke_reason = "refresh_token_reuse"
            audit.record(db, "refresh_reuse_detected", actor=session.user_id)
            db.commit()
        raise Unauthorized("Refresh token already used", code="refresh_reused")
    if as_utc(row.expires_at) < utcnow() or session is None or session.revoked_at is not None:
        raise Unauthorized("Session expired. Please log in again.", code="session_expired")
    user = db.get(User, session.user_id)
    if user is None or user.status != "active":
        raise Unauthorized("Account is not active", code="account_inactive")
    row.used_at = utcnow()
    session.last_seen_at = utcnow()
    return _issue_tokens(db, user, session)


def logout(db: Session, session_id: uuid.UUID, user_id: uuid.UUID) -> None:
    session = db.get(AuthSession, session_id)
    if session and session.user_id == user_id and session.revoked_at is None:
        session.revoked_at = utcnow()
        session.revoke_reason = "logout"
        db.execute(update(RefreshToken).where(RefreshToken.session_id == session_id, RefreshToken.revoked_at.is_(None))
                   .values(revoked_at=utcnow()))
        audit.record(db, "logout", actor=user_id)
