"""Phone-app sign-in endpoints: challenge -> Google -> tokens; refresh; session; re-authentication; sign-out."""

from __future__ import annotations

import uuid
from datetime import timedelta

from fastapi import APIRouter, Depends, Request, Response
from sqlalchemy.orm import Session

from app.admin import permissions
from app.admin_api.schemas import AccountOut
from app.admin_mobile import deps
from app.admin_mobile.schemas import (
    ChallengeOut,
    GoogleSignInIn,
    MobileSessionInfo,
    MobileSessionOut,
    ReauthIn,
    RefreshIn,
    SessionList,
    SessionListItem,
    TokensOut,
)
from app.core import rate_limit
from app.core.config import get_settings
from app.core.errors import AppError, Forbidden, NotFound, Unauthorized
from app.db.base import as_utc, utcnow
from app.db.session import get_db
from app.models import AdminAccount, AdminSession
from app.services import admin_access, admin_mobile_auth
from app.services.admin_mobile_auth import DeviceInfo, MobileTokens

router = APIRouter(prefix="/auth")


def session_out(sess: AdminSession, acct: AdminAccount) -> MobileSessionOut:
    s = get_settings()
    return MobileSessionOut(
        account=AccountOut(id=str(acct.id), email=acct.email, display_name=acct.display_name, role=acct.role,
                           role_label=permissions.ROLE_LABELS[acct.role]),
        permissions=sorted(permissions.PERMISSIONS.get(acct.role, frozenset())),
        session=MobileSessionInfo(
            id=str(sess.id), client=sess.client, platform=sess.platform, created_at=as_utc(sess.created_at),
            expires_at=as_utc(sess.expires_at), idle_timeout_minutes=s.admin_session_idle_minutes,
            reauth_until=as_utc(sess.reauth_at) + timedelta(minutes=s.admin_reauth_minutes),
            access_expires_at=as_utc(sess.token_expires_at) if sess.token_expires_at else None),
        environment=s.environment,
    )


def _tokens_out(tokens: MobileTokens) -> TokensOut:
    expires_in = int((as_utc(tokens.session.token_expires_at) - utcnow()).total_seconds())
    return TokensOut(access_token=tokens.access_token, expires_in=max(expires_in, 0),
                     refresh_token=tokens.refresh_token, session=session_out(tokens.session, tokens.account))


def _error(e: admin_access.AdminAccessError) -> AppError:
    if e.code in ("not_authorised", "different_account"):
        return Forbidden(e.message, code=e.code)
    return Unauthorized(e.message, code=e.code)


@router.post("/challenge", response_model=ChallengeOut)
def sign_in_challenge(request: Request, db: Session = Depends(get_db)):
    """Step 1: a one-time nonce for Google sign-in."""
    ip = deps.client_ip(request)
    rate_limit.hit(f"admin-mobile-challenge-ip:{ip or 'unknown'}", 30, 600)
    challenge, nonce = admin_mobile_auth.create_challenge(db, "signin", ip=ip)
    return ChallengeOut(challenge_id=str(challenge.id), nonce=nonce,
                        expires_in=get_settings().admin_challenge_minutes * 60)


@router.post("/google", response_model=TokensOut)
def google_sign_in(body: GoogleSignInIn, request: Request, db: Session = Depends(get_db)):
    """Step 2: the Google ID token (carrying the challenge nonce) for an access + refresh token pair."""
    ip = deps.client_ip(request)
    rate_limit.hit(f"admin-login-ip:{ip or 'unknown'}", 10, 600)
    device = DeviceInfo(installation_id=body.device.installation_id, platform=body.device.platform,
                        device_name=body.device.device_name, app_version=body.device.app_version)
    try:
        tokens = admin_mobile_auth.sign_in(db, body.challenge_id, body.id_token, device, ip=ip,
                                           user_agent=request.headers.get("user-agent"))
    except admin_access.AdminAccessError as e:
        db.commit()  # the challenge stays used up; refusals stay audited
        raise _error(e) from e
    return _tokens_out(tokens)


@router.post("/refresh", response_model=TokensOut)
def refresh(body: RefreshIn, request: Request, db: Session = Depends(get_db)):
    """A new access + refresh token pair; the refresh token sent here stops working."""
    ip = deps.client_ip(request)
    rate_limit.hit(f"admin-mobile-refresh-ip:{ip or 'unknown'}", 60, 60)
    try:
        tokens = admin_mobile_auth.refresh(db, body.refresh_token, ip=ip)
    except admin_access.AdminAccessError as e:
        raise _error(e) from e
    return _tokens_out(tokens)


@router.get("/session", response_model=MobileSessionOut)
def current_session(ctx: deps.MobileContext = Depends(deps.current_admin)):
    return session_out(ctx.session, ctx.account)


@router.post("/reauth/challenge", response_model=ChallengeOut)
def reauth_challenge(ctx: deps.MobileContext = Depends(deps.current_admin)):
    """A one-time nonce for re-authenticating this session before a sensitive action."""
    challenge, nonce = admin_mobile_auth.create_challenge(ctx.db, "reauth", ip=ctx.ip, session=ctx.session)
    return ChallengeOut(challenge_id=str(challenge.id), nonce=nonce,
                        expires_in=get_settings().admin_challenge_minutes * 60)


@router.post("/reauth", response_model=MobileSessionOut)
def reauth(body: ReauthIn, ctx: deps.MobileContext = Depends(deps.current_admin)):
    try:
        admin_mobile_auth.reauthenticate(ctx.db, ctx.session, ctx.account, body.challenge_id, body.id_token,
                                         ip=ctx.ip)
    except admin_access.AdminAccessError as e:
        ctx.db.commit()  # the challenge stays used up; the refusal stays audited
        raise _error(e) from e
    return session_out(ctx.session, ctx.account)


@router.post("/logout", status_code=204)
def logout(ctx: deps.MobileContext = Depends(deps.current_admin)):
    admin_access.sign_out(ctx.db, ctx.session, ctx.account, ip=ctx.ip)
    return Response(status_code=204)


@router.get("/sessions", response_model=SessionList)
def my_sessions(ctx: deps.MobileContext = Depends(deps.current_admin)):
    """The admin's live sessions on every client (browser and phone)."""
    rows = admin_access.list_live_sessions(ctx.db, ctx.account.id)
    return SessionList(items=[
        SessionListItem(id=str(r.id), client=r.client, platform=r.platform, device_name=r.device_name,
                        app_version=r.app_version, user_agent=r.user_agent, created_at=as_utc(r.created_at),
                        last_seen_at=as_utc(r.last_seen_at), expires_at=as_utc(r.expires_at),
                        current=r.id == ctx.session.id)
        for r in rows])


@router.delete("/sessions/{session_id}", status_code=204)
def end_session(session_id: str, ctx: deps.MobileContext = Depends(deps.current_admin)):
    try:
        target = ctx.db.get(AdminSession, uuid.UUID(session_id))
    except ValueError:
        target = None
    if target is None or target.admin_account_id != ctx.account.id or target.revoked_at is not None:
        raise NotFound("That session does not exist.")
    admin_access.revoke_session(ctx.db, target, ctx.account, ip=ctx.ip)
    return Response(status_code=204)
