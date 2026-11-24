"""Helpers for admin-portal tests: authorised accounts, Google sign-in and CSRF tokens."""

from __future__ import annotations

from fastapi.testclient import TestClient
from sqlalchemy import select

from app.db.session import db_session
from app.models import AdminAccount, AdminSession
from app.services import admin_access
from tests.conftest import fake_google_token

G_CSRF = "google-double-submit-token"


def make_admin(email: str, role: str = "owner", *, active: bool = True) -> str:
    with db_session() as db:
        acct = admin_access.create_account(db, email, role, via="cli")
        acct.is_active = active
        return str(acct.id)


def google_post(client: TestClient, path: str, email: str, *, sub: str | None = None, verified: bool = True,
                g_csrf: str = G_CSRF, next_path: str | None = None):
    client.cookies.set("g_csrf_token", G_CSRF, path="/")
    url = path + (f"?next={next_path}" if next_path else "")
    return client.post(url, data={"credential": fake_google_token(sub or f"sub-{email}", email, verified=verified),
                                  "g_csrf_token": g_csrf}, follow_redirects=False)


def sign_in(client: TestClient, email: str, role: str = "owner", *, create: bool = True) -> None:
    if create:
        make_admin(email, role)
    r = google_post(client, "/admin/auth/google", email)
    assert r.status_code == 303 and r.headers["location"] == "/admin", r.headers.get("location")
    assert "am_admin" in client.cookies


def csrf_token(email: str) -> str:
    with db_session() as db:
        acct = db.scalar(select(AdminAccount).where(AdminAccount.email == email))
        sess = db.scalar(select(AdminSession).where(AdminSession.admin_account_id == acct.id,
                                                    AdminSession.revoked_at.is_(None))
                         .order_by(AdminSession.created_at.desc()))
        return sess.csrf_token


def htmx(email: str) -> dict:
    return {"HX-Request": "true", "X-CSRF-Token": csrf_token(email)}
