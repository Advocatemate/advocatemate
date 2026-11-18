"""Factories for upstream clients (overridable in tests) and the parsed-data cache."""

from __future__ import annotations

from datetime import datetime, timedelta

from sqlalchemy.orm import Session

from app.db.base import as_utc, utcnow
from app.integrations.aphc.client import AphcClient
from app.integrations.lexika.client import LexikaClient
from app.models import SourceCache


def aphc_client() -> AphcClient:
    return AphcClient()


def lexika_client() -> LexikaClient:
    return LexikaClient()


def cache_get(db: Session, key: str, *, allow_stale: bool = False) -> tuple[dict | None, datetime | None, bool]:
    """Returns (payload, fetched_at, is_fresh)."""
    row = db.get(SourceCache, key)
    if row is None:
        return None, None, False
    fresh = as_utc(row.expires_at) > utcnow()
    if not fresh and not allow_stale:
        return None, as_utc(row.fetched_at), False
    return row.payload, as_utc(row.fetched_at), fresh


def cache_put(db: Session, key: str, payload: dict, ttl_seconds: int) -> datetime:
    now = utcnow()
    row = db.get(SourceCache, key)
    if row is None:
        row = SourceCache(key=key, payload=payload, fetched_at=now, expires_at=now + timedelta(seconds=ttl_seconds))
        db.add(row)
    else:
        row.payload = payload
        row.fetched_at = now
        row.expires_at = now + timedelta(seconds=ttl_seconds)
    db.flush()
    return now
