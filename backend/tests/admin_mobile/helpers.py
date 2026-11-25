"""Helpers for /admin-mobile/v1 tests: challenge + Google sign-in as the phone app does it."""

from __future__ import annotations

from fastapi.testclient import TestClient

from tests.admin.helpers import make_admin
from tests.conftest import fake_google_token

API = "/admin-mobile/v1"
DEVICE = {"installation_id": "1f6c0b9e-7d2a-4c1e-9a55-3b8f2d7e6a10", "platform": "android",
          "device_name": "Test Phone", "app_version": "0.1.0+1"}


def challenge(client: TestClient) -> dict:
    r = client.post(f"{API}/auth/challenge")
    assert r.status_code == 200, r.text
    return r.json()


def google_sign_in(client: TestClient, email: str, *, ch: dict | None = None, nonce: str | None = None,
                   sub: str | None = None, device: dict | None = None):
    ch = ch or challenge(client)
    token = fake_google_token(sub or f"sub-{email}", email, nonce=ch["nonce"] if nonce is None else nonce or None)
    return client.post(f"{API}/auth/google", json={"challenge_id": ch["challenge_id"], "id_token": token,
                                                   "device": device or DEVICE})


def mobile_sign_in(client: TestClient, email: str, role: str = "owner", *, create: bool = True) -> dict:
    """Signs in and returns the token response (access_token, refresh_token, session)."""
    if create:
        make_admin(email, role)
    r = google_sign_in(client, email)
    assert r.status_code == 200, r.text
    return r.json()


def bearer(tokens: dict) -> dict:
    return {"Authorization": f"Bearer {tokens['access_token']}"}
