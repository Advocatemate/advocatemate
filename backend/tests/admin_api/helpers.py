"""Helpers for /admin-api/v1 tests: nonce + Google sign-in as the Admin App does it."""

from __future__ import annotations

from fastapi.testclient import TestClient

from tests.admin.helpers import make_admin
from tests.conftest import fake_google_token

API = "/admin-api/v1"
ORIGIN = "http://localhost:5173"  # development default for ADMIN_APP_ORIGINS


def get_nonce(client: TestClient) -> str:
    r = client.get(f"{API}/auth/nonce")
    assert r.status_code == 200, r.text
    return r.json()["nonce"]


def google_sign_in(client: TestClient, email: str, *, nonce: str | None = None, sub: str | None = None,
                   origin: str | None = ORIGIN):
    token_nonce = nonce if nonce is not None else get_nonce(client)
    headers = {"Origin": origin} if origin else {}
    return client.post(f"{API}/auth/google", headers=headers,
                       json={"credential": fake_google_token(sub or f"sub-{email}", email, nonce=token_nonce)})


def api_sign_in(client: TestClient, email: str, role: str = "owner", *, create: bool = True) -> dict:
    """Signs in and returns the session payload (account, permissions, csrf_token, session)."""
    if create:
        make_admin(email, role)
    r = google_sign_in(client, email)
    assert r.status_code == 200, r.text
    return r.json()


def unsafe_headers(payload: dict) -> dict:
    return {"Origin": ORIGIN, "X-CSRF-Token": payload["csrf_token"]}
