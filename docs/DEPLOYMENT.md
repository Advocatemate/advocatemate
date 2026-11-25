# Deployment

## Local development
```
cp .env.example .env          # set JWT_SECRET and OTP_HASH_SECRET
docker compose up --build     # db, redis, api (:8000), worker-enrichment, worker-sync, beat
```
The `api` container runs `alembic upgrade head` on start. Swagger: http://localhost:8000/docs.
Without Docker: PostgreSQL 16 + Redis 7 locally, then in `backend/`:
`alembic upgrade head`, `uvicorn app.main:app --reload`, `celery -A app.workers.celery_app worker -Q enrichment -c 2`,
`celery -A app.workers.celery_app worker -Q sync,default -c 1`, `celery -A app.workers.celery_app beat`.

## Staging / production (recommended shape)
* Managed PostgreSQL 16 (automated daily backups + PITR), managed Redis.
* Container host running four processes from the same image: `api` (2+ replicas behind HTTPS load balancer),
  `worker-enrichment` (concurrency 2), `worker-sync` (concurrency 1), `beat` (**exactly one** instance).
* TLS terminated at the load balancer; HSTS; restrict `/api/v1/admin/*` and `/docs` by IP/VPN.
* Set `FORWARDED_ALLOW_IPS` to the load balancer / reverse proxy address(es): uvicorn trusts `X-Forwarded-For`
  only from them (the client IP feeds rate limits and `ADMIN_ALLOWED_IPS`). Never `*`.
* Admin App (`advocatemate-admin`, separate deployment): do not route `/admin-api` on the public API host; the
  Admin App's own reverse proxy forwards `/api/*` to `/admin-api/v1/*` with `X-Admin-Proxy-Key`. Set
  `ADMIN_API_ENABLED=true`, `ADMIN_APP_ORIGINS`, `ADMIN_PROXY_SECRET` — see [ADMIN_APP_API.md](ADMIN_APP_API.md).
* Admin phone app: `/admin-mobile/v1` is served on the normal API host (phones connect directly). Set
  `ADMIN_MOBILE_API_ENABLED=true` and `ADMIN_MOBILE_GOOGLE_CLIENT_IDS` — see [ADMIN_MOBILE_API.md](ADMIN_MOBILE_API.md).
* Persistent volume or object storage for `STORAGE_DIR` (cached PDFs).
* Secrets (JWT/OTP secrets, DB URL, FCM service account, SMS provider keys) from the platform secret manager.
* Separate databases, Redis, Firebase projects and secrets per environment.
* Observability: `SENTRY_DSN`, JSON logs shipped to the platform log store; alerts on job failures,
  open circuits (`/admin/source-health`) and stale live board.

## Release procedure
1. CI green on the branch (backend + mobile workflows).
2. Deploy image to **staging**; `alembic upgrade head` runs on start; run `scripts/e2e_local.py` against staging.
3. Owner approval → deploy to production. **No automatic production deployment is configured.**

## Backups & restore
* `pg_dump -Fc -d $DATABASE_URL -f advocatemate-$(date +%F).dump` (in addition to managed snapshots).
* Restore drill monthly: `pg_restore -d <scratch_db> --clean --if-exists dump` then `alembic current` and
  `pytest`-style smoke via `/health/ready`.
* Redis holds only broker/rate-limit state; no backup needed.

## Rollback
Redeploy the previous image. Migrations are additive; `0001` has a full downgrade path. Never run
`alembic downgrade` in production without a fresh backup and owner approval.
