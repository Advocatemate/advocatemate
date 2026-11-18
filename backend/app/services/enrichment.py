"""Asynchronous case enrichment (handover section 3).

/case-details -> request_enrichment() -> job row -> worker claims (lease)
-> circuit check -> LexikaClient.case_status() (six ops) -> identity validated
-> replace_case_status() in ONE transaction -> job succeeded -> notification.
"""

from __future__ import annotations

import logging
import uuid
from datetime import timedelta

from sqlalchemy import delete, or_, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.logging import log_event
from app.db.base import as_utc, utcnow
from app.db.session import db_session
from app.integrations.http import UpstreamError, UpstreamIdentityMismatch
from app.integrations.lexika import parsers as lexika_parsers
from app.integrations.lexika.client import CLIENT_VERSION, CaseStatusResult
from app.integrations.lexika.normaliser import normalise_primary
from app.models import (
    Case,
    LexikaCaseParty,
    LexikaCaseStatusCache,
    LexikaCaseStatusEnrichmentJob,
    LexikaCaseVakalathMapping,
    LexikaSafetyCircuit,
)
from app.models.lexika import JOB_ACTIVE_STATES
from app.services import circuit, sources
from app.services.cases import identity_of
from app.utils.case_identity import same_case

logger = logging.getLogger(__name__)


# ---------------------------------------------------------------- requests
def cache_row(db: Session, case_id: uuid.UUID) -> LexikaCaseStatusCache | None:
    return db.scalar(select(LexikaCaseStatusCache).where(LexikaCaseStatusCache.case_id == case_id))


def is_fresh(row: LexikaCaseStatusCache | None) -> bool:
    if row is None:
        return False
    return utcnow() - as_utc(row.fetched_at) < timedelta(hours=get_settings().enrichment_cache_hours)


def active_job(db: Session, case_id: uuid.UUID) -> LexikaCaseStatusEnrichmentJob | None:
    return db.scalar(
        select(LexikaCaseStatusEnrichmentJob).where(
            LexikaCaseStatusEnrichmentJob.case_id == case_id,
            LexikaCaseStatusEnrichmentJob.status.in_(JOB_ACTIVE_STATES),
        )
    )


def latest_job(db: Session, case_id: uuid.UUID) -> LexikaCaseStatusEnrichmentJob | None:
    return db.scalar(
        select(LexikaCaseStatusEnrichmentJob)
        .where(LexikaCaseStatusEnrichmentJob.case_id == case_id)
        .order_by(LexikaCaseStatusEnrichmentJob.created_at.desc())
        .limit(1)
    )


def request_enrichment(
    db: Session, case: Case, *, user_id: uuid.UUID | None = None, force: bool = False
) -> LexikaCaseStatusEnrichmentJob | None:
    """Create a job unless the cache is fresh or one is already active (idempotent)."""
    existing = active_job(db, case.id)
    if existing:
        return existing
    if not force and is_fresh(cache_row(db, case.id)):
        return None
    job = LexikaCaseStatusEnrichmentJob(
        case_id=case.id,
        status="pending",
        attempts=0,
        max_attempts=get_settings().enrichment_max_attempts,
        next_attempt_at=utcnow(),
        requested_by_user_id=user_id,
    )
    try:
        with db.begin_nested():
            db.add(job)
            db.flush()
    except IntegrityError:
        # Another request created the active job concurrently (partial unique index).
        return active_job(db, case.id)
    return job


# ---------------------------------------------------------------- worker side
def claim_due_jobs(owner: str, limit: int | None = None) -> list[uuid.UUID]:
    """Lease due jobs (pending, or running with an expired lease) - SKIP LOCKED safe."""
    s = get_settings()
    limit = limit or s.enrichment_dispatch_batch
    now = utcnow()
    with db_session() as db:
        jobs = db.scalars(
            select(LexikaCaseStatusEnrichmentJob)
            .where(
                or_(
                    (LexikaCaseStatusEnrichmentJob.status == "pending")
                    & (LexikaCaseStatusEnrichmentJob.next_attempt_at <= now),
                    (LexikaCaseStatusEnrichmentJob.status == "running")
                    & (LexikaCaseStatusEnrichmentJob.lease_expires_at < now),
                )
            )
            .order_by(LexikaCaseStatusEnrichmentJob.next_attempt_at)
            .limit(limit)
            .with_for_update(skip_locked=True)
        ).all()
        ids = []
        for job in jobs:
            job.status = "running"
            job.lease_owner = owner
            job.lease_expires_at = now + timedelta(seconds=s.enrichment_lease_seconds)
            job.attempts += 1
            job.started_at = now
            ids.append(job.id)
        return ids


def _finish(job_id: uuid.UUID, owner: str, *, status: str, code: str | None = None, message: str | None = None,
            retry_at=None, refund_attempt: bool = False) -> LexikaCaseStatusEnrichmentJob | None:
    with db_session() as db:
        job = db.get(LexikaCaseStatusEnrichmentJob, job_id, with_for_update=True)
        if job is None or job.lease_owner != owner:
            return None  # lease lost to another worker; do not overwrite its outcome
        job.status = status
        job.last_error_code = code
        job.last_error_message = (message or "")[:500] or None
        job.lease_owner = None
        job.lease_expires_at = None
        if refund_attempt and job.attempts > 0:
            job.attempts -= 1
        if retry_at is not None:
            job.next_attempt_at = retry_at
        if status in ("succeeded", "failed"):
            job.finished_at = utcnow()
        db.flush()
        db.expunge(job)
        return job


def run_job(job_id: uuid.UUID, owner: str) -> str:
    """Execute one leased job. Returns the final job status."""
    s = get_settings()
    with db_session() as db:
        job = db.get(LexikaCaseStatusEnrichmentJob, job_id)
        if job is None or job.status != "running" or job.lease_owner != owner:
            return "skipped"
        case = db.get(Case, job.case_id)
        identity = identity_of(case)
        attempts, max_attempts = job.attempts, job.max_attempts
        case_id = case.id

    try:
        circuit.check(circuit.LEXIKA)
    except circuit.CircuitOpen:
        with db_session() as db:
            row = db.get(LexikaSafetyCircuit, circuit.LEXIKA)
            retry_at = as_utc(row.open_until) if row and row.open_until else utcnow() + timedelta(seconds=60)
        _finish(job_id, owner, status="pending", code="circuit_open", message="source paused",
                retry_at=retry_at, refund_attempt=True)
        return "pending"

    try:
        result = circuit.call(circuit.LEXIKA, lambda: sources.lexika_client().case_status(identity))
        if not same_case(result.identity, identity):
            raise UpstreamIdentityMismatch("result identity differs from job case")
    except UpstreamError as e:
        retry = e.retryable and attempts < max_attempts
        if retry:
            delay = s.enrichment_backoff_base_seconds * (2 ** (attempts - 1))
            _finish(job_id, owner, status="pending", code=e.code, message=str(e),
                    retry_at=utcnow() + timedelta(seconds=delay))
            log_event(logger, logging.INFO, "enrichment retry scheduled", case=identity.slash, code=e.code)
            return "pending"
        _finish(job_id, owner, status="failed", code=e.code, message=str(e))
        log_event(logger, logging.WARNING, "enrichment failed", case=identity.slash, code=e.code)
        _notify(case_id, job_id, succeeded=False)
        return "failed"
    except Exception as e:  # noqa: BLE001
        logger.exception("enrichment internal error")
        _finish(job_id, owner, status="failed", code="internal_error", message=type(e).__name__)
        return "failed"

    with db_session() as db:
        job = db.get(LexikaCaseStatusEnrichmentJob, job_id, with_for_update=True)
        if job is None or job.lease_owner != owner:
            return "skipped"
        replace_case_status(db, db.get(Case, case_id), result)
        job.status = "succeeded"
        job.finished_at = utcnow()
        job.lease_owner = None
        job.lease_expires_at = None
        job.last_error_code = None
        job.last_error_message = None
    log_event(logger, logging.INFO, "enrichment succeeded", case=identity.slash, calls=result.calls_made)
    _notify(case_id, job_id, succeeded=True)
    return "succeeded"


def replace_case_status(db: Session, case: Case, result: CaseStatusResult) -> LexikaCaseStatusCache:
    """Atomically replace the projections for one case (caller owns the transaction)."""
    if not same_case(result.identity, identity_of(case)):
        raise UpstreamIdentityMismatch("refusing to store data for a different case")
    # Serialise concurrent replacements of the same case.
    db.get(Case, case.id, with_for_update=True)
    columns, extra = normalise_primary(result.primary)
    now = utcnow()
    row = cache_row(db, case.id)
    if row is None:
        row = LexikaCaseStatusCache(case_id=case.id, compact_key=case.compact_key)
        db.add(row)
    for k, v in columns.items():
        setattr(row, k, v)
    # Clear columns the source no longer returns (no stale carry-over).
    for col in (
        "main_number", "sr_number", "petitioner", "respondent", "petitioner_advocate", "respondent_advocate",
        "case_category", "category", "sub_category", "district", "filing_date", "registration_date",
        "listing_date", "disposal_date", "disposal_type", "status", "purpose", "judges",
    ):
        if col not in columns:
            setattr(row, col, None)
    row.extra_fields = extra
    row.sections = dict(result.section_status) | {"available": result.available_sections}
    row.client_version = CLIENT_VERSION
    row.parser_version = lexika_parsers.PARSER_VERSION
    row.source = "aphc_lexika_chatbot"
    row.fetched_at = now

    # Parties / vakalath: replace only sections that were actually retrieved, so a
    # failed optional section keeps the previous good data instead of wiping it.
    for side, key, entries in (("P", "petitioners", result.petitioners), ("R", "respondents", result.respondents)):
        if result.section_status.get(key) in ("present", "empty"):
            db.execute(delete(LexikaCaseParty).where(LexikaCaseParty.case_id == case.id, LexikaCaseParty.side == side))
            seen = set()
            for p in entries:
                if p.party_no in seen:
                    continue
                seen.add(p.party_no)
                db.add(LexikaCaseParty(case_id=case.id, side=side, party_no=p.party_no, name=p.name,
                                       description=p.description, fetched_at=now))
    if result.section_status.get("vakalath") in ("present", "empty"):
        db.execute(delete(LexikaCaseVakalathMapping).where(LexikaCaseVakalathMapping.case_id == case.id))
        seen_v = set()
        for v in result.vakalath:
            k = (v.side, v.party_no, v.advocate_name)
            if k in seen_v:
                continue
            seen_v.add(k)
            db.add(LexikaCaseVakalathMapping(case_id=case.id, side=v.side, party_no=v.party_no,
                                             advocate_name=v.advocate_name, advocate_code=v.advocate_code,
                                             fetched_at=now))
    db.flush()
    return row


def _notify(case_id: uuid.UUID, job_id: uuid.UUID, *, succeeded: bool) -> None:
    try:
        from app.services import notifications

        notifications.enrichment_finished(case_id, job_id, succeeded)
    except Exception:  # noqa: BLE001
        logger.exception("failed to queue enrichment notification")


# ---------------------------------------------------------------- read side
def status_payload(db: Session, case: Case) -> dict:
    row = cache_row(db, case.id)
    job = active_job(db, case.id) or latest_job(db, case.id)
    if job and job.status in JOB_ACTIVE_STATES:
        state = job.status  # pending | running
    elif job and job.status == "failed" and (row is None or as_utc(job.created_at) > as_utc(row.fetched_at)):
        state = "failed"
    elif row is not None:
        state = "completed"
    else:
        state = "not_requested"
    freshness = None
    if row is not None:
        freshness = "fresh" if is_fresh(row) else "stale"
    return {
        "case_id": str(case.id),
        "state": state,
        "freshness": freshness,
        "fetched_at": as_utc(row.fetched_at) if row else None,
        "job": None
        if job is None
        else {
            "id": str(job.id),
            "status": job.status,
            "attempts": job.attempts,
            "max_attempts": job.max_attempts,
            "next_attempt_at": as_utc(job.next_attempt_at),
            "error_code": job.last_error_code,
        },
        "poll_after_seconds": 3 if state in JOB_ACTIVE_STATES else None,
    }
