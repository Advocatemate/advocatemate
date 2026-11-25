"""Request and response shapes of /admin-mobile/v1 (mirrored by the Flutter app's Dart models)."""

from __future__ import annotations

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field

from app.admin_api.schemas import AccountOut


class ChallengeOut(BaseModel):
    challenge_id: str
    nonce: str = Field(description="Pass to Google sign-in; the ID token must carry it. Works once.")
    expires_in: int


class DeviceIn(BaseModel):
    installation_id: str = Field(pattern=r"^[A-Za-z0-9-]{8,64}$", description="Random ID created at app install")
    platform: Literal["android", "ios"]
    device_name: str | None = Field(default=None, max_length=120)
    app_version: str | None = Field(default=None, max_length=32)


class GoogleSignInIn(BaseModel):
    challenge_id: str = Field(max_length=64)
    id_token: str = Field(min_length=1, max_length=8192)
    device: DeviceIn


class ReauthIn(BaseModel):
    challenge_id: str = Field(max_length=64)
    id_token: str = Field(min_length=1, max_length=8192)


class RefreshIn(BaseModel):
    refresh_token: str = Field(min_length=1, max_length=256)


class MobileSessionInfo(BaseModel):
    id: str
    client: str
    platform: str | None
    created_at: datetime
    expires_at: datetime
    idle_timeout_minutes: int
    reauth_until: datetime
    access_expires_at: datetime | None


class MobileSessionOut(BaseModel):
    account: AccountOut
    permissions: list[str]
    session: MobileSessionInfo
    environment: str


class TokensOut(BaseModel):
    access_token: str
    token_type: Literal["bearer"] = "bearer"  # noqa: S105 - OAuth token type, not a secret
    expires_in: int = Field(description="Seconds until the access token expires")
    refresh_token: str = Field(description="Single-use; store in the Keychain / Keystore only")
    session: MobileSessionOut


class SessionListItem(BaseModel):
    id: str
    client: str
    platform: str | None
    device_name: str | None
    app_version: str | None
    user_agent: str | None
    created_at: datetime
    last_seen_at: datetime
    expires_at: datetime
    current: bool


class SessionList(BaseModel):
    items: list[SessionListItem]
