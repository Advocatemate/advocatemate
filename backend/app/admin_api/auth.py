"""Admin App sign-in: Google ID token (bound to a nonce) -> authorised admin account -> server-side session.

Flow: ``GET auth/nonce`` (nonce in an HttpOnly cookie and in the body) -> Google Identity Services in the
browser, initialised with that nonce -> ``POST auth/google`` -> session cookie + ``GET auth/session``.
Every check is the existing ``admin_access`` service; this module only adapts it to JSON.
"""

from __future__ import annotations

import secrets
import uuid
from datetime import timedelta

from fastapi import APIRouter, Depends, Request, Response
from sqlalchemy.orm import Session

from app.admin import permissions
from app.admin_api import deps
from app.admin_api.schemas import (
    AccountOut,
    GoogleCredential,
    NonceOut,
    SessionInfo,
    SessionList,
    SessionListItem,
    SessionOut,
)
from app.core import rate_limit
from app.core.config import get_settings
from app.core.errors import AppError, Forbidden, NotFound, Unauthorized
from app.db.base import as_utc
from app.db.session import get_db
from app.models import AdminAccount, AdminSession
from app.services import admin_access

router = APIRouter(prefix="/auth")

SIGN_IN_EXPIRED = "The sign-in page expired. Please try again."


def session_out(sess: AdminSession, acct: AdminAccount) -> SessionOut:
    s = get_settings()
    return SessionOut(
        account=AccountOut(id=str(acct.id), email=acct.email, display_name=acct.display_name, role=acct.role,
                           role_label=permissions.ROLE_LABELS[acct.role]),
        permissions=sorted(permissions.PERMISSIONS.get(acct.role, frozenset())),
        csrf_token=sess.csrf_token,
        session=SessionInfo(id=str(sess.id), created_at=as_utc(sess.created_at), expires_at=as_utc(sess.expires_at),
                            idle_timeout_minutes=s.admin_session_idle_minutes,
                            reauth_until=as_utc(sess.reauth_at) + timedelta(minutes=s.admin_reauth_minutes)),
        environment=s.environment,
    )


def _access_error(e: admin_access.AdminAccessError) -> AppError:
    if e.code == "not_authorised":
        return Forbidden(e.message, code="not_authorised")
    if e.code == "different_account":
        return Forbidden(e.message, code="different_account")
    return Unauthorized(e.message, code=e.code)


@router.get("/nonce", response_model=NonceOut)
def nonce(request: Request, response: Response):
    rate_limit.hit(f"admin-nonce-ip:{deps.client_ip(request) or 'unknown'}", 30, 600)
    value = secrets.token_urlsafe(24)
    deps.set_nonce_cookie(response, value)
    return NonceOut(nonce=value, client_id=get_settings().admin_client_id, expires_in=deps.NONCE_MAX_AGE)


@router.post("/google", response_model=SessionOut)
def google_sign_in(body: GoogleCredential, request: Request, response: Response, db: Session = Depends(get_db)):
    deps.check_origin(request)
    ip = deps.client_ip(request)
    rate_limit.hit(f"admin-login-ip:{ip or 'unknown'}", 10, 600)
    expected = request.cookies.get(deps.nonce_cookie_name())
    if not expected:
        raise Unauthorized(SIGN_IN_EXPIRED, code="sign_in_expired")
    try:
        new = admin_access.sign_in(db, body.credential, ip=ip, user_agent=request.headers.get("user-agent"),
                                   expected_nonce=expected)
    except admin_access.AdminAccessError as e:
        raise _access_error(e) from e
    deps.set_session_cookie(response, new.token)
    deps.clear_nonce_cookie(response)
    return session_out(new.session, new.account)


@router.get("/session", response_model=SessionOut)
def current_session(ctx: deps.AdminApiContext = Depends(deps.current_admin)):
    return session_out(ctx.session, ctx.account)


@router.post("/reauth", response_model=SessionOut)
def reauth(body: GoogleCredential, response: Response, ctx: deps.AdminApiContext = Depends(deps.current_admin)):
    expected = ctx.request.cookies.get(deps.nonce_cookie_name())
    if not expected:
        raise Unauthorized(SIGN_IN_EXPIRED, code="sign_in_expired")
    try:
        admin_access.reauthenticate(ctx.db, ctx.session, ctx.account, body.credential, ip=ctx.ip,
                                    expected_nonce=expected)
    except admin_access.AdminAccessError as e:
        ctx.db.commit()  # keep the audit record of the refusal
        raise _access_error(e) from e
    deps.clear_nonce_cookie(response)
    return session_out(ctx.session, ctx.account)


@router.post("/logout", status_code=204)
def logout(ctx: deps.AdminApiContext = Depends(deps.current_admin)):
    admin_access.sign_out(ctx.db, ctx.session, ctx.account, ip=ctx.ip)
    response = Response(status_code=204)
    deps.clear_session_cookie(response)
    return response


@router.get("/sessions", response_model=SessionList)
def my_sessions(ctx: deps.AdminApiContext = Depends(deps.current_admin)):
    rows = admin_access.list_live_sessions(ctx.db, ctx.account.id)
    return SessionList(items=[
        SessionListItem(id=str(r.id), created_at=as_utc(r.created_at), last_seen_at=as_utc(r.last_seen_at),
                        expires_at=as_utc(r.expires_at), user_agent=r.user_agent, current=r.id == ctx.session.id)
        for r in rows])


@router.delete("/sessions/{session_id}", status_code=204)
def end_session(session_id: str, ctx: deps.AdminApiContext = Depends(deps.current_admin)):
    try:
        target = ctx.db.get(AdminSession, uuid.UUID(session_id))
    except ValueError:
        target = None
    if target is None or target.admin_account_id != ctx.account.id or target.revoked_at is not None:
        raise NotFound("That session does not exist.")
    admin_access.revoke_session(ctx.db, target, ctx.account, ip=ctx.ip)
    response = Response(status_code=204)
    if target.id == ctx.session.id:
        deps.clear_session_cookie(response)
    return response
