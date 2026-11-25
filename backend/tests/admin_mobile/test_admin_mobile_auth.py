"""Admin phone app API: one-time challenge sign-in, bearer access tokens, single-use refresh tokens with reuse
detection, session limits and revocation, re-authentication, roles - and isolation from the browser sessions."""

from __future__ import annotations

from datetime import timedelta

import pytest
from fastapi import Depends, FastAPI
from fastapi.testclient import TestClient
from sqlalchemy import select, update

from app.admin import permissions
from app.admin_mobile import deps
from app.core.config import Settings, get_settings
from app.core.errors import install_error_handlers
from app.db.base import as_utc, utcnow
from app.db.session import db_session
from app.models import AdminAccount, AdminAuthChallenge, AdminRefreshToken, AdminSession, AuditRecord
from app.services import admin_mobile_auth
from tests.admin.helpers import make_admin
from tests.admin_mobile.helpers import API, DEVICE, bearer, challenge, google_sign_in, mobile_sign_in
from tests.conftest import fake_google_audiences, fake_google_token


def _audit(action: str) -> list[AuditRecord]:
    with db_session() as db:
        return list(db.scalars(select(AuditRecord).where(AuditRecord.action == action)))


def _session() -> AdminSession:
    with db_session() as db:
        return db.scalar(select(AdminSession).order_by(AdminSession.created_at.desc()))


def _error(r) -> str:
    return r.json()["error"]["code"]


# ------------------------------------------------------------------ sign-in
def test_challenge_is_one_time_and_stored_hashed(client):
    ch = challenge(client)
    assert len(ch["nonce"]) >= 40 and ch["expires_in"] == 300
    with db_session() as db:
        row = db.scalar(select(AdminAuthChallenge))
        assert row.nonce_hash != ch["nonce"] and len(row.nonce_hash) == 64 and row.purpose == "signin"


def test_sign_in_returns_tokens_and_opens_a_mobile_session(client):
    tokens = mobile_sign_in(client, "owner@example.com")
    assert tokens["token_type"] == "bearer" and 0 < tokens["expires_in"] <= 15 * 60
    assert len(tokens["access_token"]) >= 40 and len(tokens["refresh_token"]) >= 60
    s = tokens["session"]
    assert s["account"]["email"] == "owner@example.com" and s["session"]["client"] == "mobile"
    assert s["session"]["platform"] == "android"
    assert set(s["permissions"]) == set(permissions.PERMISSIONS["owner"])
    assert "csrf_token" not in s  # bearer clients need no CSRF token

    sess = _session()
    assert sess.client == "mobile" and sess.device_name == "Test Phone" and sess.app_version == "0.1.0+1"
    assert sess.installation_id == DEVICE["installation_id"]
    assert sess.token_hash != tokens["access_token"] and len(sess.token_hash) == 64
    with db_session() as db:
        refresh_rows = list(db.scalars(select(AdminRefreshToken)))
    assert len(refresh_rows) == 1 and refresh_rows[0].token_hash != tokens["refresh_token"]
    login = _audit("admin_login")
    assert len(login) == 1 and login[0].details["client"] == "mobile"
    # The admin app's own Google client IDs are the accepted audiences (development falls back to GOOGLE_CLIENT_IDS).
    assert fake_google_audiences[-1] == get_settings().admin_mobile_audiences

    r = client.get(f"{API}/auth/session", headers=bearer(tokens))
    assert r.status_code == 200 and r.json()["account"]["role"] == "owner"
    assert r.headers["cache-control"] == "no-store"


def test_admin_audiences_are_separate_from_the_advocate_app(client, monkeypatch):
    monkeypatch.setattr(get_settings(), "admin_mobile_google_client_ids", "admin-server.apps.googleusercontent.com")
    mobile_sign_in(client, "owner@example.com")
    assert fake_google_audiences[-1] == ["admin-server.apps.googleusercontent.com"]


def test_unknown_inactive_and_advocate_accounts_are_refused(client):
    assert _error(r := google_sign_in(client, "stranger@example.com")) == "not_authorised" and r.status_code == 403
    make_admin("gone@example.com", "admin", active=False)
    assert google_sign_in(client, "gone@example.com").status_code == 403
    assert google_sign_in(client, "adv.one@example.com", sub="google-sub-12345").status_code == 403
    with db_session() as db:
        assert db.scalar(select(AdminSession)) is None


def test_challenge_cannot_be_replayed(client):
    make_admin("owner@example.com")
    ch = challenge(client)
    assert google_sign_in(client, "owner@example.com", ch=ch).status_code == 200
    again = google_sign_in(client, "owner@example.com", ch=ch)
    assert again.status_code == 401 and _error(again) == "sign_in_expired"
    assert [r.details["reason"] for r in _audit("admin_login_denied")] == ["challenge_reused"]  # replay audited


def test_failed_attempt_uses_up_the_challenge(client):
    make_admin("owner@example.com")
    ch = challenge(client)
    assert google_sign_in(client, "owner@example.com", ch=ch, nonce="not-the-challenge-nonce").status_code == 401
    # Even with the right nonce now, the challenge is gone.
    r = google_sign_in(client, "owner@example.com", ch=ch)
    assert r.status_code == 401 and _error(r) == "sign_in_expired"
    assert [a.details.get("reason") for a in _audit("admin_login_denied")] == ["nonce_mismatch", "challenge_reused"]


@pytest.mark.parametrize("nonce", ["", "someone-elses-nonce"])
def test_token_must_carry_the_challenge_nonce(client, nonce):
    make_admin("owner@example.com")
    r = google_sign_in(client, "owner@example.com", nonce=nonce)
    assert r.status_code == 401 and _error(r) == "google_token_invalid"


def test_expired_and_unknown_challenges_are_refused(client):
    make_admin("owner@example.com")
    ch = challenge(client)
    with db_session() as db:
        db.execute(update(AdminAuthChallenge).values(expires_at=utcnow() - timedelta(seconds=1)))
    assert _error(google_sign_in(client, "owner@example.com", ch=ch)) == "sign_in_expired"
    bogus = {"challenge_id": "not-a-uuid", "nonce": ch["nonce"]}
    assert _error(google_sign_in(client, "owner@example.com", ch=bogus)) == "sign_in_expired"
    assert {r.details["reason"] for r in _audit("admin_login_denied")} == {"challenge_expired", "challenge_unknown"}


def test_device_details_are_validated(client):
    make_admin("owner@example.com")
    r = google_sign_in(client, "owner@example.com", device={**DEVICE, "platform": "windows"})
    assert r.status_code == 422
    r = google_sign_in(client, "owner@example.com", device={**DEVICE, "installation_id": "x"})
    assert r.status_code == 422


def test_sign_in_is_rate_limited_per_ip(client):
    for _ in range(10):
        google_sign_in(client, "stranger@example.com")
    assert google_sign_in(client, "stranger@example.com").status_code == 429


# ------------------------------------------------------------------ bearer access
def test_requests_need_a_valid_bearer_token(client):
    assert _error(client.get(f"{API}/auth/session")) == "not_authenticated"
    assert _error(client.get(f"{API}/auth/session", headers={"Authorization": "Bearer nonsense"})) \
        == "session_expired"
    assert _error(client.get(f"{API}/auth/session", headers={"Authorization": "Basic abc"})) == "not_authenticated"


def test_state_changes_need_no_csrf_token_or_origin(client):
    tokens = mobile_sign_in(client, "owner@example.com")
    r = client.post(f"{API}/auth/logout", headers=bearer(tokens))
    assert r.status_code == 204


def test_expired_access_token_asks_for_refresh_without_ending_the_session(client):
    tokens = mobile_sign_in(client, "owner@example.com")
    with db_session() as db:
        db.execute(update(AdminSession).values(token_expires_at=utcnow() - timedelta(seconds=1)))
    r = client.get(f"{API}/auth/session", headers=bearer(tokens))
    assert r.status_code == 401 and _error(r) == "token_expired"
    assert _session().revoked_at is None


# ------------------------------------------------------------------ refresh
def test_refresh_rotates_both_tokens(client):
    first = mobile_sign_in(client, "owner@example.com")
    r = client.post(f"{API}/auth/refresh", json={"refresh_token": first["refresh_token"]})
    assert r.status_code == 200
    second = r.json()
    assert second["access_token"] != first["access_token"] and second["refresh_token"] != first["refresh_token"]
    assert client.get(f"{API}/auth/session", headers=bearer(second)).status_code == 200
    # The previous access token stops working at once.
    assert client.get(f"{API}/auth/session", headers=bearer(first)).status_code == 401


def test_reusing_a_refresh_token_ends_the_session(client):
    first = mobile_sign_in(client, "owner@example.com")
    second = client.post(f"{API}/auth/refresh", json={"refresh_token": first["refresh_token"]}).json()

    replay = client.post(f"{API}/auth/refresh", json={"refresh_token": first["refresh_token"]})
    assert replay.status_code == 401 and _error(replay) == "refresh_reused"
    assert _session().revoke_reason == "refresh_token_reuse"
    assert len(_audit("admin_refresh_reuse_detected")) == 1
    # Both the thief's and the owner's tokens are now dead - and the rightful app is told why, on any request.
    r = client.get(f"{API}/auth/session", headers=bearer(second))
    assert r.status_code == 401 and _error(r) == "session_reuse_detected"
    assert "used twice" in r.json()["error"]["message"]
    r = client.post(f"{API}/auth/refresh", json={"refresh_token": second["refresh_token"]})
    assert r.status_code == 401 and _error(r) == "session_reuse_detected"


def test_other_session_endings_keep_the_generic_reason(client):
    tokens = mobile_sign_in(client, "owner@example.com")
    client.post(f"{API}/auth/logout", headers=bearer(tokens))
    assert _error(client.get(f"{API}/auth/session", headers=bearer(tokens))) == "session_expired"
    r = client.post(f"{API}/auth/refresh", json={"refresh_token": tokens["refresh_token"]})
    assert _error(r) == "session_expired"


def test_unknown_refresh_token_is_refused(client):
    r = client.post(f"{API}/auth/refresh", json={"refresh_token": "made-up"})
    assert r.status_code == 401 and _error(r) == "invalid_refresh"


def test_idle_session_cannot_be_refreshed(client):
    tokens = mobile_sign_in(client, "owner@example.com")
    with db_session() as db:
        db.execute(update(AdminSession).values(last_seen_at=utcnow() - timedelta(minutes=31)))
    r = client.post(f"{API}/auth/refresh", json={"refresh_token": tokens["refresh_token"]})
    assert r.status_code == 401 and _error(r) == "session_expired"
    assert _session().revoke_reason == "idle_timeout"


def test_absolute_limit_caps_refresh_and_access_lifetime(client):
    tokens = mobile_sign_in(client, "owner@example.com")
    with db_session() as db:
        db.execute(update(AdminSession).values(expires_at=utcnow() + timedelta(minutes=5)))
    r = client.post(f"{API}/auth/refresh", json={"refresh_token": tokens["refresh_token"]})
    assert r.status_code == 200 and r.json()["expires_in"] <= 5 * 60  # never beyond the session's end
    with db_session() as db:
        db.execute(update(AdminSession).values(expires_at=utcnow() - timedelta(seconds=1)))
    again = client.post(f"{API}/auth/refresh", json={"refresh_token": r.json()["refresh_token"]})
    assert again.status_code == 401 and _session().revoke_reason == "expired"


# ------------------------------------------------------------------ revocation
def test_sign_out_revokes_access_and_refresh(client):
    tokens = mobile_sign_in(client, "owner@example.com")
    assert client.post(f"{API}/auth/logout", headers=bearer(tokens)).status_code == 204
    assert client.get(f"{API}/auth/session", headers=bearer(tokens)).status_code == 401
    assert client.post(f"{API}/auth/refresh", json={"refresh_token": tokens["refresh_token"]}).status_code == 401
    assert _session().revoke_reason == "signed_out" and len(_audit("admin_logout")) == 1


def test_deactivating_the_admin_ends_phone_sessions(client):
    tokens = mobile_sign_in(client, "support@example.com", "support")
    with db_session() as db:
        db.execute(update(AdminAccount).values(is_active=False))
    assert client.get(f"{API}/auth/session", headers=bearer(tokens)).status_code == 401
    assert client.post(f"{API}/auth/refresh", json={"refresh_token": tokens["refresh_token"]}).status_code == 401


def test_list_and_end_sessions_across_clients(client):
    from tests.admin.helpers import sign_in as portal_sign_in

    portal_sign_in(client, "owner@example.com")  # a browser session for the same admin
    tokens = mobile_sign_in(client, "owner@example.com", create=False)
    items = client.get(f"{API}/auth/sessions", headers=bearer(tokens)).json()["items"]
    assert {i["client"] for i in items} == {"browser", "mobile"}
    browser = next(i for i in items if i["client"] == "browser")
    assert client.delete(f"{API}/auth/sessions/{browser['id']}", headers=bearer(tokens)).status_code == 204
    assert client.get("/admin", follow_redirects=False).status_code == 303  # browser session is gone
    assert client.delete(f"{API}/auth/sessions/{browser['id']}", headers=bearer(tokens)).status_code == 404


def test_another_admin_cannot_end_my_session(client):
    mine = mobile_sign_in(client, "owner@example.com")
    theirs = mobile_sign_in(client, "admin@example.com", "admin")
    r = client.delete(f"{API}/auth/sessions/{mine['session']['session']['id']}", headers=bearer(theirs))
    assert r.status_code == 404
    assert client.get(f"{API}/auth/session", headers=bearer(mine)).status_code == 200


# ------------------------------------------------------------------ browser / phone isolation
def test_phone_tokens_do_not_work_as_browser_cookies(client):
    tokens = mobile_sign_in(client, "owner@example.com")
    client.cookies.set("am_admin", tokens["access_token"], path="/admin")
    assert client.get("/admin", follow_redirects=False).status_code == 303  # portal: sign in
    client.cookies.set("am_admin_app", tokens["access_token"], path="/")
    assert client.get("/admin-api/v1/auth/session").status_code == 401


def test_browser_session_tokens_do_not_work_as_bearer_tokens(client):
    from tests.admin.helpers import sign_in as portal_sign_in

    portal_sign_in(client, "owner@example.com")
    cookie = client.cookies.get("am_admin")
    r = client.get(f"{API}/auth/session", headers={"Authorization": f"Bearer {cookie}"})
    assert r.status_code == 401


def test_browser_admin_api_still_works(client):
    from tests.admin_api.helpers import api_sign_in

    body = api_sign_in(client, "owner@example.com")
    assert "csrf_token" in body and client.get("/admin-api/v1/auth/session").status_code == 200


# ------------------------------------------------------------------ re-authentication
def _reauth(client, tokens, email, *, sub=None, ch=None):
    ch = ch or client.post(f"{API}/auth/reauth/challenge", headers=bearer(tokens)).json()
    return client.post(f"{API}/auth/reauth", headers=bearer(tokens), json={
        "challenge_id": ch["challenge_id"],
        "id_token": fake_google_token(sub or f"sub-{email}", email, nonce=ch["nonce"])})


def test_reauth_refreshes_the_window_for_the_same_account(client):
    tokens = mobile_sign_in(client, "owner@example.com")
    with db_session() as db:
        db.execute(update(AdminSession).values(reauth_at=utcnow() - timedelta(hours=1)))
    r = _reauth(client, tokens, "owner@example.com", sub="sub-someone-else")
    assert r.status_code == 403 and _error(r) == "different_account"
    r = _reauth(client, tokens, "owner@example.com")
    assert r.status_code == 200
    assert as_utc(_session().reauth_at) > utcnow() - timedelta(minutes=1)


def test_reauth_challenge_belongs_to_its_session(client):
    mine = mobile_sign_in(client, "owner@example.com")
    other = mobile_sign_in(client, "owner@example.com", create=False)
    ch = client.post(f"{API}/auth/reauth/challenge", headers=bearer(other)).json()
    r = _reauth(client, mine, "owner@example.com", ch=ch)
    assert r.status_code == 401 and _error(r) == "sign_in_expired"
    # A sign-in challenge is not a re-authentication challenge either.
    r = _reauth(client, mine, "owner@example.com", ch=challenge(client))
    assert _error(r) == "sign_in_expired"
    assert [r.details["reason"] for r in _audit("admin_reauth_denied")] == ["challenge_mismatch", "challenge_mismatch"]


def test_reauth_challenge_needs_a_session(client):
    assert client.post(f"{API}/auth/reauth/challenge").status_code == 401


# ------------------------------------------------------------------ permissions
@pytest.fixture
def probe_client(engine):
    test_app = FastAPI()
    install_error_handlers(test_app)

    @test_app.post(f"{API}/_probe/manage-admins")
    def manage(ctx: deps.MobileContext = Depends(deps.require(permissions.MANAGE_ADMINS))):
        return {"ok": True}

    @test_app.post(f"{API}/_probe/retry-job")
    def retry(ctx: deps.MobileContext = Depends(deps.require(permissions.RETRY_JOB))):
        return {"ok": True}

    return TestClient(test_app)


def test_require_enforces_role_and_fresh_sign_in(client, probe_client):
    support = mobile_sign_in(client, "support@example.com", "support")
    r = probe_client.post(f"{API}/_probe/manage-admins", headers=bearer(support))
    assert r.status_code == 403 and _error(r) == "forbidden"
    assert probe_client.post(f"{API}/_probe/retry-job", headers=bearer(support)).status_code == 200

    owner = mobile_sign_in(client, "owner@example.com", "owner")
    assert probe_client.post(f"{API}/_probe/manage-admins", headers=bearer(owner)).status_code == 200
    with db_session() as db:
        db.execute(update(AdminSession).values(reauth_at=utcnow() - timedelta(minutes=11)))
    r = probe_client.post(f"{API}/_probe/manage-admins", headers=bearer(owner))
    assert r.status_code == 403 and _error(r) == "reauth_required"


# ------------------------------------------------------------------ housekeeping and configuration
def test_housekeeping_purges_old_challenges_and_dead_refresh_tokens(client):
    tokens = mobile_sign_in(client, "owner@example.com")
    client.post(f"{API}/auth/logout", headers=bearer(tokens))
    with db_session() as db:
        db.execute(update(AdminAuthChallenge).values(expires_at=utcnow() - timedelta(days=2)))
    with db_session() as db:
        assert admin_mobile_auth.purge_expired(db) == 2  # one challenge + one refresh token
    with db_session() as db:
        assert db.scalar(select(AdminRefreshToken)) is None and db.scalar(select(AdminAuthChallenge)) is None


_PROD = dict(environment="production", jwt_secret="j" * 40, otp_hash_secret="o" * 40, otp_provider="disabled",
             google_client_ids="web-client.apps.googleusercontent.com")


def test_mobile_api_is_off_in_production_unless_enabled():
    assert Settings(**_PROD).admin_mobile_api_on is False
    assert Settings(environment="test").admin_mobile_api_on is True


def test_production_requires_the_admin_apps_own_google_clients():
    with pytest.raises(ValueError, match="ADMIN_MOBILE_GOOGLE_CLIENT_IDS"):
        Settings(**_PROD, admin_mobile_api_enabled=True)
    ok = Settings(**_PROD, admin_mobile_api_enabled=True,
                  admin_mobile_google_client_ids="admin-server.apps.googleusercontent.com, admin-ios.apps.googleusercontent.com")
    assert ok.admin_mobile_audiences == ["admin-server.apps.googleusercontent.com",
                                         "admin-ios.apps.googleusercontent.com"]
    # Production never falls back to the advocate app's client IDs.
    assert Settings(**_PROD).admin_mobile_audiences == []
