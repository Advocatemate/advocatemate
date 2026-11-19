"""Google sign-in + automatic advocate-registry verification (scenarios A-G) and sessions."""

from datetime import timedelta

import jwt
from sqlalchemy import func, select, update

from app.models import AdvocateProfile, AuditRecord, AuthSession, FavouriteAdvocate, User
from tests.conftest import auth, fake_google_token, login

GOOGLE = "/api/v1/auth/google"
LINK = "/api/v1/auth/google/link"


def step1(client, sub, email, verified=True):
    return client.post(GOOGLE, json={"id_token": fake_google_token(sub, email, verified=verified)})


def step2(client, link_token, code):
    return client.post(LINK, json={"link_token": link_token, "advocate_code": code})


def link_token(client, sub, email):
    r = step1(client, sub, email)
    assert r.status_code == 200 and r.json()["status"] == "advocate_code_required", r.text
    return r.json()["link_token"]


# ------------------------------------------------------------------ Scenario A
def test_scenario_a_first_link_grants_access(client, engine):
    r = step1(client, "sub-a", "ADV.ONE@example.com")  # email case from Google is normalised
    body = r.json()
    assert body["status"] == "advocate_code_required" and body["google_email"] == "adv.one@example.com"
    assert "access_token" not in body
    with engine.connect() as c:  # nothing stored before verification succeeds
        assert c.execute(select(func.count()).select_from(AdvocateProfile)).scalar() == 0
    r = step2(client, body["link_token"], "12345")
    assert r.status_code == 200 and r.json()["status"] == "signed_in"
    me = client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {r.json()['access_token']}"}).json()
    assert me["advocate_code"] == "12345" and me["advocate_name"] == "ADVOCATE ONE"
    assert me["google_email"] == "adv.one@example.com"
    assert me["identity_verification"] == "registry_verified" and me["verification_method"] == "registry_email_match"


# ------------------------------------------------------------------ Scenario B
def test_scenario_b_linked_account_goes_straight_in(client):
    login(client, code="12345", email="adv.one@example.com", sub="sub-b")
    r = step1(client, "sub-b", "adv.one@example.com")
    assert r.status_code == 200 and r.json()["status"] == "signed_in" and "link_token" not in r.json()


# ------------------------------------------------------------------ Scenario C
def test_scenario_c_invalid_code(client):
    r = step2(client, link_token(client, "sub-c", "adv.one@example.com"), "99999")
    assert r.status_code == 404
    assert r.json()["error"] == {"code": "invalid_advocate_code",
                                 "message": "Invalid Advocate Code. Please check your code and try again.",
                                 "request_id": r.json()["error"]["request_id"]}


def test_code_alone_never_grants_access(client):
    # No Google token -> no link token -> cannot even attempt the code.
    r = client.post(LINK, json={"link_token": "x" * 30, "advocate_code": "12345"})
    assert r.status_code == 401 and r.json()["error"]["code"] == "link_token_invalid"


# ------------------------------------------------------------------ Scenario D
def test_scenario_d_email_mismatch(client, engine):
    r = step2(client, link_token(client, "sub-d", "someone.else@example.com"), "12345")
    assert r.status_code == 403 and r.json()["error"]["code"] == "email_mismatch"
    assert "adv.one" not in r.text  # registered email is never revealed
    with engine.connect() as c:
        assert c.execute(select(func.count()).select_from(AdvocateProfile)).scalar() == 0


def test_registry_without_email_cannot_be_verified(client):
    r = step2(client, link_token(client, "sub-x", "anyone@example.com"), "22222")
    assert r.status_code == 403 and r.json()["error"]["code"] == "registry_email_missing"


# ------------------------------------------------------------------ Scenario E
def test_scenario_e_advocate_already_linked_to_other_google_account(client):
    login(client, code="12345", email="adv.one@example.com", sub="first-owner")
    # A different Google account that (somehow) uses the same email still cannot take over the link.
    r = step2(client, link_token(client, "second-account", "adv.one@example.com"), "12345")
    assert r.status_code == 409 and r.json()["error"]["code"] == "advocate_already_linked"


# ------------------------------------------------------------------ Scenario F
def test_scenario_f_google_account_linked_to_another_advocate(client):
    token = link_token(client, "shared-sub", "adv.one@example.com")
    login(client, code="12345", email="adv.one@example.com", sub="shared-sub")
    # The earlier link token for the same Google account is now used against a second advocate.
    r = step2(client, token, "24680")
    assert r.status_code == 409 and r.json()["error"]["code"] == "google_account_linked_elsewhere"


# ------------------------------------------------------------------ Scenario G
def test_scenario_g_inactive_and_suspended_denied(client):
    for code, email in (("11111", "inactive.adv@example.com"), ("33333", "suspended.adv@example.com")):
        r = step2(client, link_token(client, f"sub-{code}", email), code)
        assert r.status_code == 403 and r.json()["error"]["code"] == "advocate_not_eligible", code


def test_deactivated_in_registry_loses_access_immediately(client, engine):
    h = login(client)
    assert client.get("/api/v1/auth/me", headers=auth(h)).status_code == 200
    from app.models import AdvocateRegistryEntry

    with engine.begin() as c:
        c.execute(update(AdvocateRegistryEntry).where(AdvocateRegistryEntry.advocate_code == "12345")
                  .values(status="suspended"))
    r = client.get("/api/v1/auth/me", headers=auth(h))
    assert r.status_code == 403 and r.json()["error"]["code"] == "advocate_not_eligible"
    assert client.post("/api/v1/auth/refresh", json={"refresh_token": h["_refresh"]}).status_code == 401
    r = step1(client, "google-sub-12345", "adv.one@example.com")  # Scenario B path also refuses
    assert r.status_code == 403
    with engine.connect() as c:  # session revoked, link itself kept
        assert c.execute(select(AuthSession.revoked_at)).scalar() is not None
        assert c.execute(select(AdvocateProfile.google_sub)).scalar() == "google-sub-12345"


# ------------------------------------------------------------------ Google token handling
def test_unverified_google_email_rejected(client):
    r = step1(client, "sub-u", "adv.one@example.com", verified=False)
    assert r.status_code == 401 and r.json()["error"]["code"] == "google_email_unverified"


def test_invalid_google_token_rejected(client):
    r = client.post(GOOGLE, json={"id_token": "not-a-real-google-token-at-all"})
    assert r.status_code == 401 and r.json()["error"]["code"] == "google_token_invalid"


def test_client_cannot_inject_email_or_sub(client):
    r = client.post(GOOGLE, json={"id_token": fake_google_token("s", "adv.one@example.com"),
                                  "email": "adv.one@example.com", "sub": "s"})
    assert r.status_code == 422  # extra fields are refused outright
    r = client.post(LINK, json={"link_token": link_token(client, "s2", "x@example.com"), "advocate_code": "12345",
                                "email": "adv.one@example.com"})
    assert r.status_code == 422


def test_link_token_expired_tampered_wrong_type_and_reused(client):
    from app.core.config import get_settings

    s = get_settings()
    good = link_token(client, "sub-t", "adv.one@example.com")
    claims = jwt.decode(good, s.jwt_secret, algorithms=[s.jwt_algorithm], issuer=s.jwt_issuer)
    expired = jwt.encode(claims | {"exp": claims["iat"] - 10}, s.jwt_secret, algorithm=s.jwt_algorithm)
    assert step2(client, expired, "12345").json()["error"]["code"] == "link_token_expired"
    forged = jwt.encode(claims | {"email": "adv.two@example.com"}, "not-the-server-secret-xxxxxxxxxxxx",
                        algorithm=s.jwt_algorithm)
    assert step2(client, forged, "67890").json()["error"]["code"] == "link_token_invalid"
    wrong_type = jwt.encode(claims | {"typ": "access"}, s.jwt_secret, algorithm=s.jwt_algorithm)
    assert step2(client, wrong_type, "12345").json()["error"]["code"] == "link_token_invalid"
    assert step2(client, good, "12345").status_code == 200
    r = step2(client, good, "12345")
    assert r.status_code == 401 and r.json()["error"]["code"] == "link_token_used"


def test_wrong_code_can_be_retried_with_same_link_token(client):
    token = link_token(client, "sub-r", "adv.one@example.com")
    assert step2(client, token, "99999").status_code == 404
    assert step2(client, token, "12345").status_code == 200


def test_link_attempts_rate_limited(client):
    token = link_token(client, "sub-rl", "adv.one@example.com")
    codes = [step2(client, token, "99999").status_code for _ in range(11)]
    assert codes[:10] == [404] * 10 and codes[10] == 429


# ------------------------------------------------------------------ existing users / switching
def test_legacy_otp_profile_is_reused_and_old_sessions_revoked(client, engine):
    from app.db.session import db_session
    from app.models import Advocate, NotificationPreference

    with db_session() as db:  # profile + session as the retired OTP login left them
        db.add(Advocate(advocate_code="12345", name="ADVOCATE ONE", source="aphc_lexika_chatbot"))
        user = User(role="advocate", status="active")
        db.add(user)
        db.flush()
        db.add(AdvocateProfile(user_id=user.id, advocate_code="12345", source_name="ADVOCATE ONE",
                               identity_verification="legacy_unverified"))
        db.add(NotificationPreference(user_id=user.id))
        db.add(FavouriteAdvocate(user_id=user.id, advocate_code="12345"))
        old = AuthSession(user_id=user.id)
        db.add(old)
        db.flush()
        legacy_user, old_session = user.id, old.id

    h = auth(login(client, code="12345", email="adv.one@example.com", sub="legacy-relink"))
    me = client.get("/api/v1/auth/me", headers=h).json()
    assert me["user_id"] == str(legacy_user)  # same account: favourites and history kept
    assert len(client.get("/api/v1/favourites/advocates", headers=h).json()) == 1
    with engine.connect() as c:
        assert c.execute(select(AuthSession.revoke_reason).where(AuthSession.id == old_session)).scalar() \
            == "relinked_with_google"


def test_unlinked_legacy_session_must_sign_in_with_google(client, engine):
    from app.core.security import create_access_token
    from app.db.session import db_session
    from app.models import Advocate

    with db_session() as db:
        db.add(Advocate(advocate_code="67890", name="ADVOCATE TWO", source="aphc_lexika_chatbot"))
        user = User(role="advocate", status="active")
        db.add(user)
        db.flush()
        db.add(AdvocateProfile(user_id=user.id, advocate_code="67890", source_name="ADVOCATE TWO",
                               identity_verification="legacy_unverified"))
        s = AuthSession(user_id=user.id)
        db.add(s)
        db.flush()
        token, _ = create_access_token(user_id=user.id, session_id=s.id, role="advocate")
    r = client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {token}"})
    assert r.status_code == 401 and r.json()["error"]["code"] == "google_link_required"


def test_switching_google_accounts_keeps_permanent_links(client, engine):
    a = auth(login(client, code="12345", email="adv.one@example.com", sub="acct-1"))
    assert client.post("/api/v1/auth/logout", headers=a).status_code == 204
    b = auth(login(client, code="67890", email="adv.two@example.com", sub="acct-2"))
    assert client.get("/api/v1/auth/me", headers=b).json()["advocate_code"] == "67890"
    # Switching back: the first account's link is still there -> straight in.
    assert step1(client, "acct-1", "adv.one@example.com").json()["status"] == "signed_in"
    with engine.connect() as c:
        assert c.execute(select(func.count()).select_from(AdvocateProfile)
                         .where(AdvocateProfile.google_sub.is_not(None))).scalar() == 2


def test_retired_otp_endpoints(client):
    for path in ("/api/v1/auth/register", "/api/v1/auth/send-otp", "/api/v1/auth/verify-otp"):
        r = client.post(path, json={"advocate_code": "12345"})
        assert r.status_code == 410 and r.json()["error"]["code"] == "login_method_retired", path


def test_attempts_are_audited_without_secrets(client, engine):
    step2(client, link_token(client, "sub-aud", "someone@example.com"), "12345")
    with engine.connect() as c:
        rows = c.execute(select(AuditRecord.action, AuditRecord.details)).all()
    attempts = [d for a, d in rows if a == "advocate_link_attempt"]
    assert attempts and attempts[0]["result"] == "email_mismatch"
    assert "someone@example.com" not in str(rows) and "link_token" not in str(rows)


# ------------------------------------------------------------------ sessions (unchanged behaviour)
def test_refresh_rotation_and_reuse_detection(client):
    h = login(client)
    r1 = client.post("/api/v1/auth/refresh", json={"refresh_token": h["_refresh"]})
    assert r1.status_code == 200
    new = r1.json()
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
        assert client.get(path).status_code == 401, path
    assert client.get("/api/v1/auth/me", headers={"Authorization": "Bearer nonsense"}).status_code == 401


def test_profile_update_only_editable_fields(client, engine):
    h = auth(login(client))
    r = client.patch("/api/v1/auth/me", headers=h, json={"display_name": "Adv. One", "preferred_language": "te"})
    assert r.status_code == 200 and r.json()["display_name"] == "Adv. One"
    assert client.patch("/api/v1/auth/me", headers=h, json={"advocate_name": "x"}).status_code == 422
    assert client.patch("/api/v1/auth/me", headers=h, json={"google_email": "x@example.com"}).status_code == 422
    with engine.connect() as c:
        assert c.execute(select(AdvocateProfile.google_email)).scalar() == "adv.one@example.com"


def test_disabled_user_cannot_use_token(client, engine):
    h = auth(login(client))
    with engine.begin() as c:
        c.execute(update(User).values(status="disabled"))
    assert client.get("/api/v1/auth/me", headers=h).status_code == 401


def test_link_token_lifetime_is_short(client):
    from app.core.config import get_settings

    r = step1(client, "sub-ttl", "adv.one@example.com").json()
    assert r["link_expires_in"] == get_settings().google_link_token_minutes * 60 <= int(timedelta(minutes=15).total_seconds())


def test_database_enforces_one_to_one_links(client, engine):
    """Even if two requests raced past the checks, the unique constraints stop a double link."""
    import pytest
    from sqlalchemy.exc import IntegrityError

    from app.db.session import db_session
    from app.models import Advocate

    login(client, code="12345", email="adv.one@example.com", sub="unique-sub")
    with pytest.raises(IntegrityError):  # same Google account on a second advocate profile
        with db_session() as db:
            db.add(Advocate(advocate_code="67890", name="ADVOCATE TWO", source="t"))
            u = User(role="advocate", status="active")
            db.add(u)
            db.flush()
            db.add(AdvocateProfile(user_id=u.id, advocate_code="67890", source_name="x", google_sub="unique-sub"))
    with pytest.raises(IntegrityError):  # same advocate code on a second profile
        with db_session() as db:
            u = User(role="advocate", status="active")
            db.add(u)
            db.flush()
            db.add(AdvocateProfile(user_id=u.id, advocate_code="12345", source_name="x", google_sub="other-sub"))
