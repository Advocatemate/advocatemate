# Technology stack

| Layer | Choice (version) | Notes |
|---|---|---|
| Mobile | Flutter 3.50.0 / Dart 3.14 (stable) | One codebase for Android + iOS. Uses `material_ui` (Material split from the SDK in Flutter 3.47+). |
| State / routing | flutter_riverpod 3.5, go_router 18.1 | |
| Networking | Dio 5.11 | refresh-token interceptor |
| Models | freezed 4 + json_serializable 6 | snake_case mapping via `build.yaml` |
| Storage | flutter_secure_storage 11 (tokens), path_provider + JSON files (offline cache), shared_preferences (UI prefs) | |
| PDF / share | pdfx 2.11, share_plus 13 | |
| Push / crash | firebase_core, firebase_messaging, firebase_crashlytics | inactive until Firebase config files are supplied |
| Localisation | flutter gen-l10n (ARB), English + Telugu | |
| Backend | Python 3.11, FastAPI 0.115, Pydantic 2.12 | sync SQLAlchemy sessions (threadpool), simpler for Celery reuse |
| ORM / migrations | SQLAlchemy 2.0, Alembic 1.14 | |
| Database | PostgreSQL 16 | JSONB, partial unique index, optional pg_trgm |
| Jobs / cache | Celery 5.4 + Redis 7 | queues: enrichment, sync, default; beat schedules |
| HTTP (upstream) | HTTPX 0.28 | |
| HTML parsing | lxml 6 | |
| Auth | PyJWT 2.10 (HS256) | HMAC-hashed refresh tokens and OTPs |
| PDF generation | ReportLab 4.2 | generated summaries only |
| Monitoring | Sentry SDK, structured JSON logs; Firebase Crashlytics (mobile) | |
| Tests | pytest, respx, Flutter test, integration_test | |
| Lint | ruff, flutter_lints | |
| CI | GitHub Actions | no deploy step |
| Containers | Docker, docker compose | |

## Deviations from the supplied spreadsheet
The spreadsheet assumed an *existing* Python backend with a database-backed worker and SQLite. The repository was
empty and the earlier codebase was not accessible, so the backend was built new on FastAPI with Celery + Redis as
requested in the master prompt. The handover's job/lease/circuit semantics were kept (in PostgreSQL tables);
Redis is the Celery broker, not the job store, so job state survives Redis loss.
