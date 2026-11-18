from sqlalchemy import select

from app.models import AdvocateProfile, OtpRecord, User
from tests.conftest import auth, login


def test_register_validates_code_against_source(client):
    r = client.post("/api/v1/auth/register", json={"advocate_code": "12345"})
    assert r.status_code == 200
    body = r.json()
    assert body["advocate_name"] == "ADVOCATE ONE" and body["already_registered"] is False
    assert client.post("/api/v1/auth/register", json={"advocate_code": "99999999"}).status_code == 404
    assert client.post("/api/v1/auth/register", json={"advocate_code": "12a"}).status_code == 422


def test_send_otp_requires_identity_confirmation(client):
    r = client.post("/api/v1/auth/send-otp", json={"advocate_code": "12345", "mobile": "9876543210",
                                                   "identity_confirmed": False})
    assert r.status_code == 422 and r.json()["error"]["code"] == "identity_not_confirmed"


def test_full_login_creates_self_declared_profile(client, engine):
    h = login(client)
    me = client.get("/api/v1/auth/me", headers=auth(h)).json()
    assert me["advocate_code"] == "12345" and me["advocate_name"] == "ADVOCATE ONE"
    assert me["identity_verification"] == "self_declared"
    assert me["mobile"] == "+91******3210"
    with engine.connect() as c:
        otp = c.execute(select(OtpRecord)).first()
        assert otp.code_hash and len(otp.code_hash) > 20  # hash, not the code


def test_wrong_otp_and_lockout(client):
    client.post("/api/v1/auth/send-otp", json={"advocate_code": "12345", "mobile": "9876543210",
                                               "identity_confirmed": True})
    for _ in range(5):
        r = client.post("/api/v1/auth/verify-otp", json={"advocate_code": "12345", "mobile": "9876543210",
                                                         "otp": "000000"})
        assert r.status_code == 401
    r = client.post("/api/v1/auth/verify-otp", json={"advocate_code": "12345", "mobile": "9876543210",
                                                     "otp": "000000"})
    assert r.json()["error"]["code"] in ("otp_locked", "otp_expired")


def test_otp_send_rate_limit(client):
    codes = []
    for _ in range(6):
        codes.append(client.post("/api/v1/auth/send-otp", json={"advocate_code": "12345", "mobile": "9876543210",
                                                                "identity_confirmed": True}).status_code)
    assert codes[:5] == [200] * 5 and codes[5] == 429


def test_code_bound_to_first_verified_mobile(client):
    login(client)
    r = client.post("/api/v1/auth/send-otp", json={"advocate_code": "12345", "mobile": "9000000001",
                                                   "identity_confirmed": True})
    assert r.status_code == 409 and r.json()["error"]["code"] == "mobile_mismatch"
    reg = client.post("/api/v1/auth/register", json={"advocate_code": "12345"}).json()
    assert reg["already_registered"] is True and reg["registered_mobile_hint"] == "+91******3210"


def test_refresh_rotation_and_reuse_detection(client):
    h = login(client)
    r1 = client.post("/api/v1/auth/refresh", json={"refresh_token": h["_refresh"]})
    assert r1.status_code == 200
    new = r1.json()
    # Old token reused -> rejected and whole session revoked.
    r2 = client.post("/api/v1/auth/refresh", json={"refresh_token": h["_refresh"]})
    assert r2.status_code == 401 and r2.json()["error"]["code"] == "refresh_reused"
    r3 = client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {new['access_token']}"})
    assert r3.status_code == 401 and r3.json()["error"]["code"] == "session_revoked"


def test_logout_revokes_session(client):
    h = auth(login(client))
    assert client.post("/api/v1/auth/logout", headers=h).status_code == 204
    assert client.get("/api/v1/auth/me", headers=h).status_code == 401


def test_protected_routes_require_auth(client):
    for path in ("/api/v1/auth/me", "/api/v1/cause-list/status", "/api/v1/favourites/cases",
                 "/api/v1/live-courts", "/api/v1/admin/dashboard"):
        r = client.get(path)
        assert r.status_code == 401, path
    assert client.get("/api/v1/auth/me", headers={"Authorization": "Bearer nonsense"}).status_code == 401


def test_profile_update_only_editable_fields(client, engine):
    h = auth(login(client))
    r = client.patch("/api/v1/auth/me", headers=h, json={"display_name": "Adv. One", "preferred_language": "te"})
    assert r.status_code == 200 and r.json()["display_name"] == "Adv. One" and r.json()["preferred_language"] == "te"
    # Source-owned fields cannot be set.
    r = client.patch("/api/v1/auth/me", headers=h, json={"advocate_name": "Someone Else"})
    assert r.status_code == 422
    with engine.connect() as c:
        assert c.execute(select(AdvocateProfile.source_name)).scalar() == "ADVOCATE ONE"


def test_disabled_otp_provider_does_not_pretend(client, monkeypatch):
    from app.core.config import get_settings

    monkeypatch.setattr(get_settings(), "otp_provider", "disabled")
    r = client.post("/api/v1/auth/send-otp", json={"advocate_code": "12345", "mobile": "9876543210",
                                                   "identity_confirmed": True})
    assert r.status_code == 503 and r.json()["error"]["code"] == "otp_unavailable"


def test_disabled_user_cannot_use_token(client, engine):
    h = auth(login(client))
    from sqlalchemy import update

    with engine.begin() as c:
        c.execute(update(User).values(status="disabled"))
    assert client.get("/api/v1/auth/me", headers=h).status_code == 401


def test_error_responses_are_safe(client):
    r = client.post("/api/v1/auth/verify-otp", json={"advocate_code": "1", "mobile": "x", "otp": "1"})
    assert r.status_code == 422 and "request_id" in r.json()["error"]
    assert "Traceback" not in r.text
