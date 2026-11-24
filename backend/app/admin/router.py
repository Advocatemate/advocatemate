"""Admin portal routes, served at /admin (never listed in the public API documentation)."""

from __future__ import annotations

import hmac
import json
import uuid
from pathlib import Path

from fastapi import APIRouter, Depends, FastAPI, Form, Request
from fastapi.responses import HTMLResponse, RedirectResponse, Response
from fastapi.staticfiles import StaticFiles
from sqlalchemy.orm import Session

from app.admin import permissions
from app.admin.dependencies import (
    COOKIE_NAME,
    COOKIE_PATH,
    AdminContext,
    AdminDenied,
    AdminRedirect,
    check_ip_allowed,
    client_ip,
    current_admin,
    is_htmx,
    require,
    safe_next,
)
from app.admin.templating import NAV_BY_KEY, render
from app.core import rate_limit
from app.core.config import get_settings
from app.core.errors import RateLimited
from app.db.base import as_utc
from app.db.session import get_db
from app.models import ADMIN_ROLES, AdminAccount
from app.services import admin_access

router = APIRouter(prefix="/admin", include_in_schema=False)

# Content-Security-Policy: own files only; the sign-in pages also allow Google's sign-in script.
CSP = ("default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; font-src 'self'; "
       "connect-src 'self'; frame-ancestors 'none'; form-action 'self'; base-uri 'none'; object-src 'none'")
CSP_GOOGLE = ("default-src 'self'; script-src 'self' https://accounts.google.com/gsi/client; "
              # Google's sign-in library sets inline styles; allowed on the two sign-in pages only (scripts stay strict).
              "style-src 'self' 'unsafe-inline' https://accounts.google.com/gsi/style; "
              "img-src 'self' data: https://*.googleusercontent.com; "
              "font-src 'self'; frame-src https://accounts.google.com/gsi/; "
              "connect-src 'self' https://accounts.google.com/gsi/; frame-ancestors 'none'; "
              "form-action 'self'; base-uri 'none'; object-src 'none'")

LOGIN_ERRORS = {
    "not_authorised": admin_access.DENIED,
    "google_token_invalid": "Google sign-in could not be verified. Please try again.",
    "csrf": "The sign-in request could not be verified. Please try again.",
    "rate_limited": "Too many sign-in attempts. Please wait a few minutes and try again.",
    "expired": "Your session ended. Please sign in again.",
    "different_account": "Please confirm with the same Google account you signed in with.",
}


# ------------------------------------------------------------------ helpers
def _toast(kind: str, message: str) -> dict[str, str]:
    return {"HX-Trigger": json.dumps({"toast": {"kind": kind, "message": message}})}


def _google_page(request: Request, template: str, **context) -> HTMLResponse:
    resp = render(request, template, client_id=get_settings().admin_client_id, **context)
    resp.headers["Content-Security-Policy"] = CSP_GOOGLE
    return resp


def _check_google_csrf(request: Request, g_csrf_token: str | None) -> bool:
    """Google's double-submit check: the posted token must equal the g_csrf_token cookie it set."""
    cookie = request.cookies.get("g_csrf_token")
    return bool(cookie and g_csrf_token and hmac.compare_digest(cookie, g_csrf_token))


def _set_session_cookie(response: Response, token: str) -> None:
    s = get_settings()
    response.set_cookie(COOKIE_NAME, token, httponly=True, secure=s.environment in ("staging", "production"),
                        samesite="strict", path=COOKIE_PATH, max_age=s.admin_session_max_hours * 3600)


# ------------------------------------------------------------------ sign-in
@router.get("/login")
def login_page(request: Request, next: str | None = None, error: str | None = None,
               db: Session = Depends(get_db)):
    check_ip_allowed(request)
    if admin_access.load_session(db, request.cookies.get(COOKIE_NAME)) is not None:
        return RedirectResponse(safe_next(next), status_code=303)
    return _google_page(request, "login.html", title="Sign in", next=safe_next(next),
                        error=LOGIN_ERRORS.get(error or ""), login_uri=str(request.url_for("admin_google_signin")))


@router.post("/auth/google", name="admin_google_signin")
def google_signin(request: Request, credential: str = Form(""), g_csrf_token: str = Form(""),
                  next: str = "/admin", db: Session = Depends(get_db)):
    check_ip_allowed(request)
    ip = client_ip(request)
    try:
        rate_limit.hit(f"admin-login-ip:{ip or 'unknown'}", 10, 600)
    except RateLimited:
        return RedirectResponse("/admin/login?error=rate_limited", status_code=303)
    if not _check_google_csrf(request, g_csrf_token):
        return RedirectResponse("/admin/login?error=csrf", status_code=303)
    try:
        new = admin_access.sign_in(db, credential, ip=ip, user_agent=request.headers.get("user-agent"))
    except admin_access.AdminAccessError as e:
        return RedirectResponse(f"/admin/login?error={e.code}", status_code=303)
    resp = RedirectResponse(safe_next(next), status_code=303)
    _set_session_cookie(resp, new.token)
    return resp


@router.get("/reauth")
def reauth_page(request: Request, next: str | None = None, error: str | None = None,
                ctx: AdminContext = Depends(current_admin)):
    return _google_page(request, "reauth.html", admin=ctx, title="Confirm it's you", next=safe_next(next),
                        reauth_minutes=get_settings().admin_reauth_minutes,
                        error=LOGIN_ERRORS.get(error or ""), login_uri=str(request.url_for("admin_google_reauth")))


@router.post("/auth/reauth", name="admin_google_reauth")
def google_reauth(request: Request, credential: str = Form(""), g_csrf_token: str = Form(""), next: str = "/admin",
                  db: Session = Depends(get_db)):
    # Google posts this form itself, so the portal's CSRF token cannot be attached: the session cookie
    # (SameSite=Strict) plus Google's double-submit token protect it instead.
    check_ip_allowed(request)
    loaded = admin_access.load_session(db, request.cookies.get(COOKIE_NAME))
    if loaded is None:
        return RedirectResponse("/admin/login?error=expired", status_code=303)
    if not _check_google_csrf(request, g_csrf_token):
        return RedirectResponse(f"/admin/reauth?error=csrf&next={safe_next(next)}", status_code=303)
    sess, acct = loaded
    try:
        admin_access.reauthenticate(db, sess, acct, credential, ip=client_ip(request))
    except admin_access.AdminAccessError as e:
        db.commit()
        return RedirectResponse(f"/admin/reauth?error={e.code}&next={safe_next(next)}", status_code=303)
    return RedirectResponse(safe_next(next), status_code=303)


@router.post("/logout")
def logout(ctx: AdminContext = Depends(current_admin)):
    admin_access.sign_out(ctx.db, ctx.session, ctx.account, ip=ctx.ip)
    resp = RedirectResponse("/admin/login", status_code=303)
    resp.delete_cookie(COOKIE_NAME, path=COOKIE_PATH)
    return resp


# ------------------------------------------------------------------ pages
@router.get("")
@router.get("/")
def overview(request: Request, ctx: AdminContext = Depends(require(permissions.VIEW))):
    return render(request, "overview.html", admin=ctx, active="overview", title="Overview",
                  session_expires=as_utc(ctx.session.expires_at))


def _coming_soon(key: str):
    item = NAV_BY_KEY[key]

    def page(request: Request, ctx: AdminContext = Depends(require(item.permission))):
        return render(request, "coming_soon.html", admin=ctx, active=key, title=item.label, item=item)

    return page


for _key in ("users", "registry", "court", "jobs", "notifications", "devices", "health", "activity"):
    router.add_api_route(NAV_BY_KEY[_key].href.removeprefix("/admin"), _coming_soon(_key), methods=["GET"])


# ------------------------------------------------------------------ admin access (owner only)
def _access_page(request: Request, ctx: AdminContext, *, status: int = 200, headers: dict | None = None,
                 partial: bool = False):
    accounts = admin_access.list_accounts(ctx.db)
    by_id = {a.id: a for a in accounts}
    return render(request, "access/_table.html" if partial else "access/index.html", admin=ctx, active="access",
                  title="Admin Access", accounts=accounts, by_id=by_id, roles=ADMIN_ROLES, status=status,
                  headers=headers)


@router.get("/access")
def access_index(request: Request, ctx: AdminContext = Depends(require(permissions.MANAGE_ADMINS))):
    return _access_page(request, ctx)


@router.post("/access")
def access_create(request: Request, email: str = Form(""), role: str = Form("support"),
                  ctx: AdminContext = Depends(require(permissions.MANAGE_ADMINS))):
    try:
        acct = admin_access.create_account(ctx.db, email, role, by=ctx.account, ip=ctx.ip)
    except admin_access.AdminAccessError as e:
        return _access_page(request, ctx, partial=True, headers=_toast("error", e.message))
    return _access_page(request, ctx, partial=True,
                        headers=_toast("success", f"Added {acct.email} as {permissions.ROLE_LABELS[acct.role]}."))


def _target(ctx: AdminContext, account_id: str) -> AdminAccount:
    try:
        acct = ctx.db.get(AdminAccount, uuid.UUID(account_id))
    except ValueError:
        acct = None
    if acct is None:
        raise AdminDenied(404, "Not found", "That admin account does not exist.")
    return acct


@router.post("/access/{account_id}/role")
def access_role(request: Request, account_id: str, role: str = Form(...),
                ctx: AdminContext = Depends(require(permissions.MANAGE_ADMINS))):
    acct = _target(ctx, account_id)
    try:
        admin_access.set_role(ctx.db, acct, role, by=ctx.account, ip=ctx.ip)
    except admin_access.AdminAccessError as e:
        return _access_page(request, ctx, partial=True, headers=_toast("error", e.message))
    return _access_page(request, ctx, partial=True,
                        headers=_toast("success", f"{acct.email} is now {permissions.ROLE_LABELS[acct.role]}."))


@router.post("/access/{account_id}/active")
def access_active(request: Request, account_id: str, active: str = Form(...),
                  ctx: AdminContext = Depends(require(permissions.MANAGE_ADMINS))):
    acct = _target(ctx, account_id)
    try:
        admin_access.set_active(ctx.db, acct, active == "true", by=ctx.account, ip=ctx.ip)
    except admin_access.AdminAccessError as e:
        return _access_page(request, ctx, partial=True, headers=_toast("error", e.message))
    verb = "reactivated" if acct.is_active else "deactivated"
    return _access_page(request, ctx, partial=True, headers=_toast("success", f"{acct.email} {verb}."))


# ------------------------------------------------------------------ errors, headers, static
def _security_headers(response: Response, path: str) -> None:
    response.headers.setdefault("Content-Security-Policy", CSP)
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["X-Robots-Tag"] = "noindex, nofollow"
    response.headers["Permissions-Policy"] = "camera=(), microphone=(), geolocation=(), payment=()"
    response.headers["Cross-Origin-Opener-Policy"] = "same-origin-allow-popups"
    if not path.startswith("/admin/static/"):
        response.headers["Cache-Control"] = "no-store"


def install(app: FastAPI) -> None:
    """Mount the portal on the FastAPI app."""
    app.include_router(router)
    app.mount("/admin/static", StaticFiles(directory=str(Path(__file__).parent / "static")), name="admin_static")

    @app.exception_handler(AdminRedirect)
    async def _redirect(request: Request, exc: AdminRedirect):
        if is_htmx(request):
            return Response(status_code=200, headers={"HX-Redirect": exc.location})
        return RedirectResponse(exc.location, status_code=303)

    @app.exception_handler(AdminDenied)
    async def _denied(request: Request, exc: AdminDenied):
        if is_htmx(request):
            return Response(status_code=200, headers=_toast("error", exc.message) | {"HX-Reswap": "none"})
        return render(request, "error.html", status=exc.status, title=exc.title, message=exc.message)

    @app.middleware("http")
    async def admin_headers(request: Request, call_next):
        response = await call_next(request)
        path = request.url.path
        if path == "/admin" or path.startswith("/admin/"):  # not /admin-api (the Admin App API sets its own)
            _security_headers(response, request.url.path)
        return response
