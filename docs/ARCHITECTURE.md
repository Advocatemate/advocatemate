# Architecture

```
 Android / iOS (Flutter)                      AdvocateMate backend                         AP High Court (public)
┌──────────────────────────┐   HTTPS/JSON   ┌───────────────────────────────┐   HTTPS     ┌─────────────────────────┐
│ UI (features/*)          │──────────────► │ FastAPI  /api/v1              │             │ Hcdbs pages (cause      │
│ Riverpod providers       │  JWT access +  │  ├ api/v1 (routers, RBAC)     │────────────►│  lists, online board,   │
│ Repositories (Dio)       │  refresh token │  ├ services (business logic)  │  throttled, │  display board, PDFs)   │
│ Secure storage (tokens)  │                │  ├ integrations/aphc, lexika  │  circuit-   │ Lexika chatbot.php      │
│ File cache (offline)     │ ◄── FCM push ──│  └ models (SQLAlchemy 2)      │  breaker    │  (case status, advocate │
└──────────────────────────┘                │ Celery workers + beat (Redis) │             │   cause list)           │
                                            │ PostgreSQL 16                 │             └─────────────────────────┘
                                            └───────────────────────────────┘
```

## Principles
* **All upstream access is server-side.** The app never calls APHC; cookies/sessions stay in the backend.
* **One poller per source.** Live board and publication status are polled by Celery beat; phones read snapshots.
* **Never fabricate.** Fields are only returned when a source supplied them; absent sections are labelled.
* **Provenance everywhere.** Responses carry `fetched_at`, `stale`, and source names; the app shows offline/stale
  banners and "last updated" times.

## Backend layout (`backend/app`)
| Package | Responsibility |
|---|---|
| `core/` | settings (env), JSON logging with redaction, errors → safe JSON, JWT/HMAC helpers, rate limiting |
| `db/` | declarative base (UUID PKs, timestamps), engine/session |
| `models/` | users & auth, cases, cause lists, five `lexika_*` tables, favourites/notifications/PDF/cache/audit |
| `integrations/http.py` | shared HTTPS client: no redirects, throttle, error classification |
| `integrations/aphc/` | Hcdbs client (session manager `HcdbsSession`) + parsers |
| `integrations/lexika/` | `LexikaClient` (six-op case status, advocate search), parsers, response normaliser |
| `utils/case_identity.py` | the only compact⇄slash identity converter |
| `services/` | cause lists, advocates, cases/details, enrichment (jobs/leases), circuit breaker, live board, PDFs, notifications/FCM, auth/OTP, search, audit |
| `api/v1/` | routers: auth, court data, personal (favourites/devices/notifications), admin |
| `workers/`, `tasks/` | Celery app (queues `enrichment`, `sync`, `default`) and scheduled tasks |

## Mobile layout (`mobile/lib`)
| Folder | Responsibility |
|---|---|
| `config/` | `--dart-define` environment (API URL, app env, Firebase flag) |
| `network/` | `ApiClient` (Dio, auth header, single-flight refresh, error mapping) |
| `storage/` | secure token store, offline file cache, UI preferences |
| `core/` | errors, `Loaded<T>` provenance wrapper, formatters, case identity validation, providers |
| `routing/` | GoRouter with session redirect, shell navigation, deep-link mapping |
| `theme/` | navy/white/light-grey/gold palette, light & dark themes |
| `shared/` | freezed models, repositories, reusable widgets (cards, skeletons, empty/error, freshness banner, date selector) |
| `features/*` | one folder per feature as specified (authentication … settings) |
| `l10n/` | English and Telugu ARB files (+ generated localisations) |

## Key flows
* **Login:** code → `/auth/register` (Lexika lookup, user confirms name) → `/auth/send-otp` → `/auth/verify-otp`
  → tokens in Keychain/Keystore → `/auth/me`. See AUTHENTICATION.md.
* **Court-wise list:** app → `/cause-list/court/{n}` → DB if fresh (30 min) else `HcdbsSession` (5 requests) →
  parse → replace items in one transaction → response with `fetched_at`; on upstream failure returns last copy
  with `stale=true`.
* **Case details:** returns basic info immediately, enqueues an enrichment job, app polls with backoff.
* **Live board:** beat polls `displaytext.jsp` every 60 s in court hours → `source_cache` → `/live-courts`
  (stale after 180 s, never labelled current).

## Environments
`development` (dev OTP echo allowed), `test`, `staging`, `production` (startup refuses dev secrets and dev OTP;
OpenAPI docs disabled in production). Configuration: `.env.example`.
