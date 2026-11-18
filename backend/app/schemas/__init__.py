"""Request/response schemas for /api/v1."""

from __future__ import annotations

from datetime import date, datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class _In(BaseModel):
    model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)


# ------------------------------------------------------------------ auth
class RegisterIn(_In):
    advocate_code: str = Field(min_length=1, max_length=8, pattern=r"^\d+$")


class RegisterOut(BaseModel):
    advocate_code: str
    advocate_name: str
    source: str
    already_registered: bool
    registered_mobile_hint: str | None
    otp_available: bool
    identity_note: str


class SendOtpIn(_In):
    advocate_code: str = Field(min_length=1, max_length=8, pattern=r"^\d+$")
    mobile: str = Field(min_length=10, max_length=16)
    identity_confirmed: bool = Field(description="User confirmed the advocate name returned by the source is theirs")


class SendOtpOut(BaseModel):
    otp_id: str
    expires_in: int
    sent_to: str
    advocate_name: str
    dev_otp: str | None = Field(default=None, description="Development/test environments only")


class VerifyOtpIn(_In):
    advocate_code: str = Field(min_length=1, max_length=8, pattern=r"^\d+$")
    mobile: str = Field(min_length=10, max_length=16)
    otp: str = Field(min_length=4, max_length=8, pattern=r"^\d+$")
    device_label: str | None = Field(default=None, max_length=120)


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
    identity_verification: str | None
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


class AdminVerifyIn(_In):
    advocate_code: str = Field(pattern=r"^\d+$")
    decision: Literal["verified", "rejected", "self_declared"]


class DateParam(BaseModel):
    value: date
