from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import Boolean, DateTime, ForeignKey, Index, Integer, String, UniqueConstraint, Uuid
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base, Timestamps, UUIDPk, utcnow


class User(UUIDPk, Timestamps, Base):
    __tablename__ = "users"

    role: Mapped[str] = mapped_column(String(16), default="advocate", nullable=False)  # advocate | admin
    status: Mapped[str] = mapped_column(String(16), default="active", nullable=False)  # active | disabled
    preferred_language: Mapped[str] = mapped_column(String(8), default="en", nullable=False)
    last_login_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))

    profile: Mapped[AdvocateProfile | None] = relationship(
        back_populates="user", uselist=False, foreign_keys="AdvocateProfile.user_id"
    )
    mobiles: Mapped[list[VerifiedMobile]] = relationship(back_populates="user")


class Advocate(Timestamps, Base):
    """Directory of advocate codes seen in an authorised source (public information)."""

    __tablename__ = "advocates"

    advocate_code: Mapped[str] = mapped_column(String(16), primary_key=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    source: Mapped[str] = mapped_column(String(64), nullable=False)
    fetched_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)


class AdvocateRegistryEntry(Timestamps, Base):
    """Authoritative advocate registry, imported from the official source (scripts/import_registry.py).

    This - not the public Lexika directory in ``advocates`` and not any user-entered data - is what
    decides whether a Google account may be linked to an advocate code.
    """

    __tablename__ = "advocate_registry"

    advocate_code: Mapped[str] = mapped_column(String(16), primary_key=True)
    full_name: Mapped[str] = mapped_column(String(255), nullable=False)
    # Lower-cased, trimmed; NULL when the registry has no email for this advocate.
    email_normalized: Mapped[str | None] = mapped_column(String(320), index=True)
    status: Mapped[str] = mapped_column(String(16), nullable=False)  # active | inactive | suspended | ...
    source: Mapped[str] = mapped_column(String(64), nullable=False)
    source_reference: Mapped[str | None] = mapped_column(String(128))
    imported_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)

    @property
    def is_eligible(self) -> bool:
        return self.status == "active"


class AdvocateProfile(UUIDPk, Timestamps, Base):
    """The link between one user, one advocate code and (once verified) one Google account.

    Unique advocate_code + unique google_sub + unique user_id make the link strictly one-to-one.
    """

    __tablename__ = "advocate_profiles"

    user_id: Mapped[uuid.UUID] = mapped_column(Uuid, ForeignKey("users.id", ondelete="CASCADE"), unique=True)
    advocate_code: Mapped[str] = mapped_column(String(16), ForeignKey("advocates.advocate_code"), unique=True)
    # Google's stable account id ("sub"), taken only from a server-verified ID token.
    google_sub: Mapped[str | None] = mapped_column(String(255), unique=True)
    google_email: Mapped[str | None] = mapped_column(String(320))
    linked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    verification_method: Mapped[str | None] = mapped_column(String(32))  # registry_email_match
    # Name as returned by the source - not user-editable.
    source_name: Mapped[str] = mapped_column(String(255), nullable=False)
    # User-editable presentation fields.
    display_name: Mapped[str | None] = mapped_column(String(255))
    email: Mapped[str | None] = mapped_column(String(255))
    # registry_verified: Google account email matched the advocate registry automatically.
    # legacy_unverified: profile created by the retired mobile-OTP login; cannot sign in until
    # the advocate links a Google account that passes the registry check.
    identity_verification: Mapped[str] = mapped_column(String(24), default="registry_verified", nullable=False)
    identity_verified_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    identity_verified_by: Mapped[uuid.UUID | None] = mapped_column(Uuid, ForeignKey("users.id"))

    user: Mapped[User] = relationship(back_populates="profile", foreign_keys=[user_id])


class VerifiedMobile(UUIDPk, Base):
    __tablename__ = "verified_mobiles"
    __table_args__ = (UniqueConstraint("user_id", "phone_e164"),)

    user_id: Mapped[uuid.UUID] = mapped_column(Uuid, ForeignKey("users.id", ondelete="CASCADE"), index=True)
    phone_e164: Mapped[str] = mapped_column(String(20), nullable=False, index=True)
    is_primary: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    verified_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)

    user: Mapped[User] = relationship(back_populates="mobiles")


class OtpRecord(UUIDPk, Base):
    __tablename__ = "otp_records"
    __table_args__ = (Index("ix_otp_records_phone_created", "phone_e164", "created_at"),)

    phone_e164: Mapped[str] = mapped_column(String(20), nullable=False)
    advocate_code: Mapped[str] = mapped_column(String(16), nullable=False)
    purpose: Mapped[str] = mapped_column(String(16), default="login", nullable=False)
    code_hash: Mapped[str] = mapped_column(String(128), nullable=False)  # HMAC, never the OTP itself
    attempts: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    consumed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)


class AuthSession(UUIDPk, Base):
    __tablename__ = "auth_sessions"

    user_id: Mapped[uuid.UUID] = mapped_column(Uuid, ForeignKey("users.id", ondelete="CASCADE"), index=True)
    device_label: Mapped[str | None] = mapped_column(String(120))
    user_agent: Mapped[str | None] = mapped_column(String(255))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)
    last_seen_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    revoke_reason: Mapped[str | None] = mapped_column(String(64))


class RefreshToken(UUIDPk, Base):
    __tablename__ = "refresh_tokens"

    session_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("auth_sessions.id", ondelete="CASCADE"), index=True
    )
    token_hash: Mapped[str] = mapped_column(String(128), unique=True, nullable=False)
    issued_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    used_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
