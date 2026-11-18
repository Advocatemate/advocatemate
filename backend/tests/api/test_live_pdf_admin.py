from datetime import timedelta

from sqlalchemy import update

from app.db.base import utcnow
from app.db.session import db_session
from app.models import SourceCache
from app.services import live_board


def test_live_board_unavailable_before_first_poll(client, user_headers):
    r = client.get("/api/v1/live-courts", headers=user_headers)
    assert r.status_code == 503 and r.json()["error"]["code"] == "board_unavailable"


def test_live_board_after_backend_poll(client, user_headers, fake_aphc):
    with db_session() as db:
        live_board.poll_display_board(db)
    r = client.get("/api/v1/live-courts", headers=user_headers).json()
    assert r["is_current"] is True and r["stale"] is False
    assert [c["court_no"] for c in r["courts"]][:3] == ["1", "3", "7"]
    one = client.get("/api/v1/live-courts?court_no=1", headers=user_headers).json()["courts"]
    assert one == [{"court_no": "1", "state": "in_progress", "current_item": "D-52", "kept_back": "1",
                    "pending_serials": ["1", "37"], "coram": "DB-I"}]
    # mobile reads never trigger upstream polling
    polls = sum(1 for c in fake_aphc.calls if c[0] == "display")
    client.get("/api/v1/live-courts", headers=user_headers)
    assert sum(1 for c in fake_aphc.calls if c[0] == "display") == polls


def test_old_board_is_flagged_stale_never_current(client, user_headers, engine):
    with db_session() as db:
        live_board.poll_display_board(db)
    with engine.begin() as c:
        c.execute(update(SourceCache).values(fetched_at=utcnow() - timedelta(minutes=30)))
    r = client.get("/api/v1/live-courts", headers=user_headers).json()
    assert r["stale"] is True and r["is_current"] is False and "NOT the current" in r["note"]


def test_publication_status_and_court_pdf(client, user_headers, fake_aphc):
    r = client.get("/api/v1/cause-list/status", headers=user_headers)
    assert r.status_code == 200
    body = r.json()
    assert body["list_date"] == "2026-11-18" and body["summary"] == {"UPLOADED": 2, "ON LEAVE": 1}
    assert "FAKEPC1" not in r.text
    pdf = client.get("/api/v1/cause-list/court/1/pdf?date=2026-11-18", headers=user_headers)
    assert pdf.status_code == 200 and pdf.headers["x-document-official"] == "true"
    assert ("pdf", "/Hcdbs/upload/court1_20261118.pdf") in fake_aphc.calls
    none = client.get("/api/v1/cause-list/court/17/pdf?date=2026-11-18", headers=user_headers)
    assert none.status_code == 404 and none.json()["error"]["code"] == "pdf_unavailable"


def test_weekly_pdf_proxied_and_cached(client, user_headers, fake_aphc):
    r = client.get("/api/v1/cause-list/weekly.pdf", headers=user_headers)
    assert r.status_code == 200 and r.content.startswith(b"%PDF")
    assert r.headers["x-source-url"].endswith("/Hcdbs/upload/weeklylist.pdf")
    client.get("/api/v1/cause-list/weekly.pdf", headers=user_headers)
    assert sum(1 for c in fake_aphc.calls if c[0] == "pdf") == 1


def test_admin_routes_are_role_protected(client, user_headers, admin_headers):
    for path in ("/api/v1/admin/dashboard", "/api/v1/admin/sync-status", "/api/v1/admin/jobs",
                 "/api/v1/admin/source-health", "/api/v1/admin/audit"):
        assert client.get(path, headers=user_headers).status_code == 403, path
        r = client.get(path, headers=admin_headers)
        assert r.status_code == 200, (path, r.text)
    dash = client.get("/api/v1/admin/dashboard", headers=admin_headers).json()
    assert dash["users"]["advocates"] == 2
    audit_text = client.get("/api/v1/admin/audit", headers=admin_headers).text
    assert "9876543210" not in audit_text and "dev_otp" not in audit_text


def test_admin_identity_verification(client, user_headers, admin_headers):
    r = client.post("/api/v1/admin/advocates/verify", headers=admin_headers,
                    json={"advocate_code": "12345", "decision": "verified"})
    assert r.status_code == 200
    assert client.get("/api/v1/auth/me", headers=user_headers).json()["identity_verification"] == "verified"


def test_health(client):
    assert client.get("/health/live").json() == {"status": "ok"}
    assert client.get("/health/ready").json()["status"] == "ready"
    assert client.get("/openapi.json").status_code == 200
