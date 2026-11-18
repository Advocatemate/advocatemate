"""The five Lexika projection / job / safety tables named in the handover."""

from __future__ import annotations

import uuid
from datetime import date, datetime

from sqlalchemy import Date, DateTime, ForeignKey, Index, Integer, String, Text, UniqueConstraint, Uuid, text
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, JsonType, Timestamps, UUIDPk, utcnow


class LexikaCaseStatusCache(UUIDPk, Base):
    __tablename__ = "lexika_case_status_cache"

    case_id: Mapped[uuid.UUID] = mapped_column(Uuid, ForeignKey("cases.id", ondelete="CASCADE"), unique=True)
    compact_key: Mapped[str] = mapped_column(String(40), unique=True, nullable=False)
    main_number: Mapped[str | None] = mapped_column(String(64))
    sr_number: Mapped[str | None] = mapped_column(String(64))
    petitioner: Mapped[str | None] = mapped_column(Text)
    respondent: Mapped[str | None] = mapped_column(Text)
    petitioner_advocate: Mapped[str | None] = mapped_column(Text)
    respondent_advocate: Mapped[str | None] = mapped_column(Text)
    case_category: Mapped[str | None] = mapped_column(String(128))
    category: Mapped[str | None] = mapped_column(String(128))
    sub_category: Mapped[str | None] = mapped_column(String(255))
    district: Mapped[str | None] = mapped_column(String(128))
    filing_date: Mapped[date | None] = mapped_column(Date)
    registration_date: Mapped[date | None] = mapped_column(Date)
    listing_date: Mapped[date | None] = mapped_column(Date)
    disposal_date: Mapped[date | None] = mapped_column(Date)
    disposal_type: Mapped[str | None] = mapped_column(String(128))
    status: Mapped[str | None] = mapped_column(String(64))
    purpose: Mapped[str | None] = mapped_column(String(255))
    judges: Mapped[str | None] = mapped_column(Text)
    # Label/value pairs the source returned that have no dedicated column yet.
    extra_fields: Mapped[dict] = mapped_column(JsonType, default=dict)
    # Which of the six operations produced usable sections, e.g. {"vakalath": "present"}.
    sections: Mapped[dict] = mapped_column(JsonType, default=dict)
    source: Mapped[str] = mapped_column(String(64), default="aphc_lexika_chatbot", nullable=False)
    client_version: Mapped[str] = mapped_column(String(16), nullable=False)
    parser_version: Mapped[str] = mapped_column(String(16), nullable=False)
    fetched_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)


class LexikaCaseParty(UUIDPk, Base):
    __tablename__ = "lexika_case_parties"
    __table_args__ = (UniqueConstraint("case_id", "side", "party_no"),)

    case_id: Mapped[uuid.UUID] = mapped_column(Uuid, ForeignKey("cases.id", ondelete="CASCADE"), index=True)
    side: Mapped[str] = mapped_column(String(1), nullable=False)  # P | R
    party_no: Mapped[int] = mapped_column(Integer, nullable=False)
    name: Mapped[str] = mapped_column(Text, nullable=False)
    description: Mapped[str | None] = mapped_column(Text)
    fetched_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)


class LexikaCaseVakalathMapping(UUIDPk, Base):
    __tablename__ = "lexika_case_vakalath_mappings"
    __table_args__ = (UniqueConstraint("case_id", "side", "party_no", "advocate_name"),)

    case_id: Mapped[uuid.UUID] = mapped_column(Uuid, ForeignKey("cases.id", ondelete="CASCADE"), index=True)
    side: Mapped[str] = mapped_column(String(1), nullable=False)  # P | R as returned ("P/R No.")
    party_no: Mapped[str] = mapped_column(String(16), nullable=False)
    advocate_name: Mapped[str] = mapped_column(String(255), nullable=False)
    advocate_code: Mapped[str | None] = mapped_column(String(16), index=True)
    fetched_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)


JOB_ACTIVE_STATES = ("pending", "running")


class LexikaCaseStatusEnrichmentJob(UUIDPk, Timestamps, Base):
    __tablename__ = "lexika_case_status_enrichment_jobs"
    __table_args__ = (
        # Duplicate prevention: at most one active job per case.
        Index(
            "uq_enrichment_one_active_per_case",
            "case_id",
            unique=True,
            postgresql_where=text("status IN ('pending','running')"),
            sqlite_where=text("status IN ('pending','running')"),
        ),
        Index("ix_enrichment_jobs_due", "status", "next_attempt_at"),
    )

    case_id: Mapped[uuid.UUID] = mapped_column(Uuid, ForeignKey("cases.id", ondelete="CASCADE"), index=True)
    status: Mapped[str] = mapped_column(String(16), default="pending", nullable=False)
    # pending | running | succeeded | failed | cancelled
    attempts: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    max_attempts: Mapped[int] = mapped_column(Integer, default=3, nullable=False)
    next_attempt_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)
    lease_owner: Mapped[str | None] = mapped_column(String(64))
    lease_expires_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    started_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    finished_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    last_error_code: Mapped[str | None] = mapped_column(String(48))
    last_error_message: Mapped[str | None] = mapped_column(String(500))
    requested_by_user_id: Mapped[uuid.UUID | None] = mapped_column(Uuid, ForeignKey("users.id", ondelete="SET NULL"))


class LexikaSafetyCircuit(Base):
    """Per-upstream circuit breaker + health record (one row per source name)."""

    __tablename__ = "lexika_safety_circuits"

    name: Mapped[str] = mapped_column(String(64), primary_key=True)
    state: Mapped[str] = mapped_column(String(16), default="closed", nullable=False)  # closed|open|half_open
    consecutive_failures: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    opened_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    open_until: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    last_success_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    last_failure_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    last_error_code: Mapped[str | None] = mapped_column(String(48))
    last_latency_ms: Mapped[int | None] = mapped_column(Integer)
    total_successes: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    total_failures: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, onupdate=utcnow)
