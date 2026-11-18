# Testing

## Results (executed 2026-11-18 on Windows 11)
| Suite | Command | Result |
|---|---|---|
| Backend unit + API (PostgreSQL 16.2) | `TEST_DATABASE_URL=... pytest` | **108 passed**, coverage 90 % |
| Backend lint | `ruff check app tests` | clean |
| Alembic | `upgrade head` → `check` → `downgrade base` → `upgrade head` (PostgreSQL + SQLite) | passed |
| Flutter static analysis | `flutter analyze` | no issues |
| Flutter unit + widget | `flutter test` | **31 passed** |
| Live APHC smoke (production code, ~13 requests) | `python -m scripts.live_smoke` | passed (see APHC_INTEGRATION.md) |
| Full-stack local E2E over HTTP with live APHC | `python -m scripts.e2e_local` | passed: login → lists → case → worker enrichment → PDFs → live board → logout |
| Flutter integration tests (`integration_test/`) | `flutter test integration_test -d <device>` | **NOT RUN** — no Android emulator/SDK or iOS simulator on this machine |
| Android APK/AAB build | `flutter build apk/appbundle` | **NOT RUN** — Android SDK not installed (licence acceptance required) |
| iOS build | `flutter build ios` | **NOT RUN** — requires macOS + Xcode |

## Backend
* `tests/unit`: case identity (handover examples, leading zeros, bracketed types), Hcdbs/Lexika parsers against
  synthetic fixtures that mirror captured page structure (no real party data committed), LexikaClient six-op
  contract with `respx` (exact form bodies, order, cookie continuity, cap, redirect, 5xx, mismatch, partial
  sections), Hcdbs session sequence, PDF allow-list, redaction, settings guard.
* `tests/api`: auth (OTP lockout, rate limit, rotation/reuse, logout, disabled user, mobile binding, profile
  editability, disabled provider), cause lists (source order, list-type separation, stale fallback, advocate list
  join), enrichment (non-blocking, dedupe, repeated runs, identity mismatch, backoff, circuit, leases), live board
  (stale never current), publication/PDFs, favourites isolation, notifications idempotency/preferences, search,
  admin RBAC, Celery task bodies.
* Upstream is disabled in tests (`UPSTREAM_ENABLED=false`); fakes run the real parsers.
* SQLite can run the unit tests, but API tests require PostgreSQL (the circuit breaker commits in its own
  transaction, which SQLite's single-writer lock cannot do concurrently).

Run locally:
```
cd backend
python -m venv .venv && .venv\Scripts\pip install -r requirements-dev.txt
set TEST_DATABASE_URL=postgresql+psycopg://user:pass@localhost:5432/advocatemate_test
.venv\Scripts\pytest
```

## Mobile
* `test/unit/core_test.dart`: identity validation, deep links, court-listing filter/sort (source order),
  ApiClient error mapping, single refresh + retry, failed refresh → session expiry, offline cache fallback,
  live board never current from cache, 4xx does not fall back.
* `test/widget/app_flows_test.dart`: login flow, dashboard, My Cause List, Daily/Weekly/Supplementary (list-type
  isolation), court-wise ordering + navigation, case details enrichment polling, live board stale banner, offline
  notice, favourites, notification deep link, search, bottom navigation + logout, expired session, generated
  PDF label, Telugu rendering.
* `test/support/fake_backend.dart`: in-memory implementation of the `/api/v1` contract at the Dio adapter level.

## Performance
Not yet measured. Suggested before launch: k6/Locust against staging for `/cause-list/court/{n}` (DB-cached path)
and `/live-courts`; confirm upstream request rate stays within the limit agreed with APHC.
