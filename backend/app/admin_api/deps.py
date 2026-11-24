"""Request protection for /admin-api/v1: proxy gate, session cookie, Origin + CSRF, permissions.

Failures are JSON errors (``{"error": {"code", "message"}}``) so the web app can react to them:
``not_authenticated`` / ``session_expired`` (401), ``forbidden`` / ``reauth_required`` / ``csrf_failed`` /
``origin_denied`` (403), ``rate_limited`` (429).
"""

from __future__ import annotations

import hmac
from collections.abc import Callable
from dataclasses import dataclass

from fastapi import Depends, Request, Response
from sqlalchemy.orm import Session

from app.admin import guards, permissions
from app.core.config import get_settings
from app.core.errors import Forbidden, Unauthorized
from app.db.session import get_db
from app.models import AdminAccount, AdminSession
from app.services import admin_access

PREFIX = "/admin-api/v1"
PROXY_HEADER = "x-admin-proxy-key"
CSRF_HEADER = "x-csrf-token"
NONCE_MAX_AGE = 600  # seconds a sign-in page may stay open before the nonce expires


def _secure() -> bool:
    return get_settings().environment in ("staging", "production")


def session_cookie_name() -> str:
    # __Host- cookies must be Secure, Path=/ and have no Domain: the browser then pins them to the admin host.
    return "__Host-am_admin_app" if _secure() else "am_admin_app"


def nonce_cookie_name() -> str:
    return "__Host-am_admin_nonce" if _secure() else "am_admin_nonce"


def set_session_cookie(response: Response, token: str) -> None:
    response.set_cookie(session_cookie_name(), token, httponly=True, secure=_secure(), samesite="strict", path="/",
                        max_age=get_settings().admin_session_max_hours * 3600)


def clear_session_cookie(response: Response) -> None:
    response.delete_cookie(session_cookie_name(), path="/", secure=_secure(), httponly=True, samesite="strict")


def set_nonce_cookie(response: Response, nonce: str) -> None:
    response.set_cookie(nonce_cookie_name(), nonce, httponly=True, secure=_secure(), samesite="strict", path="/",
                        max_age=NONCE_MAX_AGE)


def clear_nonce_cookie(response: Response) -> None:
    response.delete_cookie(nonce_cookie_name(), path="/", secure=_secure(), httponly=True, samesite="strict")


def client_ip(request: Request) -> str | None:
    return request.client.host if request.client else None


def gate_allows(request: Request) -> bool:
    """Only the Admin App's reverse proxy (shared secret) and allowed IPs reach the API; others get a 404."""
    secret = get_settings().admin_proxy_secret
    if secret:
        sent = request.headers.get(PROXY_HEADER) or ""
        if not hmac.compare_digest(sent.encode(), secret.encode()):
            return False
    return guards.ip_allowed(client_ip(request))


def check_origin(request: Request) -> None:
    """Browsers send Origin on every POST/PATCH/DELETE; it must be the Admin App itself."""
    origin = (request.headers.get("origin") or "").rstrip("/")
    if origin not in get_settings().admin_app_origin_list:
        raise Forbidden("This request could not be verified. Reload the page and try again.", code="origin_denied")


@dataclass
class AdminApiContext:
    request: Request
    db: Session
    session: AdminSession
    account: AdminAccount

    @property
    def role(self) -> str:
        return self.account.role

    @property
    def ip(self) -> str | None:
        return client_ip(self.request)

    def can(self, permission: str) -> bool:
        return permissions.can(self.role, permission)


def current_admin(request: Request, db: Session = Depends(get_db)) -> AdminApiContext:
    token = request.cookies.get(session_cookie_name())
    loaded = admin_access.load_session(db, token)
    if loaded is None:
        db.commit()  # keep any expiry/revocation just recorded
        if token:
            raise Unauthorized("Your session ended. Please sign in again.", code="session_expired")
        raise Unauthorized("Please sign in.", code="not_authenticated")
    sess, acct = loaded
    if request.method in guards.UNSAFE_METHODS:
        check_origin(request)
        if not guards.csrf_valid(sess, request.headers.get(CSRF_HEADER)):
            raise Forbidden("This request could not be verified. Reload the page and try again.", code="csrf_failed")
        guards.hit_action_limit(acct.id)
    return AdminApiContext(request=request, db=db, session=sess, account=acct)


def require(permission: str) -> Callable[..., AdminApiContext]:
    """Dependency: the signed-in admin must hold ``permission`` (and a fresh Google sign-in where required)."""

    def dep(ctx: AdminApiContext = Depends(current_admin)) -> AdminApiContext:
        refusal = guards.check_permission(ctx.role, permission, ctx.session, ctx.request.method)
        if refusal == "forbidden":
            raise Forbidden("Your admin role does not allow this.", code="forbidden")
        if refusal == "reauth_required":
            raise Forbidden("Please confirm it's you with Google to continue.", code="reauth_required")
        return ctx

    return dep
