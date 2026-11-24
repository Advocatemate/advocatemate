"""Admin portal identity, sessions and operational history (migration 0004).

Admins are separate from advocates: an admin account is an explicitly authorised Google account with a
role, independent of the advocate registry. There is no self-registration.
"""

from __future__ import annotations

import uuid
from datetime import date, datetime

from sqlalchemy import Boolean, Date, DateTime, ForeignKey, Index, Integer, String, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, Timestamps, UUIDPk, utcnow

ADMIN_ROLES = ("owner", "admin", "support")


class AdminAccount(UUIDPk, Timestamps, Base):
    __tablename__ = "admin_accounts"

    email: Mapped[str] = mapped_column(String(320), unique=True, nullable=False)  # lower-case
    google_sub: Mapped[str | None] = mapped_column(String(255), unique=True)  # bound at first sign-in
    display_name: Mapped[str | None] = mapped_column(String(255))
    role: Mapped[str] = mapped_column(String(16), nullable=False)  # owner | admin | support
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    added_by_admin_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid, ForeignKey("admin_accounts.id", ondelete="SET NULL"))
    added_via: Mapped[str] = mapped_column(String(16), default="portal", nullable=False)  # cli | portal
    last_login_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class AdminSession(UUIDPk, Base):
    """Server-side admin session; the browser only holds a random token (stored here as a hash)."""

    __tablename__ = "admin_sessions"

    admin_account_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("admin_accounts.id", ondelete="CASCADE"), index=True, nullable=False)
    token_hash: Mapped[str] = mapped_column(String(64), unique=True, nullable=False)
    csrf_token: Mapped[str] = mapped_column(String(64), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)
    last_seen_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)  # absolute (8 h)
    reauth_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)
    ip_hash: Mapped[str | None] = mapped_column(String(64))
    user_agent: Mapped[str | None] = mapped_column(String(255))
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    revoke_reason: Mapped[str | None] = mapped_column(String(32))


class UserDailyActivity(Base):
    """One row per advocate per (IST) day they used the app - for daily-active-user charts."""

    __tablename__ = "user_daily_activity"

    activity_date: Mapped[date] = mapped_column(Date, primary_key=True)
    user_id: Mapped[uuid.UUID] = mapped_column(Uuid, ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    first_seen_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)


class SyncEvent(UUIDPk, Base):
    """One court cause-list synchronisation attempt (scheduled, app request or admin re-sync)."""

    __tablename__ = "sync_events"
    __table_args__ = (Index("ix_sync_events_list_date_court_no", "list_date", "court_no"),)

    list_type: Mapped[str] = mapped_column(String(1), nullable=False)
    list_date: Mapped[date] = mapped_column(Date, nullable=False)
    court_no: Mapped[str] = mapped_column(String(16), nullable=False)
    trigger: Mapped[str] = mapped_column(String(16), nullable=False)  # scheduled | app | admin
    result: Mapped[str] = mapped_column(String(16), nullable=False)  # synced | empty | failed
    error_code: Mapped[str | None] = mapped_column(String(64))
    item_count: Mapped[int | None] = mapped_column(Integer)
    duration_ms: Mapped[int | None] = mapped_column(Integer)
    admin_account_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid, ForeignKey("admin_accounts.id", ondelete="SET NULL"))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False, index=True)
