"""Admin Access management (owner only): add, change role, deactivate - audited, re-authenticated."""

import json
import uuid
from datetime import timedelta

import pytest
from sqlalchemy import select, text, update

from app.db import audit_guard
from app.db.base import utcnow
from app.db.session import db_session
from app.models import AdminAccount, AdminSession, AuditRecord
from scripts import admin_accounts as cli
from tests.admin.helpers import csrf_token, htmx, make_admin, sign_in

OWNER = "owner@example.com"


def _acct(email):
    with db_session() as db:
        a = db.scalar(select(AdminAccount).where(AdminAccount.email == email))
        return (a.id, a.role, a.is_active) if a else None


def _toast(r):
    return json.loads(r.headers["hx-trigger"])["toast"]


def test_owner_adds_admin_with_audit(client):
    sign_in(client, OWNER)
    r = client.post("/admin/access", data={"email": "New.Admin@Example.com", "role": "admin"}, headers=htmx(OWNER))
    assert r.status_code == 200 and "new.admin@example.com" in r.text
    assert _toast(r) == {"kind": "success", "message": "Added new.admin@example.com as Admin."}
    new_id, role, active = _acct("new.admin@example.com")
    assert role == "admin" and active
    owner_id = _acct(OWNER)[0]
    with db_session() as db:
        rec = db.scalar(select(AuditRecord).where(AuditRecord.action == "admin_account_created",
                                                  AuditRecord.target_id == str(new_id)))
        assert rec.actor_admin_id == owner_id and rec.details["role"] == "admin" and rec.details["via"] == "portal"


def test_duplicates_and_bad_input_are_refused(client):
    sign_in(client, OWNER)
    r = client.post("/admin/access", data={"email": OWNER, "role": "admin"}, headers=htmx(OWNER))
    assert _toast(r)["kind"] == "error" and "already has" in _toast(r)["message"]
    r = client.post("/admin/access", data={"email": "x@example.com", "role": "superuser"}, headers=htmx(OWNER))
    assert "owner, admin or support" in _toast(r)["message"]
    r = client.post("/admin/access", data={"email": "not-an-email", "role": "admin"}, headers=htmx(OWNER))
    assert "valid Google account email" in _toast(r)["message"]


def test_sensitive_changes_need_a_fresh_google_sign_in(client):
    sign_in(client, OWNER)
    with db_session() as db:
        db.execute(update(AdminSession).values(reauth_at=utcnow() - timedelta(minutes=11)))
    headers = htmx(OWNER) | {"Referer": "http://testserver/admin/access"}
    r = client.post("/admin/access", data={"email": "late@example.com", "role": "support"}, headers=headers)
    assert r.headers["hx-redirect"] == "/admin/reauth?next=/admin/access"
    assert _acct("late@example.com") is None


def test_missing_csrf_changes_nothing(client):
    sign_in(client, OWNER)
    r = client.post("/admin/access", data={"email": "x@example.com", "role": "support"}, headers={"HX-Request": "true"})
    assert "could not be verified" in _toast(r)["message"] and _acct("x@example.com") is None
    r = client.post("/admin/access", data={"email": "x@example.com", "role": "support",
                                           "csrf_token": "wrong"}, follow_redirects=False)
    assert r.status_code == 403 and _acct("x@example.com") is None


def test_role_changes_and_last_owner_protection(client):
    sign_in(client, OWNER)
    other = make_admin("helper@example.com", "support")
    r = client.post(f"/admin/access/{other}/role", data={"role": "admin"}, headers=htmx(OWNER))
    assert _toast(r)["message"] == "helper@example.com is now Admin." and _acct("helper@example.com")[1] == "admin"
    owner_id = _acct(OWNER)[0]
    r = client.post(f"/admin/access/{owner_id}/role", data={"role": "admin"}, headers=htmx(OWNER))
    assert "at least one active owner" in _toast(r)["message"] and _acct(OWNER)[1] == "owner"
    with db_session() as db:
        change = db.scalar(select(AuditRecord).where(AuditRecord.action == "admin_role_changed"))
        assert change.details == {"before": "support", "after": "admin"}


def test_deactivation_signs_the_admin_out_and_self_deactivation_is_refused(client):
    sign_in(client, OWNER)
    target = make_admin("leaver@example.com", "admin")
    with db_session() as db:
        db.add(AdminSession(admin_account_id=_acct("leaver@example.com")[0], token_hash="0" * 64,
                            csrf_token="c", expires_at=utcnow() + timedelta(hours=1)))
    r = client.post(f"/admin/access/{target}/active", data={"active": "false"}, headers=htmx(OWNER))
    assert _toast(r)["message"] == "leaver@example.com deactivated." and _acct("leaver@example.com")[2] is False
    with db_session() as db:
        assert db.scalar(select(AdminSession).where(AdminSession.token_hash == "0" * 64)).revoke_reason \
            == "account_deactivated"
    owner_id = _acct(OWNER)[0]
    make_admin("second.owner@example.com", "owner")
    r = client.post(f"/admin/access/{owner_id}/active", data={"active": "false"}, headers=htmx(OWNER))
    assert "cannot deactivate your own" in _toast(r)["message"] and _acct(OWNER)[2] is True
    r = client.post(f"/admin/access/{target}/active", data={"active": "true"}, headers=htmx(OWNER))
    assert _acct("leaver@example.com")[2] is True


def test_unknown_account_id(client):
    sign_in(client, OWNER)
    r = client.post("/admin/access/not-a-uuid/role", data={"role": "admin", "csrf_token": csrf_token(OWNER)},
                    follow_redirects=False)
    assert r.status_code == 404


# ------------------------------------------------------------------ command-line setup
def test_command_line_creates_the_first_owner(capsys):
    assert cli.main(["list"]) == 0 and "No admin accounts yet" in capsys.readouterr().out
    assert cli.main(["add", "First.Owner@example.com", "--role", "owner"]) == 0
    assert _acct("first.owner@example.com")[1] == "owner"
    assert cli.main(["add", "first.owner@example.com", "--role", "admin"]) == 1  # duplicate
    assert cli.main(["deactivate", "first.owner@example.com"]) == 1  # last owner stays
    assert cli.main(["set-role", "nobody@example.com", "admin"]) == 1
    with db_session() as db:
        rec = db.scalar(select(AuditRecord).where(AuditRecord.action == "admin_account_created"))
        assert rec.details["via"] == "cli" and rec.actor_admin_id is None


# ------------------------------------------------------------------ audit records are append-only (PostgreSQL)
def test_audit_records_cannot_be_changed_or_deleted(engine):
    if engine.dialect.name != "postgresql":
        pytest.skip("database rule is PostgreSQL-only")
    from app.services import audit

    admin_id = make_admin(OWNER)
    with db_session() as db:
        audit.record(db, "admin_test_action", actor_admin=uuid.UUID(admin_id), target_type="test")
    with engine.begin() as conn:
        conn.exec_driver_sql(audit_guard.CREATE_SQL)
    try:
        with db_session() as db:
            rec_id = db.scalar(select(AuditRecord.id).where(AuditRecord.action == "admin_test_action"))
        for stmt, params in (("UPDATE audit_records SET action = 'tampered' WHERE id = :id", {}),
                             ("UPDATE audit_records SET details = CAST(:d AS JSONB) WHERE id = :id", {"d": '{"x": 1}'}),
                             ("UPDATE audit_records SET actor_admin_id = NULL, action = 'x' WHERE id = :id", {}),
                             ("DELETE FROM audit_records WHERE id = :id", {})):
            with pytest.raises(Exception, match="append-only"), engine.begin() as conn:
                conn.execute(text(stmt), {"id": rec_id, **params})
        with engine.begin() as conn:
            row = conn.execute(text("SELECT action, actor_admin_id FROM audit_records WHERE id = :id"),
                               {"id": rec_id}).one()
            assert row.action == "admin_test_action" and str(row.actor_admin_id) == admin_id
            # deleting the admin account may only clear the actor reference (ON DELETE SET NULL)
            conn.execute(text("DELETE FROM admin_accounts WHERE id = :a"), {"a": admin_id})
            assert conn.execute(text("SELECT actor_admin_id FROM audit_records WHERE id = :id"),
                                {"id": rec_id}).scalar() is None
    finally:
        with engine.begin() as conn:
            conn.exec_driver_sql(audit_guard.DROP_SQL)
