"""Admin portal sign-in, sessions, CSRF, security headers and isolation from the advocate app."""

from datetime import timedelta

from sqlalchemy import select, update

from app.core.config import get_settings
from app.db.base import as_utc, utcnow
from app.db.session import db_session
from app.models import AdminAccount, AdminSession, AuditRecord
from tests.admin.helpers import G_CSRF, csrf_token, google_post, make_admin, sign_in


def _audit(action: str) -> list[AuditRecord]:
    with db_session() as db:
        return list(db.scalars(select(AuditRecord).where(AuditRecord.action == action)))


def test_login_page_and_security_headers(client):
    r = client.get("/admin/login")
    assert r.status_code == 200
    assert 'data-client_id="test-web-client.apps.googleusercontent.com"' in r.text
    assert "/admin/auth/google?next=/admin" in r.text
    csp = r.headers["content-security-policy"]
    assert "https://accounts.google.com/gsi/client" in csp and "frame-ancestors 'none'" in csp
    assert r.headers["x-frame-options"] == "DENY"
    assert r.headers["x-robots-tag"] == "noindex, nofollow"
    assert r.headers["cache-control"] == "no-store"


def test_unauthenticated_requests_go_to_sign_in(client):
    r = client.get("/admin/court-data", follow_redirects=False)
    assert r.status_code == 303 and r.headers["location"] == "/admin/login?next=/admin/court-data"
    r = client.get("/admin", headers={"HX-Request": "true"}, follow_redirects=False)
    assert r.status_code == 200 and r.headers["hx-redirect"].startswith("/admin/login")


def test_sign_in_creates_hashed_server_side_session(client):
    sign_in(client, "owner@example.com")
    cookie = next(c for c in client.cookies.jar if c.name == "am_admin")
    assert cookie.path == "/admin" and cookie.has_nonstandard_attr("HttpOnly")
    raw = client.get("/admin")  # signed-in page
    assert raw.status_code == 200 and "Welcome" in raw.text and "owner@example.com" in raw.text
    with db_session() as db:
        sess = db.scalar(select(AdminSession))
        acct = db.get(AdminAccount, sess.admin_account_id)
        assert sess.token_hash != cookie.value and len(sess.token_hash) == 64  # only the hash is stored
        assert acct.google_sub == "sub-owner@example.com" and acct.last_login_at is not None
        assert sess.expires_at - sess.created_at == timedelta(hours=8)
    logins = _audit("admin_login")
    assert len(logins) == 1 and logins[0].actor_admin_id == acct.id and logins[0].actor_user_id is None


def test_set_cookie_flags(client):
    make_admin("owner@example.com")
    r = google_post(client, "/admin/auth/google", "owner@example.com")
    set_cookie = r.headers["set-cookie"].lower()
    assert "httponly" in set_cookie and "samesite=strict" in set_cookie and "path=/admin" in set_cookie
    assert "secure" not in set_cookie  # test environment; staging/production add Secure


def test_only_authorised_active_accounts_can_sign_in(client):
    r = google_post(client, "/admin/auth/google", "stranger@example.com")
    assert r.headers["location"] == "/admin/login?error=not_authorised" and "am_admin" not in client.cookies
    make_admin("former@example.com", "admin", active=False)
    r = google_post(client, "/admin/auth/google", "former@example.com")
    assert r.headers["location"] == "/admin/login?error=not_authorised"
    denied = _audit("admin_login_denied")
    assert len(denied) == 2 and all(d.details["reason"] == "not_authorised" for d in denied)
    page = client.get("/admin/login?error=not_authorised")
    assert "not authorised to use the AdvocateMate admin portal" in page.text


def test_bound_google_account_cannot_be_reused_by_another_google_identity(client):
    sign_in(client, "owner@example.com")  # binds sub-owner@example.com
    client.cookies.clear()
    r = google_post(client, "/admin/auth/google", "owner@example.com", sub="someone-else")
    assert r.headers["location"] == "/admin/login?error=not_authorised"


def test_google_double_submit_and_unverified_email_are_refused(client):
    make_admin("owner@example.com")
    r = google_post(client, "/admin/auth/google", "owner@example.com", g_csrf="forged")
    assert r.headers["location"] == "/admin/login?error=csrf"
    r = google_post(client, "/admin/auth/google", "owner@example.com", verified=False)
    assert r.headers["location"] == "/admin/login?error=google_token_invalid"
    assert "am_admin" not in client.cookies


def test_next_is_limited_to_admin_paths(client):
    make_admin("owner@example.com")
    r = google_post(client, "/admin/auth/google", "owner@example.com", next_path="https://evil.example/x")
    assert r.headers["location"] == "/admin"
    client.cookies.clear()
    r = google_post(client, "/admin/auth/google", "owner@example.com", next_path="/admin/jobs")
    assert r.headers["location"] == "/admin/jobs"


def test_idle_and_absolute_expiry(client):
    sign_in(client, "owner@example.com")
    with db_session() as db:
        db.execute(update(AdminSession).values(last_seen_at=utcnow() - timedelta(minutes=31)))
    r = client.get("/admin", follow_redirects=False)
    assert r.status_code == 303
    with db_session() as db:
        assert db.scalar(select(AdminSession)).revoke_reason == "idle_timeout"

    client.cookies.clear()
    sign_in(client, "owner@example.com", create=False)
    with db_session() as db:
        db.execute(update(AdminSession).where(AdminSession.revoked_at.is_(None))
                   .values(expires_at=utcnow() - timedelta(seconds=1)))
    assert client.get("/admin", follow_redirects=False).status_code == 303


def test_logout_needs_csrf_and_revokes_the_session(client):
    sign_in(client, "owner@example.com")
    r = client.post("/admin/logout", data={}, follow_redirects=False)
    assert r.status_code == 403 and "could not be verified" in r.text
    r = client.post("/admin/logout", data={"csrf_token": csrf_token("owner@example.com")}, follow_redirects=False)
    assert r.status_code == 303 and r.headers["location"] == "/admin/login"
    with db_session() as db:
        assert db.scalar(select(AdminSession)).revoke_reason == "signed_out"
    assert client.get("/admin", follow_redirects=False).status_code == 303
    assert len(_audit("admin_logout")) == 1


def test_sign_in_attempts_are_rate_limited(client):
    make_admin("owner@example.com")
    for _ in range(10):
        google_post(client, "/admin/auth/google", "stranger@example.com")
    r = google_post(client, "/admin/auth/google", "owner@example.com")
    assert r.headers["location"] == "/admin/login?error=rate_limited"


def test_advocate_app_tokens_do_not_open_the_portal(client, user_headers):
    r = client.get("/admin", headers=user_headers, follow_redirects=False)
    assert r.status_code == 303 and r.headers["location"].startswith("/admin/login")


def test_portal_is_not_in_the_api_documentation(client):
    paths = client.get("/openapi.json").json()["paths"]
    assert not any(p.startswith("/admin") for p in paths)


def test_optional_ip_allow_list(client):
    s = get_settings()
    s.admin_allowed_ips = "10.0.0.0/8"
    try:
        assert client.get("/admin/login").status_code == 404
    finally:
        s.admin_allowed_ips = ""
    assert client.get("/admin/login").status_code == 200


def test_static_files_are_served_and_cacheable(client):
    r = client.get("/admin/static/css/admin.css")
    assert r.status_code == 200 and "--navy" in r.text and r.headers.get("cache-control") != "no-store"
    assert client.get("/admin/static/vendor/htmx.min.js").status_code == 200


def test_reauth_with_same_google_account(client):
    sign_in(client, "owner@example.com")
    with db_session() as db:
        db.execute(update(AdminSession).values(reauth_at=utcnow() - timedelta(minutes=30)))
    assert "Confirm it" in client.get("/admin/reauth?next=/admin/access").text
    r = google_post(client, "/admin/auth/reauth", "owner@example.com", sub="other-sub", next_path="/admin/access")
    assert "error=different_account" in r.headers["location"]
    r = google_post(client, "/admin/auth/reauth", "owner@example.com", next_path="/admin/access")
    assert r.headers["location"] == "/admin/access"
    with db_session() as db:
        assert utcnow() - as_utc(db.scalar(select(AdminSession)).reauth_at) < timedelta(seconds=30)
    assert len(_audit("admin_reauth")) == 1 and len(_audit("admin_reauth_denied")) == 1
    assert G_CSRF  # double-submit cookie was required for both posts
