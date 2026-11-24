from __future__ import annotations

import uuid

from sqlalchemy.orm import Session

from app.core.logging import redact_mapping
from app.core.security import hash_ip
from app.models import AuditRecord


def record(db: Session, action: str, *, actor: uuid.UUID | None = None, actor_admin: uuid.UUID | None = None,
           target_type: str | None = None, target_id: str | None = None, ip: str | None = None, **details) -> None:
    """Append an audit record. ``actor`` is an advocate user; ``actor_admin`` an admin-portal account."""
    db.add(AuditRecord(actor_user_id=actor, actor_admin_id=actor_admin, action=action, target_type=target_type,
                       target_id=target_id, ip_hash=hash_ip(ip), details=redact_mapping(details)))
