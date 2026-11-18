"""Celery task bodies, executed synchronously (no broker needed)."""

from datetime import datetime, timedelta
from zoneinfo import ZoneInfo

from sqlalchemy import func, select

from app.db.base import utcnow
from app.models import CauseList, LexikaCaseStatusEnrichmentJob, OtpRecord, PublicationStatus
from app.tasks import jobs


def test_court_hours_window():
    ist = ZoneInfo("Asia/Kolkata")
    assert jobs.court_hours(datetime(2026, 11, 18, 11, 0, tzinfo=ist))  # Wednesday
    assert not jobs.court_hours(datetime(2026, 11, 18, 20, 0, tzinfo=ist))
    assert not jobs.court_hours(datetime(2026, 11, 22, 11, 0, tzinfo=ist))  # Sunday


def test_dispatch_runs_jobs_via_worker_task(client, user_headers, monkeypatch, engine):
    client.get("/api/v1/case-details?case_number=WP/11111/2026", headers=user_headers)
    monkeypatch.setattr(jobs.run_enrichment_job, "delay", lambda job_id, owner: jobs.run_enrichment_job(job_id, owner))
    assert jobs.dispatch_enrichment() == 1
    with engine.connect() as c:
        assert c.execute(select(LexikaCaseStatusEnrichmentJob.status)).scalar() == "succeeded"


def test_polling_tasks(client, fake_aphc, engine):
    assert jobs.poll_display_board(force=True) == 5
    assert jobs.poll_display_board() in (5, "outside_court_hours")
    res = jobs.poll_publication_status()
    assert res["changes"] == 3
    with engine.connect() as c:
        assert c.execute(select(func.count()).select_from(PublicationStatus)).scalar() == 3
    assert jobs.poll_publication_status()["changes"] == 0  # idempotent


def test_sync_latest_daily_lists(client, fake_aphc, engine):
    result = jobs.sync_latest_daily_lists()
    assert result["synced"] == 2 and result["failed"] == []
    with engine.connect() as c:
        assert c.execute(select(func.count()).select_from(CauseList)).scalar() == 2


def test_housekeeping_retention(client, engine):
    with engine.begin() as c:
        c.execute(OtpRecord.__table__.insert().values(
            id=__import__("uuid").uuid4(), phone_e164="+919876543210", advocate_code="1", purpose="login",
            code_hash="x$y", attempts=0, expires_at=utcnow(), created_at=utcnow() - timedelta(days=2)))
    assert jobs.housekeeping()["otps"] == 1


def test_notify_favourites_task(client, user_headers):
    client.post("/api/v1/favourites/advocates", headers=user_headers, json={"advocate_code": "12345"})
    out = jobs.notify_favourites()
    assert out["advocates"] == 1
