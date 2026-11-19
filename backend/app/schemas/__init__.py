"""Request/response schemas for /api/v1."""

from __future__ import annotations

from datetime import date, datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class _In(BaseModel):
    model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)


# ------------------------------------------------------------------ auth
class GoogleSignInIn(_In):
    id_token: str = Field(min_length=20, max_length=8192, description="Google ID token from Google Sign-In")
    device_label: str | None = Field(default=None, max_length=120)


class GoogleLinkIn(_In):
    link_token: str = Field(min_length=20, max_length=4096)
    advocate_code: str = Field(min_length=1, max_length=8, pattern=r"^\d+$")
    device_label: str | None = Field(default=None, max_length=120)


class GoogleSignInOut(BaseModel):
    status: Literal["signed_in", "advocate_code_required"]
    # signed_in
    access_token: str | None = None
    token_type: Literal["bearer"] | None = None  # noqa: S105
    expires_in: int | None = None
    refresh_token: str | None = None
    session_id: str | None = None
    # advocate_code_required
    link_token: str | None = None
    link_expires_in: int | None = None
    google_email: str | None = None


class TokenOut(BaseModel):
    access_token: str
    token_type: Literal["bearer"] = "bearer"  # noqa: S105
    expires_in: int
    refresh_token: str
    session_id: str


class RefreshIn(_In):
    refresh_token: str = Field(min_length=20, max_length=200)


class MeOut(BaseModel):
    user_id: str
    role: str
    preferred_language: str
    advocate_code: str | None
    advocate_name: str | None
    display_name: str | None
    email: str | None
    google_email: str | None = None
    identity_verification: str | None
    verification_method: str | None = None
    linked_at: datetime | None = None
    mobile: str | None
    created_at: datetime


class ProfileUpdateIn(_In):
    display_name: str | None = Field(default=None, max_length=120)
    email: EmailStr | None = None
    preferred_language: Literal["en", "te"] | None = None


# ------------------------------------------------------------------ favourites
class FavouriteAdvocateIn(_In):
    advocate_code: str = Field(min_length=1, max_length=8, pattern=r"^\d+$")
    label: str | None = Field(default=None, max_length=120)


class FavouriteAdvocateOut(BaseModel):
    id: str
    advocate_code: str
    advocate_name: str | None
    label: str | None
    created_at: datetime


class FavouriteCaseIn(_In):
    case_number: str | None = Field(default=None, max_length=40)
    case_id: str | None = None
    note: str | None = Field(default=None, max_length=255)


class FavouriteCaseOut(BaseModel):
    id: str
    case_id: str
    case_number: str
    note: str | None
    petitioner: str | None
    respondent: str | None
    created_at: datetime


# ------------------------------------------------------------------ devices / notifications
class DeviceIn(_In):
    token: str = Field(min_length=20, max_length=512)
    platform: Literal["android", "ios"]
    app_version: str | None = Field(default=None, max_length=32)
    locale: str | None = Field(default=None, max_length=8)


class DeviceOut(BaseModel):
    id: str
    platform: str
    created_at: datetime


class NotificationOut(BaseModel):
    id: str
    category: str
    title: str
    body: str
    deep_link: str | None
    data: dict
    read: bool
    created_at: datetime


class NotificationPage(BaseModel):
    items: list[NotificationOut]
    unread_count: int
    total: int


class MarkReadIn(_In):
    ids: list[str] = Field(default_factory=list, max_length=200)
    all: bool = False


class PreferencesIO(_In):
    cause_list_publication: bool = True
    favourite_advocates: bool = True
    case_updates: bool = True
    court_board: bool = True
    enrichment: bool = True
    announcements: bool = True


class CaseDetailsQuery(_In):
    case_number: str


class DateParam(BaseModel):
    value: date
