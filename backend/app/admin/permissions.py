"""Role-based permissions for the admin portal, enforced on the server for every route and action.

Hiding a button is never the protection: each route declares the permission it needs (see
``dependencies.require``) and the matrix below is the single source of truth (tested role by role).
"""

from __future__ import annotations

# Viewing ---------------------------------------------------------------
VIEW = "view"  # every portal page except Admin access
# Operational actions -----------------------------------------------------
RESYNC_COURT = "court.resync"
REREAD_PDF = "court.reread_pdf"
RETRY_JOB = "job.retry"
RESET_CIRCUIT = "source.reset"
REVOKE_DEVICE = "device.revoke"
TEST_PUSH = "notification.test_push"
MANAGE_USERS = "user.manage"  # disable / enable / sign out all sessions
REVEAL_PII = "pii.reveal"  # unmask an email or device token (reason recorded)
IMPORT_REGISTRY = "registry.import"
SEND_ANNOUNCEMENT = "announcement.send"
MANAGE_ADMINS = "admin.manage"  # add / remove admins, change roles

_SUPPORT = {VIEW, RESYNC_COURT, REREAD_PDF, RETRY_JOB}
_ADMIN = _SUPPORT | {RESET_CIRCUIT, REVOKE_DEVICE, TEST_PUSH, MANAGE_USERS, REVEAL_PII, IMPORT_REGISTRY,
                     SEND_ANNOUNCEMENT}
_OWNER = _ADMIN | {MANAGE_ADMINS}

PERMISSIONS: dict[str, frozenset[str]] = {
    "owner": frozenset(_OWNER),
    "admin": frozenset(_ADMIN),
    "support": frozenset(_SUPPORT),
}

# Actions that also need a fresh Google sign-in (within ADMIN_REAUTH_MINUTES).
REAUTH_REQUIRED = frozenset({IMPORT_REGISTRY, SEND_ANNOUNCEMENT, MANAGE_ADMINS})

ROLE_LABELS = {"owner": "Owner", "admin": "Admin", "support": "Support"}


def can(role: str | None, permission: str) -> bool:
    return permission in PERMISSIONS.get(role or "", frozenset())
