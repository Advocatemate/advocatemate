from __future__ import annotations

import uuid
from datetime import date, datetime

from sqlalchemy import Date, DateTime, ForeignKey, Integer, String, UniqueConstraint, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, Timestamps, UUIDPk, utcnow


class Case(UUIDPk, Timestamps, Base):
    """Canonical case identity. Details live in the lexika_* projections."""

    __tablename__ = "cases"
    __table_args__ = (UniqueConstraint("case_type", "case_number", "case_year"),)

    case_type: Mapped[str] = mapped_column(String(20), nullable=False)
    case_number: Mapped[str] = mapped_column(String(8), nullable=False)
    case_year: Mapped[int] = mapped_column(Integer, nullable=False)
    canonical_key: Mapped[str] = mapped_column(String(40), unique=True, nullable=False)  # slash form
    compact_key: Mapped[str] = mapped_column(String(40), unique=True, nullable=False)  # Lexika form


class AdvocateCaseLink(UUIDPk, Base):
    """An advocate-to-case association *as reported by the source* for a list date.

    Rows are only created from the APHC Lexika "Advocate Code Wise Search"
    response, which is the source asserting the association.
    """

    __tablename__ = "advocate_case_links"
    __table_args__ = (
        UniqueConstraint("advocate_code", "case_id", "list_date", "court_no", "item_no", "application_key"),
    )

    advocate_code: Mapped[str] = mapped_column(String(16), nullable=False, index=True)
    case_id: Mapped[uuid.UUID] = mapped_column(Uuid, ForeignKey("cases.id", ondelete="CASCADE"), index=True)
    list_date: Mapped[date] = mapped_column(Date, nullable=False, index=True)
    court_no: Mapped[str] = mapped_column(String(16), nullable=False)
    item_no: Mapped[str] = mapped_column(String(16), nullable=False)
    list_type: Mapped[str] = mapped_column(String(32), nullable=False)
    application_key: Mapped[str] = mapped_column(String(40), default="", nullable=False)
    application_description: Mapped[str | None] = mapped_column(String(255))
    source: Mapped[str] = mapped_column(String(64), nullable=False)
    fetched_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)
