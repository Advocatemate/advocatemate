"""Request protection for /admin-mobile/v1: bearer access token, permissions, re-authentication, rate limits.

There are no cookies, so there is nothing a third-party page could make the phone send: no CSRF token or Origin
check is needed. Errors are JSON (``{"error": {"code", "message"}}``): ``not_authenticated``,
``token_expired`` (refresh and retry), ``session_expired`` (sign in again) - 401; ``forbidden``,
``reauth_required`` - 403; ``rate_limited`` - 429.
"""

from __future__ import annotations

from collections.abc import Callable
from dataclasses import dataclass

from fastapi import Depends, Request
from sqlalchemy.orm import Session

from app.admin import guards, permissions
from app.core.errors import Forbidden, Unauthorized
from app.db.session import get_db
from app.models import AdminAccount, AdminSession
from app.services import admin_mobile_auth
from app.services.admin_access import AdminAccessError

PREFIX = "/admin-mobile/v1"


def client_ip(request: Request) -> str | None:
    return request.client.host if request.client else None


def bearer_token(request: Request) -> str | None:
    header = request.headers.get("authorization") or ""
    scheme, _, value = header.partition(" ")
    return (value.strip() or None) if scheme.lower() == "bearer" else None


@dataclass
class MobileContext:
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


def current_admin(request: Request, db: Session = Depends(get_db)) -> MobileContext:
    token = bearer_token(request)
    if not token:
        raise Unauthorized("Please sign in.", code="not_authenticated")
    try:
        sess, acct = admin_mobile_auth.authenticate(db, token)
    except AdminAccessError as e:
        db.commit()  # keep any expiry/revocation just recorded
        raise Unauthorized(e.message, code=e.code) from e
    if request.method in guards.UNSAFE_METHODS:
        guards.hit_action_limit(acct.id)
    return MobileContext(request=request, db=db, session=sess, account=acct)


def require(permission: str) -> Callable[..., MobileContext]:
    """Dependency: the signed-in admin must hold ``permission`` (and a fresh Google sign-in where required)."""

    def dep(ctx: MobileContext = Depends(current_admin)) -> MobileContext:
        refusal = guards.check_permission(ctx.role, permission, ctx.session, ctx.request.method)
        if refusal == "forbidden":
            raise Forbidden("Your admin role does not allow this.", code="forbidden")
        if refusal == "reauth_required":
            raise Forbidden("Please confirm it's you with Google to continue.", code="reauth_required")
        return ctx

    return dep
