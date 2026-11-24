"""Role permission matrix: enforced on the server for every page and action."""

import pytest
from sqlalchemy import update

from app.admin import permissions as p
from app.db.session import db_session
from app.models import AdminAccount
from tests.admin.helpers import htmx, make_admin, sign_in

VIEW_PAGES = ["/admin", "/admin/users", "/admin/registry", "/admin/court-data", "/admin/jobs",
              "/admin/notifications", "/admin/devices", "/admin/health", "/admin/activity"]


def test_matrix_is_exactly_as_specified():
    assert p.PERMISSIONS["support"] == {p.VIEW, p.RESYNC_COURT, p.REREAD_PDF, p.RETRY_JOB}
    assert p.PERMISSIONS["admin"] == p.PERMISSIONS["support"] | {
        p.RESET_CIRCUIT, p.REVOKE_DEVICE, p.TEST_PUSH, p.MANAGE_USERS, p.REVEAL_PII, p.IMPORT_REGISTRY,
        p.SEND_ANNOUNCEMENT}
    assert p.PERMISSIONS["owner"] == p.PERMISSIONS["admin"] | {p.MANAGE_ADMINS}
    assert not p.can("support", p.MANAGE_USERS) and not p.can("support", p.IMPORT_REGISTRY)
    assert not p.can("admin", p.MANAGE_ADMINS) and not p.can(None, p.VIEW) and not p.can("advocate", p.VIEW)
    assert p.REAUTH_REQUIRED == {p.IMPORT_REGISTRY, p.SEND_ANNOUNCEMENT, p.MANAGE_ADMINS}


@pytest.mark.parametrize("role", ["owner", "admin", "support"])
def test_every_role_can_view_monitoring_pages(client, role):
    sign_in(client, f"{role}@example.com", role)
    for path in VIEW_PAGES:
        assert client.get(path).status_code == 200, (role, path)


@pytest.mark.parametrize(("role", "allowed"), [("owner", True), ("admin", False), ("support", False)])
def test_only_the_owner_reaches_admin_access(client, role, allowed):
    sign_in(client, f"{role}@example.com", role)
    page = client.get("/admin/access")
    assert page.status_code == (200 if allowed else 403)
    nav = client.get("/admin").text
    assert ('href="/admin/access"' in nav) is allowed  # menu hides it, but the server is what enforces it
    r = client.post("/admin/access", data={"email": "new@example.com", "role": "support"},
                    headers=htmx(f"{role}@example.com"))
    if allowed:
        assert "new@example.com" in r.text
    else:
        assert "new@example.com" not in r.text and "does not allow" in r.headers["hx-trigger"]


def test_deactivated_admin_loses_access_immediately(client):
    sign_in(client, "admin@example.com", "admin")
    owner_id = make_admin("owner@example.com")
    assert owner_id
    with db_session() as db:
        db.execute(update(AdminAccount).where(AdminAccount.email == "admin@example.com").values(is_active=False))
    assert client.get("/admin", follow_redirects=False).status_code == 303
