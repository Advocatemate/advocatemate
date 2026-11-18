from __future__ import annotations

import uuid
from datetime import date, datetime

from sqlalchemy import Date, DateTime, ForeignKey, Integer, String, Text, UniqueConstraint, Uuid
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base, JsonType, Timestamps, UUIDPk, utcnow


class Court(Timestamps, Base):
    __tablename__ = "courts"

    court_no: Mapped[str] = mapped_column(String(16), primary_key=True)
    bench_code: Mapped[str | None] = mapped_column(String(64))
    coram: Mapped[str | None] = mapped_column(String(255))


class CauseList(UUIDPk, Base):
    """One court's list for one date and list type (D/W/S), as published by APHC."""

    __tablename__ = "cause_lists"
    __table_args__ = (UniqueConstraint("list_type", "list_date", "court_no"),)

    list_type: Mapped[str] = mapped_column(String(1), nullable=False)  # D | W | S
    list_date: Mapped[date] = mapped_column(Date, nullable=False, index=True)
    court_no: Mapped[str] = mapped_column(String(16), nullable=False)
    bench: Mapped[str | None] = mapped_column(String(255))
    headings: Mapped[list] = mapped_column(JsonType, default=list)  # hearing notes / list titles
    item_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    content_hash: Mapped[str | None] = mapped_column(String(64))
    status: Mapped[str] = mapped_column(String(16), default="synced", nullable=False)  # synced|empty|failed
    error: Mapped[str | None] = mapped_column(String(255))
    fetched_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)

    items: Mapped[list[CauseListItem]] = relationship(
        back_populates="cause_list", cascade="all, delete-orphan", order_by="CauseListItem.sequence"
    )


class CauseListItem(UUIDPk, Base):
    __tablename__ = "cause_list_items"
    __table_args__ = (UniqueConstraint("cause_list_id", "sequence"),)

    cause_list_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("cause_lists.id", ondelete="CASCADE"), index=True
    )
    sequence: Mapped[int] = mapped_column(Integer, nullable=False)  # original order in source
    item_no: Mapped[str] = mapped_column(String(16), nullable=False)
    list_section: Mapped[str | None] = mapped_column(String(255))
    stage: Mapped[str | None] = mapped_column(String(255))
    case_id: Mapped[uuid.UUID | None] = mapped_column(Uuid, ForeignKey("cases.id"), index=True)
    case_display: Mapped[str] = mapped_column(String(64), nullable=False)
    applications: Mapped[list] = mapped_column(JsonType, default=list)
    petitioner: Mapped[str | None] = mapped_column(Text)
    respondent: Mapped[str | None] = mapped_column(Text)
    petitioner_advocates: Mapped[list] = mapped_column(JsonType, default=list)
    respondent_advocates: Mapped[list] = mapped_column(JsonType, default=list)
    district: Mapped[str | None] = mapped_column(String(128))
    remarks: Mapped[str | None] = mapped_column(Text)

    cause_list: Mapped[CauseList] = relationship(back_populates="items")


class PublicationStatus(UUIDPk, Base):
    """Court-wise publication status from APHC online_board.jsp.

    Video-conference meeting IDs/pass-codes on that page are deliberately NOT stored.
    """

    __tablename__ = "publication_statuses"
    __table_args__ = (UniqueConstraint("list_date", "court_no"),)

    list_date: Mapped[date] = mapped_column(Date, nullable=False, index=True)
    court_no: Mapped[str] = mapped_column(String(16), nullable=False)
    bench_code: Mapped[str | None] = mapped_column(String(64))
    coram: Mapped[str | None] = mapped_column(String(255))
    status: Mapped[str] = mapped_column(String(64), nullable=False)
    uploaded_at_text: Mapped[str | None] = mapped_column(String(32))
    pdf_path: Mapped[str | None] = mapped_column(String(255))
    fetched_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)
