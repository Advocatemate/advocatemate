"""Jinja2 rendering for the admin portal: navigation, shared page context and display filters."""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo

from fastapi import Request
from fastapi.templating import Jinja2Templates
from starlette.responses import HTMLResponse

from app.admin import permissions
from app.core.config import get_settings
from app.db.base import as_utc

IST = ZoneInfo("Asia/Kolkata")
templates = Jinja2Templates(directory=str(Path(__file__).parent / "templates"))


@dataclass(frozen=True)
class NavItem:
    key: str
    label: str
    href: str
    icon: str
    permission: str = permissions.VIEW
    phase: int | None = None  # set while the module is still being built


NAV: tuple[NavItem, ...] = (
    NavItem("overview", "Overview", "/admin", "overview"),
    NavItem("users", "Users", "/admin/users", "users", phase=3),
    NavItem("registry", "Advocate Registry", "/admin/registry", "registry", phase=4),
    NavItem("court", "Court Data", "/admin/court-data", "court", phase=2),
    NavItem("jobs", "Jobs", "/admin/jobs", "jobs", phase=2),
    NavItem("notifications", "Notifications", "/admin/notifications", "bell", phase=2),
    NavItem("devices", "Devices", "/admin/devices", "device", phase=2),
    NavItem("health", "System Health", "/admin/health", "health", phase=2),
    NavItem("activity", "Activity Log", "/admin/activity", "activity", phase=2),
    NavItem("access", "Admin Access", "/admin/access", "access", permissions.MANAGE_ADMINS),
)
NAV_BY_KEY = {n.key: n for n in NAV}


def environment_label() -> tuple[str, str]:
    env = get_settings().environment
    return {"production": ("PRODUCTION", "danger"), "staging": ("STAGING", "warning")}.get(env, (env.upper(), "info"))


def fmt_dt(value: datetime | None, fmt: str = "%d %b %Y, %I:%M %p") -> str:
    if value is None:
        return "—"
    return as_utc(value).astimezone(IST).strftime(fmt).replace(" 0", " ")


def mask_email(email: str | None) -> str:
    if not email or "@" not in email:
        return "—"
    name, domain = email.split("@", 1)
    return f"{name[:2]}{'•' * max(3, len(name) - 2)}@{domain}"


templates.env.filters["dt"] = fmt_dt
templates.env.filters["mask_email"] = mask_email
templates.env.globals["role_labels"] = permissions.ROLE_LABELS


def render(request: Request, template: str, *, admin=None, status: int = 200, active: str | None = None,
           title: str = "", headers: dict | None = None, **context) -> HTMLResponse:
    env_label, env_tone = environment_label()
    nav = [n for n in NAV if admin is None or admin.can(n.permission)]
    response = templates.TemplateResponse(request, template, {
        "admin": admin,
        "csrf_token": admin.session.csrf_token if admin else "",
        "env_label": env_label,
        "env_tone": env_tone,
        "nav": nav,
        "active": active,
        "page_title": title,
        "perm": permissions,
        **context,
    }, status_code=status)
    for k, v in (headers or {}).items():
        response.headers[k] = v
    return response
