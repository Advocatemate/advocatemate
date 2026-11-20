"""Advocate code-wise lookup from the Daily cause list: any advocate's list by code (Lexika, no CAPTCHA)."""

from app.api.v1 import court_data


def test_other_advocates_list_by_code(client, user_headers):
    r = client.get("/api/v1/cause-list/advocate/67890?date=2026-11-18", headers=user_headers)
    assert r.status_code == 200
    body = r.json()
    assert body["advocate_code"] == "67890" and body["advocate_name"] == "ADVOCATE TWO"
    assert body["total_cases"] == 0 and body["date_offered_by_source"] is False


def test_unknown_advocate_code_has_a_clear_error(client, user_headers):
    for path in ("/api/v1/cause-list/advocate/99999?date=2026-11-18", "/api/v1/advocates/99999"):
        r = client.get(path, headers=user_headers)
        assert r.status_code == 404
        err = r.json()["error"]
        assert err["code"] == "advocate_not_found"
        assert err["message"] == "No advocate was found for this advocate code. Check the code and try again."


def test_invalid_advocate_code_is_rejected(client, user_headers):
    r = client.get("/api/v1/cause-list/advocate/12ab?date=2026-11-18", headers=user_headers)
    assert r.status_code == 422 and r.json()["error"]["code"] == "invalid_advocate_code"


def test_lookups_of_other_advocates_are_limited_but_own_code_is_not(client, user_headers, monkeypatch, fake_lexika):
    monkeypatch.setattr(court_data, "OTHER_ADVOCATE_LOOKUPS_PER_10_MIN", 3)
    for _ in range(3):
        assert client.get("/api/v1/cause-list/advocate/67890?date=2026-11-18", headers=user_headers).status_code == 200
    r = client.get("/api/v1/cause-list/advocate/67890?date=2026-11-17", headers=user_headers)
    assert r.status_code == 429 and r.json()["error"]["code"] == "advocate_lookup_limited"
    # the signed-in advocate's own code (12345) is never limited
    for _ in range(5):
        assert client.get("/api/v1/cause-list/advocate/12345?date=2026-11-18", headers=user_headers).status_code == 200
    calls = sum(1 for c in fake_lexika.calls if c[0] == "advocate_list" and c[1] == "67890")
    assert calls <= 3  # the refused request never reached the High Court service


def test_lookup_requires_sign_in(client):
    assert client.get("/api/v1/cause-list/advocate/67890?date=2026-11-18").status_code == 401
