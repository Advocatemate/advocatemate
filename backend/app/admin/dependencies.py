"""Request-level protection for every admin route: IP allow-list, session, CSRF, roles, re-authentication."""

from __future__ import annotations

import hmac
import ipaddress
from collections.abc import Callable
from dataclasses import dataclass
from urllib.parse import quote

from fastapi import Depends, Request
from sqlalchemy.orm import Session

from app.admin import permissions
from app.core import rate_limit
from app.core.config import get_settings
from app.core.errors import RateLimited
from app.db.session import get_db
from app.models import AdminAccount, AdminSession
from app.services import admin_access

COOKIE_NAME = "am_admin"
COOKIE_PATH = "/admin"
CSRF_HEADER = "x-csrf-token"
CSRF_FIELD = "csrf_token"
UNSAFE_METHODS = {"POST", "PUT", "PATCH", "DELETE"}


class AdminRedirect(Exception):
    """Send the browser elsewhere (sign-in or re-authentication); HTMX requests get HX-Redirect."""

    def __init__(self, location: str):
        self.location = location


class AdminDenied(Exception):
    def __init__(self, status: int, title: str, message: str):
        self.status, self.title, self.message = status, title, message


@dataclass
class AdminContext:
    request: Request
    db: Session
    session: AdminSession
    account: AdminAccount

    @property
    def role(self) -> str:
        return self.account.role

    def can(self, permission: str) -> bool:
        return permissions.can(self.role, permission)

    @property
    def ip(self) -> str | None:
        return client_ip(self.request)


def client_ip(request: Request) -> str | None:
    return request.client.host if request.client else None


def is_htmx(request: Request) -> bool:
    return request.headers.get("hx-request") == "true"


def check_ip_allowed(request: Request) -> None:
    """Defence in depth behind the reverse-proxy rule: optional in-app allow-list (ADMIN_ALLOWED_IPS)."""
    networks = get_settings().admin_allowed_networks
    if not networks:
        return
    ip = client_ip(request)
    try:
        addr = ipaddress.ip_address(ip or "")
        if any(addr in ipaddress.ip_network(n, strict=False) for n in networks):
            return
    except ValueError:
        pass
    raise AdminDenied(404, "Not found", "The page you asked for does not exist.")


def safe_next(target: str | None) -> str:
    """Only same-site admin paths are allowed as a post-sign-in destination."""
    if target and target.startswith("/admin") and not target.startswith("//") and "\\" not in target:
        return target
    return "/admin"


def login_redirect(request: Request) -> AdminRedirect:
    nxt = request.url.path + (f"?{request.url.query}" if request.url.query else "")
    return AdminRedirect(f"/admin/login?next={quote(safe_next(nxt), safe='/')}")


async def current_admin(request: Request, db: Session = Depends(get_db)) -> AdminContext:
    check_ip_allowed(request)
    loaded = admin_access.load_session(db, request.cookies.get(COOKIE_NAME))
    if loaded is None:
        db.commit()  # keep any expiry/revocation just recorded
        raise login_redirect(request)
    sess, acct = loaded
    ctx = AdminContext(request=request, db=db, session=sess, account=acct)
    if request.method in UNSAFE_METHODS:
        form_token = None
        if CSRF_HEADER not in request.headers:  # plain HTML form post: token travels as a hidden field
            form = await request.form()
            value = form.get(CSRF_FIELD)
            form_token = value if isinstance(value, str) else None
        verify_csrf(request, sess, form_token)
        try:
            rate_limit.hit(f"admin-action:{acct.id}", 120, 60)
        except RateLimited as e:
            raise AdminDenied(429, "Too many requests", "Please wait a minute and try again.") from e
    return ctx


def verify_csrf(request: Request, sess: AdminSession, form_value: str | None = None) -> None:
    sent = request.headers.get(CSRF_HEADER) or form_value
    if not sent or not hmac.compare_digest(sent, sess.csrf_token):
        raise AdminDenied(403, "Request blocked", "This request could not be verified. Reload the page and try again.")


def require(permission: str) -> Callable[..., AdminContext]:
    """Dependency: the signed-in admin must hold ``permission`` (and a fresh sign-in where required)."""

    def dep(ctx: AdminContext = Depends(current_admin)) -> AdminContext:
        if not ctx.can(permission):
            raise AdminDenied(403, "Not allowed", "Your admin role does not allow this.")
        if permission in permissions.REAUTH_REQUIRED and ctx.request.method in UNSAFE_METHODS \
                and not admin_access.reauth_fresh(ctx.session):
            referer_path = _referer_path(ctx.request)
            raise AdminRedirect(f"/admin/reauth?next={quote(safe_next(referer_path), safe='/')}")
        return ctx

    return dep


def _referer_path(request: Request) -> str:
    ref = request.headers.get("referer") or ""
    host = request.url.netloc
    marker = f"//{host}"
    if marker in ref:
        return ref.split(marker, 1)[1]
    return "/admin"
