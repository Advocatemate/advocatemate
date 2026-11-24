"""Request and response shapes of /admin-api/v1 (mirrored by the Admin App's TypeScript types)."""

from __future__ import annotations

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field

Role = Literal["owner", "admin", "support"]


class GoogleCredential(BaseModel):
    credential: str = Field(min_length=1, max_length=8192, description="Google ID token from Google Identity Services")


class NonceOut(BaseModel):
    nonce: str
    client_id: str = Field(description="Google Web OAuth client ID the sign-in button must use")
    expires_in: int


class AccountOut(BaseModel):
    id: str
    email: str
    display_name: str | None
    role: Role
    role_label: str


class SessionInfo(BaseModel):
    id: str
    created_at: datetime
    expires_at: datetime
    idle_timeout_minutes: int
    reauth_until: datetime


class SessionOut(BaseModel):
    account: AccountOut
    permissions: list[str]
    csrf_token: str = Field(description="Send as X-CSRF-Token on every POST/PATCH/PUT/DELETE; keep in memory only")
    session: SessionInfo
    environment: str


class SessionListItem(BaseModel):
    id: str
    created_at: datetime
    last_seen_at: datetime
    expires_at: datetime
    user_agent: str | None
    current: bool


class SessionList(BaseModel):
    items: list[SessionListItem]
