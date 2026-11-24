"""Admin App JSON API: nonce-bound Google sign-in, session cookie, Origin + CSRF, sessions, re-authentication,
proxy gate and configuration guard."""

from __future__ import annotations

from datetime import timedelta

import pytest
from fastapi import Depends, FastAPI
from fastapi.testclient import TestClient
from sqlalchemy import select, update

from app.admin import permissions
from app.admin_api import deps
from app.core.config import Settings, get_settings
from app.core.errors import install_error_handlers
from app.db.base import as_utc, utcnow
from app.db.session import db_session
from app.models import AdminAccount, AdminSession, AuditRecord
from tests.admin.helpers import make_admin
from tests.admin_api.helpers import API, ORIGIN, api_sign_in, get_nonce, google_sign_in, unsafe_headers
from tests.conftest import fake_google_token


def _audit(action: str) -> list[AuditRecord]:
    with db_session() as db:
        return list(db.scalars(select(AuditRecord).where(AuditRecord.action == action)))


def _cookie(client: TestClient, name: str):
    return next((c for c in client.cookies.jar if c.name == name), None)


# ------------------------------------------------------------------ nonce
def test_nonce_sets_short_lived_http_only_cookie(client):
    r = client.get(f"{API}/auth/nonce")
    assert r.status_code == 200
    body = r.json()
    assert body["client_id"] == "test-web-client.apps.googleusercontent.com" and body["expires_in"] == 600
    set_cookie = r.headers["set-cookie"].lower()
    assert "am_admin_nonce=" in set_cookie and "httponly" in set_cookie and "samesite=strict" in set_cookie
    assert "path=/" in set_cookie and "max-age=600" in set_cookie
    assert _cookie(client, "am_admin_nonce").value == body["nonce"]
    assert r.headers["cache-control"] == "no-store" and r.headers["x-robots-tag"] == "noindex, nofollow"
    assert r.headers["content-security-policy"] == "default-src 'none'; frame-ancestors 'none'"


# ------------------------------------------------------------------ sign-in
def test_sign_in_opens_server_side_session(client):
    make_admin("owner@example.com", "owner")
    r = google_sign_in(client, "owner@example.com")
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["account"]["email"] == "owner@example.com" and body["account"]["role"] == "owner"
    assert body["account"]["role_label"] == "Owner" and body["environment"] == "test"
    assert set(body["permissions"]) == set(permissions.PERMISSIONS["owner"])
    assert len(body["csrf_token"]) >= 32 and body["session"]["idle_timeout_minutes"] == 30

    set_cookie = r.headers.get_list("set-cookie")
    session_cookie = next(c for c in set_cookie if c.startswith("am_admin_app=")).lower()
    assert "httponly" in session_cookie and "samesite=strict" in session_cookie and "path=/" in session_cookie
    assert "secure" not in session_cookie  # test environment; staging/production add Secure and __Host-
    assert any(c.startswith("am_admin_nonce=") and "max-age=0" in c.lower() for c in set_cookie)  # single use

    with db_session() as db:
        sess = db.scalar(select(AdminSession))
        assert sess.token_hash != _cookie(client, "am_admin_app").value and len(sess.token_hash) == 64
        assert as_utc(sess.expires_at) - as_utc(sess.created_at) == timedelta(hours=8)
    assert len(_audit("admin_login")) == 1

    me = client.get(f"{API}/auth/session")
    assert me.status_code == 200 and me.json()["csrf_token"] == body["csrf_token"]


@pytest.mark.parametrize("role", ["owner", "admin", "support"])
def test_permissions_follow_the_backend_matrix(client, role):
    body = api_sign_in(client, f"{role}@example.com", role)
    assert set(body["permissions"]) == set(permissions.PERMISSIONS[role])
    assert ("admin.manage" in body["permissions"]) is (role == "owner")


def test_unknown_and_inactive_accounts_are_refused(client):
    r = google_sign_in(client, "stranger@example.com")
    assert r.status_code == 403 and r.json()["error"]["code"] == "not_authorised"
    make_admin("gone@example.com", "admin", active=False)
    r = google_sign_in(client, "gone@example.com")
    assert r.status_code == 403 and r.json()["error"]["code"] == "not_authorised"
    assert _cookie(client, "am_admin_app") is None
    assert {a.details.get("reason") for a in _audit("admin_login_denied")} == {"not_authorised"}


def test_advocate_accounts_cannot_sign_in(client):
    # A signed-in advocate (mobile app) is not an admin: only admin_accounts decides.
    r = google_sign_in(client, "adv.one@example.com", sub="google-sub-12345")
    assert r.status_code == 403 and r.json()["error"]["code"] == "not_authorised"


def test_sign_in_requires_the_browsers_nonce(client):
    make_admin("owner@example.com")
    # No nonce cookie at all (sign-in page never loaded or expired).
    r = client.post(f"{API}/auth/google", headers={"Origin": ORIGIN},
                    json={"credential": fake_google_token("sub-owner@example.com", "owner@example.com", nonce="x")})
    assert r.status_code == 401 and r.json()["error"]["code"] == "sign_in_expired"
    # Token issued for another nonce (e.g. replayed from another browser).
    get_nonce(client)
    r = google_sign_in(client, "owner@example.com", nonce="someone-elses-nonce")
    assert r.status_code == 401 and r.json()["error"]["code"] == "google_token_invalid"
    # Token without any nonce.
    get_nonce(client)
    r = client.post(f"{API}/auth/google", headers={"Origin": ORIGIN},
                    json={"credential": fake_google_token("sub-owner@example.com", "owner@example.com")})
    assert r.status_code == 401
    assert [a.details.get("reason") for a in _audit("admin_login_denied")] == ["nonce_mismatch", "nonce_mismatch"]
    assert _cookie(client, "am_admin_app") is None


@pytest.mark.parametrize("origin", [None, "https://evil.example", "http://localhost:8000"])
def test_sign_in_refuses_other_origins(client, origin):
    make_admin("owner@example.com")
    r = google_sign_in(client, "owner@example.com", origin=origin)
    assert r.status_code == 403 and r.json()["error"]["code"] == "origin_denied"


def test_sign_in_is_rate_limited_per_ip(client):
    for _ in range(10):
        google_sign_in(client, "stranger@example.com")
    r = google_sign_in(client, "stranger@example.com")
    assert r.status_code == 429 and r.json()["error"]["code"] == "rate_limited"


def test_bad_request_body_is_a_validation_error(client):
    get_nonce(client)
    r = client.post(f"{API}/auth/google", headers={"Origin": ORIGIN}, json={"credential": ""})
    assert r.status_code == 422 and r.json()["error"]["code"] == "validation_error"


# ------------------------------------------------------------------ session
def test_no_session_and_ended_session_are_distinguished(client):
    r = client.get(f"{API}/auth/session")
    assert r.status_code == 401 and r.json()["error"]["code"] == "not_authenticated"
    client.cookies.set("am_admin_app", "not-a-real-token", path="/")
    r = client.get(f"{API}/auth/session")
    assert r.status_code == 401 and r.json()["error"]["code"] == "session_expired"


def test_idle_session_expires(client):
    api_sign_in(client, "owner@example.com")
    with db_session() as db:
        db.execute(update(AdminSession).values(last_seen_at=utcnow() - timedelta(minutes=31)))
    r = client.get(f"{API}/auth/session")
    assert r.status_code == 401 and r.json()["error"]["code"] == "session_expired"
    with db_session() as db:
        assert db.scalar(select(AdminSession)).revoke_reason == "idle_timeout"


def test_deactivating_an_admin_ends_their_session(client):
    api_sign_in(client, "support@example.com", "support")
    with db_session() as db:
        db.execute(update(AdminAccount).values(is_active=False))
    assert client.get(f"{API}/auth/session").status_code == 401


def test_portal_cookie_does_not_open_an_api_session(client):
    from tests.admin.helpers import sign_in as portal_sign_in

    portal_sign_in(client, "owner@example.com")
    assert client.get(f"{API}/auth/session").status_code == 401


# ------------------------------------------------------------------ CSRF / Origin on changes
def test_logout_needs_csrf_and_origin(client):
    body = api_sign_in(client, "owner@example.com")
    r = client.post(f"{API}/auth/logout", headers={"Origin": ORIGIN})
    assert r.status_code == 403 and r.json()["error"]["code"] == "csrf_failed"
    r = client.post(f"{API}/auth/logout", headers={"Origin": ORIGIN, "X-CSRF-Token": "wrong"})
    assert r.status_code == 403 and r.json()["error"]["code"] == "csrf_failed"
    r = client.post(f"{API}/auth/logout", headers={"Origin": "https://evil.example",
                                                   "X-CSRF-Token": body["csrf_token"]})
    assert r.status_code == 403 and r.json()["error"]["code"] == "origin_denied"

    r = client.post(f"{API}/auth/logout", headers=unsafe_headers(body))
    assert r.status_code == 204
    assert any("am_admin_app=" in c and "max-age=0" in c.lower() for c in r.headers.get_list("set-cookie"))
    with db_session() as db:
        assert db.scalar(select(AdminSession)).revoke_reason == "signed_out"
    assert len(_audit("admin_logout")) == 1
    assert client.get(f"{API}/auth/session").status_code == 401


# ------------------------------------------------------------------ my sessions
def test_list_and_end_own_sessions(client):
    from app.main import app

    first = api_sign_in(client, "owner@example.com")
    other = TestClient(app)
    api_sign_in(other, "owner@example.com", create=False)
    items = client.get(f"{API}/auth/sessions").json()["items"]
    assert len(items) == 2 and sum(i["current"] for i in items) == 1
    other_id = next(i["id"] for i in items if not i["current"])

    r = client.delete(f"{API}/auth/sessions/{other_id}", headers=unsafe_headers(first))
    assert r.status_code == 204
    assert other.get(f"{API}/auth/session").status_code == 401
    assert client.get(f"{API}/auth/session").status_code == 200
    assert len(_audit("admin_session_revoked")) == 1

    r = client.delete(f"{API}/auth/sessions/{other_id}", headers=unsafe_headers(first))
    assert r.status_code == 404
    r = client.delete(f"{API}/auth/sessions/not-a-uuid", headers=unsafe_headers(first))
    assert r.status_code == 404


def test_cannot_end_another_admins_session(client):
    from app.main import app

    first = api_sign_in(client, "owner@example.com")
    other = TestClient(app)
    api_sign_in(other, "admin@example.com", "admin")
    with db_session() as db:
        acct = db.scalar(select(AdminAccount).where(AdminAccount.email == "admin@example.com"))
        their = db.scalar(select(AdminSession).where(AdminSession.admin_account_id == acct.id))
        their_id = str(their.id)
    r = client.delete(f"{API}/auth/sessions/{their_id}", headers=unsafe_headers(first))
    assert r.status_code == 404
    assert other.get(f"{API}/auth/session").status_code == 200


# ------------------------------------------------------------------ re-authentication
def _reauth(client: TestClient, payload: dict, email: str, sub: str | None = None):
    nonce = get_nonce(client)
    return client.post(f"{API}/auth/reauth", headers=unsafe_headers(payload),
                       json={"credential": fake_google_token(sub or f"sub-{email}", email, nonce=nonce)})


def test_reauth_refreshes_window_for_same_account_only(client):
    body = api_sign_in(client, "owner@example.com")
    with db_session() as db:
        db.execute(update(AdminSession).values(reauth_at=utcnow() - timedelta(hours=1)))
    r = _reauth(client, body, "owner@example.com", sub="sub-someone-else")
    assert r.status_code == 403 and r.json()["error"]["code"] == "different_account"
    assert len(_audit("admin_reauth_denied")) == 1

    r = _reauth(client, body, "owner@example.com")
    assert r.status_code == 200
    from datetime import datetime

    reauth_until = datetime.fromisoformat(r.json()["session"]["reauth_until"])
    assert reauth_until > utcnow() + timedelta(minutes=9)
    assert len(_audit("admin_reauth")) == 1


def test_reauth_needs_nonce_and_csrf(client):
    body = api_sign_in(client, "owner@example.com")
    r = client.post(f"{API}/auth/reauth", headers=unsafe_headers(body),
                    json={"credential": fake_google_token("sub-owner@example.com", "owner@example.com", nonce="x")})
    assert r.status_code == 401 and r.json()["error"]["code"] == "sign_in_expired"
    nonce = get_nonce(client)
    r = client.post(f"{API}/auth/reauth", headers={"Origin": ORIGIN},
                    json={"credential": fake_google_token("sub-owner@example.com", "owner@example.com", nonce=nonce)})
    assert r.status_code == 403 and r.json()["error"]["code"] == "csrf_failed"


# ------------------------------------------------------------------ permission dependency
@pytest.fixture
def guarded_client(engine):
    """A tiny app using the real dependencies, standing in for the module endpoints of later phases."""
    test_app = FastAPI()
    install_error_handlers(test_app)

    @test_app.post(f"{API}/_probe/manage-admins")
    def manage(ctx: deps.AdminApiContext = Depends(deps.require(permissions.MANAGE_ADMINS))):
        return {"ok": True}

    @test_app.post(f"{API}/_probe/retry-job")
    def retry(ctx: deps.AdminApiContext = Depends(deps.require(permissions.RETRY_JOB))):
        return {"ok": True}

    return TestClient(test_app)


def test_require_enforces_role_and_fresh_sign_in(client, guarded_client):
    support = api_sign_in(client, "support@example.com", "support")
    guarded_client.cookies.set("am_admin_app", client.cookies.get("am_admin_app"), path="/")
    r = guarded_client.post(f"{API}/_probe/manage-admins", headers=unsafe_headers(support))
    assert r.status_code == 403 and r.json()["error"]["code"] == "forbidden"
    assert guarded_client.post(f"{API}/_probe/retry-job", headers=unsafe_headers(support)).status_code == 200

    client.cookies.clear()
    owner = api_sign_in(client, "owner@example.com", "owner")
    guarded_client.cookies.set("am_admin_app", client.cookies.get("am_admin_app"), path="/")
    assert guarded_client.post(f"{API}/_probe/manage-admins", headers=unsafe_headers(owner)).status_code == 200
    with db_session() as db:
        db.execute(update(AdminSession).values(reauth_at=utcnow() - timedelta(minutes=11)))
    r = guarded_client.post(f"{API}/_probe/manage-admins", headers=unsafe_headers(owner))
    assert r.status_code == 403 and r.json()["error"]["code"] == "reauth_required"


# ------------------------------------------------------------------ proxy gate and IP allow-list
def test_proxy_secret_hides_the_api(client, monkeypatch):
    secret = "p" * 40
    monkeypatch.setattr(get_settings(), "admin_proxy_secret", secret)
    r = client.get(f"{API}/auth/nonce")
    assert r.status_code == 404 and "set-cookie" not in r.headers
    assert client.get(f"{API}/auth/nonce", headers={"X-Admin-Proxy-Key": "wrong"}).status_code == 404
    assert client.get(f"{API}/auth/nonce", headers={"X-Admin-Proxy-Key": secret}).status_code == 200
    # The mobile API and health checks are unaffected.
    assert client.get("/health/live").status_code == 200


def test_ip_allow_list_applies_to_the_api(client, monkeypatch):
    monkeypatch.setattr(get_settings(), "admin_allowed_ips", "10.0.0.0/8")
    assert client.get(f"{API}/auth/nonce").status_code == 404


def test_portal_headers_are_not_applied_to_the_api(client):
    r = client.get(f"{API}/auth/session")
    assert r.headers["content-security-policy"] == "default-src 'none'; frame-ancestors 'none'"
    assert "accounts.google.com" not in r.headers["content-security-policy"]


# ------------------------------------------------------------------ configuration
def test_cookie_names_use_host_prefix_when_secure(monkeypatch):
    monkeypatch.setattr(get_settings(), "environment", "production")
    assert deps.session_cookie_name() == "__Host-am_admin_app"
    assert deps.nonce_cookie_name() == "__Host-am_admin_nonce"


_PROD = dict(environment="production", jwt_secret="j" * 40, otp_hash_secret="o" * 40, otp_provider="disabled",
             google_client_ids="web-client.apps.googleusercontent.com")


def test_admin_api_is_off_in_production_unless_enabled():
    assert Settings(**_PROD).admin_api_on is False
    assert Settings(environment="test").admin_api_on is True


def test_production_requires_proxy_secret_and_https_origin():
    with pytest.raises(ValueError, match="ADMIN_PROXY_SECRET"):
        Settings(**_PROD, admin_api_enabled=True, admin_app_origins="https://admin.example.com")
    with pytest.raises(ValueError, match="ADMIN_APP_ORIGINS"):
        Settings(**_PROD, admin_api_enabled=True, admin_proxy_secret="s" * 40)
    with pytest.raises(ValueError, match="ADMIN_APP_ORIGINS"):
        Settings(**_PROD, admin_api_enabled=True, admin_proxy_secret="s" * 40,
                 admin_app_origins="http://admin.example.com")
    ok = Settings(**_PROD, admin_api_enabled=True, admin_proxy_secret="s" * 40,
                  admin_app_origins="https://admin.example.com/")
    assert ok.admin_api_on and ok.admin_app_origin_list == ["https://admin.example.com"]
