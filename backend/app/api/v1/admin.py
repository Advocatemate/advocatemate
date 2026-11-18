"""Administration - role-protected, aggregate/diagnostic data only (no OTPs, tokens, cookies or phone numbers)."""

from __future__ import annotations

from datetime import timedelta

from fastapi import APIRouter, Depends, Query
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.api.deps import CurrentUser, require_admin
from app.core.errors import NotFound
from app.db.base import as_utc, utcnow
from app.db.session import get_db
from app.models import (
    AdvocateProfile,
    AuditRecord,
    AuthSession,
    CauseList,
    DeviceToken,
    LexikaCaseStatusCache,
    LexikaCaseStatusEnrichmentJob,
    LexikaSafetyCircuit,
    Notification,
    PublicationStatus,
    SourceCache,
    User,
)
from app.schemas import AdminVerifyIn
from app.services import audit, circuit

router = APIRouter(prefix="/admin", tags=["admin"])


def _count(db: Session, stmt) -> int:
    return db.scalar(select(func.count()).select_from(stmt.subquery())) or 0


@router.get("/dashboard")
def dashboard(_: CurrentUser = Depends(require_admin), db: Session = Depends(get_db)):
    day = utcnow() - timedelta(days=1)
    return {
        "users": {
            "total": _count(db, select(User.id).where(User.deleted_at.is_(None))),
            "advocates": _count(db, select(AdvocateProfile.id)),
            "identity_verified": _count(db, select(AdvocateProfile.id)
                                        .where(AdvocateProfile.identity_verification == "verified")),
            "active_sessions_24h": _count(db, select(AuthSession.id).where(AuthSession.last_seen_at >= day,
                                                                           AuthSession.revoked_at.is_(None))),
            "push_devices": _count(db, select(DeviceToken.id).where(DeviceToken.revoked_at.is_(None))),
        },
        "data": {
            "cause_lists_synced": _count(db, select(CauseList.id)),
            "cases_enriched": _count(db, select(LexikaCaseStatusCache.id)),
        },
        "jobs": _job_counts(db),
        "notifications_24h": {
            s: _count(db, select(Notification.id).where(Notification.created_at >= day,
                                                        Notification.delivery_status == s))
            for s in ("pending", "sent", "failed", "skipped")
        },
    }


def _job_counts(db: Session) -> dict:
    rows = db.execute(select(LexikaCaseStatusEnrichmentJob.status, func.count())
                      .group_by(LexikaCaseStatusEnrichmentJob.status)).all()
    return {status: n for status, n in rows}


@router.get("/sync-status")
def sync_status(_: CurrentUser = Depends(require_admin), db: Session = Depends(get_db)):
    lists = db.execute(select(CauseList.list_type, CauseList.list_date, func.count(), func.max(CauseList.fetched_at),
                              func.sum(CauseList.item_count))
                       .group_by(CauseList.list_type, CauseList.list_date)
                       .order_by(CauseList.list_date.desc()).limit(30)).all()
    failed = db.execute(select(CauseList.list_type, CauseList.list_date, CauseList.court_no, CauseList.error)
                        .where(CauseList.status == "failed").limit(50)).all()
    pub = db.scalar(select(func.max(PublicationStatus.fetched_at)))
    caches = db.scalars(select(SourceCache).order_by(SourceCache.fetched_at.desc()).limit(50)).all()
    now = utcnow()
    return {
        "cause_lists": [{"list_type": t, "list_date": d, "courts_synced": n, "last_fetched_at": as_utc(f),
                         "items": int(i or 0)} for t, d, n, f, i in lists],
        "failed_courts": [{"list_type": t, "list_date": d, "court_no": c, "error": e} for t, d, c, e in failed],
        "publication_status_fetched_at": as_utc(pub),
        "cache_freshness": [{"key": c.key.split(":")[0] + ":" + ("…" if c.key.count(":") else ""),
                             "fetched_at": as_utc(c.fetched_at), "fresh": as_utc(c.expires_at) > now}
                            for c in caches],
    }


@router.get("/jobs")
def jobs(status: str | None = Query(None, pattern="^(pending|running|succeeded|failed|cancelled)$"),
         limit: int = Query(50, ge=1, le=200), _: CurrentUser = Depends(require_admin), db: Session = Depends(get_db)):
    stmt = select(LexikaCaseStatusEnrichmentJob).order_by(LexikaCaseStatusEnrichmentJob.updated_at.desc())
    if status:
        stmt = stmt.where(LexikaCaseStatusEnrichmentJob.status == status)
    from app.models import Case

    out = []
    for j in db.scalars(stmt.limit(limit)):
        case = db.get(Case, j.case_id)
        out.append({"id": str(j.id), "case": case.canonical_key if case else None, "status": j.status,
                    "attempts": j.attempts, "max_attempts": j.max_attempts,
                    "next_attempt_at": as_utc(j.next_attempt_at), "error_code": j.last_error_code,
                    "error": j.last_error_message, "created_at": as_utc(j.created_at),
                    "finished_at": as_utc(j.finished_at)})
    return {"counts": _job_counts(db), "items": out}


@router.post("/jobs/{job_id}/retry", status_code=202)
def retry_job(job_id: str, current: CurrentUser = Depends(require_admin), db: Session = Depends(get_db)):
    import uuid

    job = db.get(LexikaCaseStatusEnrichmentJob, uuid.UUID(job_id))
    if job is None:
        raise NotFound("Job not found")
    if job.status == "failed":
        job.status, job.attempts, job.next_attempt_at = "pending", 0, utcnow()
        job.last_error_code = job.last_error_message = None
        audit.record(db, "admin_job_retry", actor=current.id, target_type="job", target_id=job_id)
    return {"id": job_id, "status": job.status}


@router.get("/source-health")
def source_health(_: CurrentUser = Depends(require_admin), db: Session = Depends(get_db)):
    rows = {r.name: r for r in db.scalars(select(LexikaSafetyCircuit))}
    out = []
    for name in circuit.ALL_SOURCES:
        r = rows.get(name)
        out.append({
            "source": name,
            "state": r.state if r else "unknown",
            "consecutive_failures": r.consecutive_failures if r else 0,
            "open_until": as_utc(r.open_until) if r else None,
            "last_success_at": as_utc(r.last_success_at) if r else None,
            "last_failure_at": as_utc(r.last_failure_at) if r else None,
            "last_error_code": r.last_error_code if r else None,
            "last_latency_ms": r.last_latency_ms if r else None,
            "totals": {"success": r.total_successes, "failure": r.total_failures} if r else None,
        })
    return {"sources": out}


@router.post("/source-health/{name}/reset", status_code=202)
def reset_circuit(name: str, current: CurrentUser = Depends(require_admin), db: Session = Depends(get_db)):
    if name not in circuit.ALL_SOURCES:
        raise NotFound("Unknown source")
    circuit.reset(name)
    audit.record(db, "admin_circuit_reset", actor=current.id, target_type="source", target_id=name)
    return {"source": name, "state": "closed"}


@router.get("/audit")
def audit_log(limit: int = Query(100, ge=1, le=500), _: CurrentUser = Depends(require_admin),
              db: Session = Depends(get_db)):
    rows = db.scalars(select(AuditRecord).order_by(AuditRecord.created_at.desc()).limit(limit))
    return {"items": [{"action": r.action, "actor": str(r.actor_user_id) if r.actor_user_id else None,
                       "target_type": r.target_type, "target_id": r.target_id, "details": r.details,
                       "created_at": as_utc(r.created_at)} for r in rows]}


@router.post("/advocates/verify")
def verify_advocate(body: AdminVerifyIn, current: CurrentUser = Depends(require_admin), db: Session = Depends(get_db)):
    p = db.scalar(select(AdvocateProfile).where(AdvocateProfile.advocate_code == body.advocate_code))
    if p is None:
        raise NotFound("No account for this advocate code")
    p.identity_verification = body.decision
    p.identity_verified_at = utcnow() if body.decision == "verified" else None
    p.identity_verified_by = current.id if body.decision == "verified" else None
    audit.record(db, "admin_identity_decision", actor=current.id, target_type="advocate",
                 target_id=body.advocate_code, decision=body.decision)
    return {"advocate_code": body.advocate_code, "identity_verification": body.decision}
