"""Per-upstream circuit breaker persisted in ``lexika_safety_circuits``.

closed --(N consecutive failures)--> open --(open_until passes)--> half_open
half_open --success--> closed ; half_open --failure--> open (again)

State changes are committed in their own short transaction so they survive a
rollback of the caller's work.
"""

from __future__ import annotations

import time
from collections.abc import Callable
from contextlib import contextmanager
from datetime import timedelta
from typing import TypeVar

from app.core.config import get_settings
from app.db.base import as_utc, utcnow
from app.db.session import db_session
from app.integrations.http import UpstreamError
from app.models import LexikaSafetyCircuit

T = TypeVar("T")

# Source names (one circuit each).
LEXIKA = "aphc_lexika_chatbot"
HCDBS_CAUSE_LIST = "aphc_hcdbs_cause_list"
HCDBS_PUBLICATION = "aphc_hcdbs_online_board"
HCDBS_DISPLAY = "aphc_hcdbs_display_board"
HCDBS_PDF = "aphc_hcdbs_pdf"
ALL_SOURCES = (LEXIKA, HCDBS_CAUSE_LIST, HCDBS_PUBLICATION, HCDBS_DISPLAY, HCDBS_PDF)

# Errors that say nothing about upstream health (the source answered correctly).
_NEUTRAL_CODES = {"not_found", "identity_mismatch"}


class CircuitOpen(UpstreamError):
    code = "circuit_open"
    retryable = True


def _get(db, name: str) -> LexikaSafetyCircuit:
    row = db.get(LexikaSafetyCircuit, name, with_for_update=True)
    if row is None:
        row = LexikaSafetyCircuit(name=name, state="closed", consecutive_failures=0)
        db.add(row)
        db.flush()
    return row


def check(name: str) -> None:
    with db_session() as db:
        row = _get(db, name)
        if row.state == "open":
            if row.open_until and as_utc(row.open_until) <= utcnow():
                row.state = "half_open"
            else:
                raise CircuitOpen(f"{name} temporarily paused after repeated failures")


def record_success(name: str, latency_ms: int | None = None) -> None:
    with db_session() as db:
        row = _get(db, name)
        row.state = "closed"
        row.consecutive_failures = 0
        row.open_until = None
        row.last_success_at = utcnow()
        row.last_latency_ms = latency_ms
        row.total_successes = (row.total_successes or 0) + 1


def record_failure(name: str, code: str) -> None:
    s = get_settings()
    with db_session() as db:
        row = _get(db, name)
        row.last_failure_at = utcnow()
        row.last_error_code = code[:48]
        row.total_failures = (row.total_failures or 0) + 1
        if code in _NEUTRAL_CODES:
            return
        row.consecutive_failures = (row.consecutive_failures or 0) + 1
        if row.state == "half_open" or row.consecutive_failures >= s.circuit_failure_threshold:
            row.state = "open"
            row.opened_at = utcnow()
            row.open_until = utcnow() + timedelta(seconds=s.circuit_open_seconds)


def reset(name: str) -> None:
    with db_session() as db:
        row = _get(db, name)
        row.state = "closed"
        row.consecutive_failures = 0
        row.open_until = None


def call(name: str, fn: Callable[[], T]) -> T:
    check(name)
    started = time.monotonic()
    try:
        result = fn()
    except UpstreamError as e:
        record_failure(name, e.code)
        raise
    except Exception:
        record_failure(name, "internal_error")
        raise
    record_success(name, int((time.monotonic() - started) * 1000))
    return result


@contextmanager
def guarded(name: str):
    check(name)
    started = time.monotonic()
    try:
        yield
    except UpstreamError as e:
        record_failure(name, e.code)
        raise
    record_success(name, int((time.monotonic() - started) * 1000))
