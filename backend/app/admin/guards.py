"""Transport-neutral admin access rules, shared by the server-rendered portal (/admin) and the JSON API
used by the separate AdvocateMate Admin web app (/admin-api/v1).

Each entry point maps the outcome to its own response (redirect/HTML page or JSON error), but the rules
themselves - IP allow-list, CSRF comparison, action rate limit, permission and re-authentication - live
only here.
"""

from __future__ import annotations

import hmac
import ipaddress
import uuid
from typing import Literal

from app.admin import permissions
from app.core import rate_limit
from app.core.config import get_settings
from app.models import AdminSession
from app.services import admin_access

UNSAFE_METHODS = frozenset({"POST", "PUT", "PATCH", "DELETE"})
ACTIONS_PER_MINUTE = 120

Refusal = Literal["forbidden", "reauth_required"]


def ip_allowed(ip: str | None) -> bool:
    """Optional in-app allow-list (ADMIN_ALLOWED_IPS), defence in depth behind the reverse proxy."""
    networks = get_settings().admin_allowed_networks
    if not networks:
        return True
    try:
        addr = ipaddress.ip_address(ip or "")
        return any(addr in ipaddress.ip_network(n, strict=False) for n in networks)
    except ValueError:
        return False


def csrf_valid(sess: AdminSession, sent: str | None) -> bool:
    return bool(sent) and hmac.compare_digest(sent, sess.csrf_token)


def hit_action_limit(admin_id: uuid.UUID) -> None:
    """Raise ``RateLimited`` when an admin makes too many state-changing requests."""
    rate_limit.hit(f"admin-action:{admin_id}", ACTIONS_PER_MINUTE, 60)


def check_permission(role: str, permission: str, sess: AdminSession, method: str) -> Refusal | None:
    """``None`` when allowed; otherwise why not (no permission, or a fresh Google sign-in is needed)."""
    if not permissions.can(role, permission):
        return "forbidden"
    if permission in permissions.REAUTH_REQUIRED and method in UNSAFE_METHODS \
            and not admin_access.reauth_fresh(sess):
        return "reauth_required"
    return None
