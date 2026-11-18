from datetime import date

from app.db.session import db_session
from app.services import notifications
from tests.conftest import auth, login


def test_favourite_advocates_crud_and_isolation(client, user_headers, admin_headers):
    r = client.post("/api/v1/favourites/advocates", headers=user_headers, json={"advocate_code": "67890"})
    assert r.status_code == 201 and r.json()["advocate_name"] == "ADVOCATE TWO"
    fav_id = r.json()["id"]
    assert client.post("/api/v1/favourites/advocates", headers=user_headers,
                       json={"advocate_code": "67890"}).status_code == 409
    assert client.post("/api/v1/favourites/advocates", headers=user_headers,
                       json={"advocate_code": "99999999"}).status_code == 404
    assert len(client.get("/api/v1/favourites/advocates", headers=user_headers).json()) == 1
    # another user can neither see nor delete it
    assert client.get("/api/v1/favourites/advocates", headers=admin_headers).json() == []
    assert client.delete(f"/api/v1/favourites/advocates/{fav_id}", headers=admin_headers).status_code == 404
    assert client.delete(f"/api/v1/favourites/advocates/{fav_id}", headers=user_headers).status_code == 204
    assert client.get("/api/v1/favourites/advocates", headers=user_headers).json() == []


def test_favourite_advocate_refresh(client, user_headers):
    fav = client.post("/api/v1/favourites/advocates", headers=user_headers, json={"advocate_code": "12345"}).json()
    r = client.post(f"/api/v1/favourites/advocates/{fav['id']}/refresh-cause-list?date=2026-11-18",
                    headers=user_headers)
    assert r.status_code == 200 and r.json()["total_cases"] == 3


def test_favourite_cases(client, user_headers):
    r = client.post("/api/v1/favourites/cases", headers=user_headers, json={"case_number": "WP/11111/2026"})
    assert r.status_code == 201 and r.json()["case_number"] == "WP/11111/2026"
    assert client.post("/api/v1/favourites/cases", headers=user_headers,
                       json={"case_number": "WP 11111/2026"}).status_code == 409
    assert client.post("/api/v1/favourites/cases", headers=user_headers, json={"case_number": "bad"}).status_code == 422
    items = client.get("/api/v1/favourites/cases", headers=user_headers).json()
    assert len(items) == 1
    assert client.delete(f"/api/v1/favourites/cases/{items[0]['id']}", headers=user_headers).status_code == 204


def test_devices_and_notifications(client, user_headers):
    d = client.post("/api/v1/devices", headers=user_headers,
                    json={"token": "x" * 40, "platform": "android", "app_version": "0.1.0"})
    assert d.status_code == 201
    me = client.get("/api/v1/auth/me", headers=user_headers).json()
    import uuid

    with db_session() as db:
        n1 = notifications.notify(db, uuid.UUID(me["user_id"]), category="announcement", title="Hello",
                                  body="Test", dedupe_key="a1", deep_link="advocatemate://notifications")
        dup = notifications.notify(db, uuid.UUID(me["user_id"]), category="announcement", title="Hello",
                                   body="Test", dedupe_key="a1")
        assert n1 is not None and dup is None
        assert n1.delivery_status == "skipped" and n1.delivery_error == "push_not_configured"
    page = client.get("/api/v1/notifications", headers=user_headers).json()
    assert page["total"] == 1 and page["unread_count"] == 1
    client.post("/api/v1/notifications/read", headers=user_headers, json={"all": True})
    assert client.get("/api/v1/notifications", headers=user_headers).json()["unread_count"] == 0
    assert client.delete(f"/api/v1/devices/{d.json()['id']}", headers=user_headers).status_code == 204


def test_notification_preferences(client, user_headers):
    prefs = client.get("/api/v1/notifications/preferences", headers=user_headers).json()
    assert all(prefs.values())
    prefs["announcements"] = False
    assert client.put("/api/v1/notifications/preferences", headers=user_headers, json=prefs).json()["announcements"] is False
    me = client.get("/api/v1/auth/me", headers=user_headers).json()
    import uuid

    with db_session() as db:
        n = notifications.notify(db, uuid.UUID(me["user_id"]), category="announcement", title="T", body="B",
                                 dedupe_key="pref-test")
        assert n.delivery_error == "preference_off"


def test_favourite_case_listing_notification(client, user_headers):
    client.get("/api/v1/cause-list/court/3?list_type=D&date=2026-11-18", headers=user_headers)
    fav = client.post("/api/v1/favourites/cases", headers=user_headers, json={"case_number": "WP/11111/2026"}).json()
    import uuid

    with db_session() as db:
        sent = notifications.favourite_case_listed(db, uuid.UUID(fav["case_id"]), date(2026, 11, 18), "3", "1")
        again = notifications.favourite_case_listed(db, uuid.UUID(fav["case_id"]), date(2026, 11, 18), "3", "1")
    assert sent == 1 and again == 0
    items = client.get("/api/v1/notifications", headers=user_headers).json()["items"]
    assert "Court 3, item 1" in items[0]["body"]


def test_search(client, user_headers):
    client.get("/api/v1/cause-list/court/3?list_type=D&date=2026-11-18", headers=user_headers)
    r = client.get("/api/v1/search/cases?q=WP/11111/2026", headers=user_headers).json()
    assert r["total"] == 1 and r["results"][0]["petitioner"] == "PETITIONER ALPHA"
    r = client.get("/api/v1/search/cases?party=gamma", headers=user_headers).json()
    assert [x["case_number"] for x in r["results"]] == ["WP/333/2017"]
    r = client.get("/api/v1/search/cases?advocate=ADVOCATE FIVE", headers=user_headers).json()
    assert {x["case_number"] for x in r["results"]} == {"WP/333/2017", "WP/444/2018"}
    r = client.get("/api/v1/search/cases?case_type=WP&case_year=2017", headers=user_headers).json()
    assert r["total"] == 1
    r = client.get("/api/v1/search/cases?q=WP/5/2020", headers=user_headers).json()
    assert r["total"] == 0 and r["hint"]
    assert client.get("/api/v1/search/cases", headers=user_headers).status_code == 422
    assert client.get("/api/v1/search/cases?q=ab", headers=user_headers).status_code == 422
    # wildcard characters are escaped
    assert client.get("/api/v1/search/cases?party=%25%25%25", headers=user_headers).json()["total"] == 0
    hist = client.get("/api/v1/search/history", headers=user_headers).json()["items"]
    assert {"WP/5/2020", "gamma", "ADVOCATE FIVE"} <= {h["query"] for h in hist}
    assert client.get("/api/v1/search/suggestions?prefix=WP/3", headers=user_headers).json()["items"] == ["WP/333/2017"]
    assert client.delete("/api/v1/search/history", headers=user_headers).status_code == 204


def test_second_user_login_isolated(client):
    a = auth(login(client))
    b = auth(login(client, code="67890", mobile="9123456789"))
    assert client.get("/api/v1/auth/me", headers=a).json()["advocate_code"] == "12345"
    assert client.get("/api/v1/auth/me", headers=b).json()["advocate_code"] == "67890"
