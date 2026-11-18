from __future__ import annotations

import uuid

from sqlalchemy.orm import Session

from app.core.logging import redact_mapping
from app.core.security import hash_ip
from app.models import AuditRecord


def record(db: Session, action: str, *, actor: uuid.UUID | None = None, target_type: str | None = None,
           target_id: str | None = None, ip: str | None = None, **details) -> None:
    db.add(AuditRecord(actor_user_id=actor, action=action, target_type=target_type, target_id=target_id,
                       ip_hash=hash_ip(ip), details=redact_mapping(details)))
