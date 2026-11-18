"""Favourites, devices, notifications, PDFs, source cache, audit and search history."""

from __future__ import annotations

import uuid
from datetime import date, datetime

from sqlalchemy import (
    BigInteger,
    Boolean,
    Date,
    DateTime,
    ForeignKey,
    Index,
    String,
    Text,
    UniqueConstraint,
    Uuid,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, JsonType, UUIDPk, utcnow


class FavouriteAdvocate(UUIDPk, Base):
    __tablename__ = "favourite_advocates"
    __table_args__ = (UniqueConstraint("user_id", "advocate_code"),)

    user_id: Mapped[uuid.UUID] = mapped_column(Uuid, ForeignKey("users.id", ondelete="CASCADE"), index=True)
    advocate_code: Mapped[str] = mapped_column(String(16), ForeignKey("advocates.advocate_code"), nullable=False)
    label: Mapped[str | None] = mapped_column(String(120))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)


class FavouriteCase(UUIDPk, Base):
    __tablename__ = "favourite_cases"
    __table_args__ = (UniqueConstraint("user_id", "case_id"),)

    user_id: Mapped[uuid.UUID] = mapped_column(Uuid, ForeignKey("users.id", ondelete="CASCADE"), index=True)
    case_id: Mapped[uuid.UUID] = mapped_column(Uuid, ForeignKey("cases.id", ondelete="CASCADE"), index=True)
    note: Mapped[str | None] = mapped_column(String(255))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)


class DeviceToken(UUIDPk, Base):
    __tablename__ = "device_tokens"

    user_id: Mapped[uuid.UUID] = mapped_column(Uuid, ForeignKey("users.id", ondelete="CASCADE"), index=True)
    platform: Mapped[str] = mapped_column(String(16), nullable=False)  # android | ios
    token: Mapped[str] = mapped_column(String(512), unique=True, nullable=False)
    app_version: Mapped[str | None] = mapped_column(String(32))
    locale: Mapped[str | None] = mapped_column(String(8))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)
    last_seen_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class NotificationPreference(Base):
    __tablename__ = "notification_preferences"

    user_id: Mapped[uuid.UUID] = mapped_column(Uuid, ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    cause_list_publication: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    favourite_advocates: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    case_updates: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    court_board: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    enrichment: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    announcements: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)


class Notification(UUIDPk, Base):
    __tablename__ = "notifications"
    __table_args__ = (
        Index("ix_notifications_user_created", "user_id", "created_at"),
        # Idempotency: the same event never notifies the same user twice.
        UniqueConstraint("user_id", "dedupe_key"),
    )

    user_id: Mapped[uuid.UUID] = mapped_column(Uuid, ForeignKey("users.id", ondelete="CASCADE"))
    category: Mapped[str] = mapped_column(String(32), nullable=False)
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    body: Mapped[str] = mapped_column(Text, nullable=False)
    deep_link: Mapped[str | None] = mapped_column(String(255))
    data: Mapped[dict] = mapped_column(JsonType, default=dict)
    dedupe_key: Mapped[str] = mapped_column(String(160), nullable=False)
    read_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    delivery_status: Mapped[str] = mapped_column(String(16), default="pending", nullable=False)
    # pending | sent | failed | skipped (push disabled / no device / preference off)
    delivery_error: Mapped[str | None] = mapped_column(String(255))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)


class PdfDocument(UUIDPk, Base):
    __tablename__ = "pdf_documents"
    __table_args__ = (Index("ix_pdf_documents_kind_key", "kind", "cache_key", unique=True),)

    kind: Mapped[str] = mapped_column(String(32), nullable=False)
    # weekly_cause_list | court_cause_list | case_summary_generated
    cache_key: Mapped[str] = mapped_column(String(160), nullable=False)
    is_official: Mapped[bool] = mapped_column(Boolean, nullable=False)
    source_url: Mapped[str | None] = mapped_column(String(512))
    storage_path: Mapped[str] = mapped_column(String(512), nullable=False)
    sha256: Mapped[str] = mapped_column(String(64), nullable=False)
    size_bytes: Mapped[int] = mapped_column(BigInteger, nullable=False)
    case_id: Mapped[uuid.UUID | None] = mapped_column(Uuid, ForeignKey("cases.id", ondelete="CASCADE"))
    list_date: Mapped[date | None] = mapped_column(Date)
    court_no: Mapped[str | None] = mapped_column(String(16))
    source_last_modified: Mapped[str | None] = mapped_column(String(64))
    fetched_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)


class SourceCache(Base):
    """Short-lived cache of parsed (never raw) upstream data, keyed by purpose."""

    __tablename__ = "source_cache"

    key: Mapped[str] = mapped_column(String(160), primary_key=True)
    payload: Mapped[dict] = mapped_column(JsonType, nullable=False)
    fetched_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)


class AuditRecord(UUIDPk, Base):
    __tablename__ = "audit_records"
    __table_args__ = (Index("ix_audit_records_created", "created_at"),)

    actor_user_id: Mapped[uuid.UUID | None] = mapped_column(Uuid, ForeignKey("users.id", ondelete="SET NULL"))
    action: Mapped[str] = mapped_column(String(64), nullable=False)
    target_type: Mapped[str | None] = mapped_column(String(32))
    target_id: Mapped[str | None] = mapped_column(String(64))
    ip_hash: Mapped[str | None] = mapped_column(String(64))
    details: Mapped[dict] = mapped_column(JsonType, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)


class SearchHistory(UUIDPk, Base):
    __tablename__ = "search_history"
    __table_args__ = (Index("ix_search_history_user_created", "user_id", "created_at"),)

    user_id: Mapped[uuid.UUID] = mapped_column(Uuid, ForeignKey("users.id", ondelete="CASCADE"))
    query: Mapped[str] = mapped_column(String(120), nullable=False)
    filters: Mapped[dict] = mapped_column(JsonType, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)
