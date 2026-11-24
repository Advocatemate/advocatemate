#!/bin/sh
set -e

case "$1" in
  api)
    alembic upgrade head
    exec uvicorn app.main:app --host 0.0.0.0 --port 8000 --proxy-headers --forwarded-allow-ips="${FORWARDED_ALLOW_IPS:-127.0.0.1}" --workers "${WEB_CONCURRENCY:-2}"
    ;;
  worker-enrichment)
    exec celery -A app.workers.celery_app worker -Q enrichment -c "${ENRICHMENT_CONCURRENCY:-2}" --loglevel=INFO
    ;;
  worker-sync)
    exec celery -A app.workers.celery_app worker -Q sync,default -c 1 --loglevel=INFO
    ;;
  beat)
    exec celery -A app.workers.celery_app beat --loglevel=INFO --schedule /tmp/celerybeat-schedule
    ;;
  migrate)
    exec alembic upgrade head
    ;;
  *)
    exec "$@"
    ;;
esac
