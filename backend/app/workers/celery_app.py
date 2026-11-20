"""Celery application.

Queues:
* ``enrichment`` - Lexika case-status jobs. Run with LOW concurrency (default 2)
  so upstream load stays bounded: ``celery -A app.workers.celery_app worker -Q enrichment -c 2``
* ``sync``       - cause-list / board / publication polling (concurrency 1).
* ``default``    - housekeeping.
"""

from __future__ import annotations

from celery import Celery
from celery.schedules import crontab

from app.core.config import get_settings
from app.core.logging import configure_logging

s = get_settings()
configure_logging(s.log_level)

celery_app = Celery("advocatemate", broker=s.redis_url, backend=s.redis_url, include=["app.tasks.jobs"])
celery_app.conf.update(
    task_default_queue="default",
    task_routes={
        "app.tasks.jobs.run_enrichment_job": {"queue": "enrichment"},
        "app.tasks.jobs.dispatch_enrichment": {"queue": "enrichment"},
        "app.tasks.jobs.poll_display_board": {"queue": "sync"},
        "app.tasks.jobs.poll_publication_status": {"queue": "sync"},
        "app.tasks.jobs.sync_latest_daily_lists": {"queue": "sync"},
        "app.tasks.jobs.notify_favourites": {"queue": "sync"},
    },
    task_acks_late=True,
    worker_prefetch_multiplier=1,
    task_time_limit=300,
    task_soft_time_limit=240,
    timezone="Asia/Kolkata",
    enable_utc=True,
    result_expires=3600,
    beat_schedule={
        "dispatch-enrichment": {"task": "app.tasks.jobs.dispatch_enrichment", "schedule": 15.0},
        # Court hours only (IST, Mon-Sat 09:30-18:00): the board is empty otherwise.
        "poll-display-board": {
            "task": "app.tasks.jobs.poll_display_board",
            "schedule": float(s.live_board_poll_seconds),
        },
        "poll-publication-status": {
            "task": "app.tasks.jobs.poll_publication_status",
            "schedule": float(s.publication_poll_minutes * 60),
        },
        "sync-latest-daily-lists": {
            "task": "app.tasks.jobs.sync_latest_daily_lists",
            "schedule": crontab(minute=15, hour="6-9,17-22"),
        },
        # Read published court PDFs after lists are published (evenings) and during court hours.
        "parse-cause-list-pdfs": {
            "task": "app.tasks.jobs.parse_cause_list_pdfs",
            "schedule": crontab(minute="5,35", hour="6-22"),
        },
        "notify-favourites": {"task": "app.tasks.jobs.notify_favourites", "schedule": crontab(minute=40, hour="7,19")},
        "housekeeping": {"task": "app.tasks.jobs.housekeeping", "schedule": crontab(minute=5, hour=3)},
    },
)
