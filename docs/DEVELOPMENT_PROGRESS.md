# Development progress — 2026-11-18

Branch: `feature/initial-platform` (local). **Not pushed:** the GitHub account on this machine has READ-only
access to `Advocatemate/advocatemate`, and the remote repository is empty.

## Phase status
| Phase | Status | Evidence |
|---|---|---|
| 1 Foundation (monorepo, Flutter, FastAPI, PostgreSQL, Alembic, Redis/Celery, Docker, docs) | ✅ Done | compose file, Dockerfile, migration 0001, docs/ |
| 2 Backend foundation (models, auth, schemas, errors, logging, security) | ✅ Done | 108 backend tests |
| 3 APHC source integration | ✅ Done for verified sources; ⛔ case-details JSON blocked | live smoke + E2E (APHC_INTEGRATION.md) |
| 4 Mobile foundation (architecture, theme, navigation, API client, storage, state, widgets) | ✅ Done | flutter analyze clean |
| 5 Core mobile (splash, login, profile, dashboard, My Cause List) | ✅ Done | widget tests |
| 6 Cause lists (daily, weekly, supplementary, court-wise, search/filters) | ✅ Done | widget tests |
| 7 Case management (details, enrichment, parties, vakalath, PDF viewing) | ✅ Done; orders/history ⛔ (no verified source) | backend + widget tests |
| 8 Advanced (live court, favourites, notifications, offline, i18n) | ✅ Done; push ⚠ needs Firebase project | tests |
| 9 Administration (dashboard, sync, jobs, source health, audit) | ✅ API done; no admin web UI | admin API tests |
| 10 Testing & security | ✅ automated suites + security review; ⚠ integration tests on device, perf tests, pen test pending | TESTING.md, SECURITY.md |
| 11 Deployment | ⚠ Docker/CI/docs ready; no staging/production environment; no store builds | DEPLOYMENT.md |

## What works (verified)
* Live APHC data through the API: daily/weekly/supplementary dates, courts, court-wise lists, publication status,
  live board, weekly + court PDFs, Lexika advocate lookup, advocate cause list, six-operation case status.
* Async enrichment with leases, retries/backoff, circuit breaker, duplicate prevention, identity validation.
* OTP auth (dev echo), refresh rotation with reuse detection, RBAC, rate limits, audit, redaction.
* Flutter app: all listed screens, offline cache + notices, Telugu, dark mode; 31 tests.

## Not available / not done
| Item | Reason | Needed |
|---|---|---|
| Orders, case history, IA/USR/MP, connected matters, lower court | `caseDetails1.jsp` blocks server requests; chatbot ops beyond the 6-call cap unverified | APHC permission/whitelist or official API; approval to extend the call cap |
| Official per-case order PDFs | same as above | same |
| Real SMS OTP | no provider/credentials | SMS gateway + DLT templates; adapter |
| Verified advocate identity | no authorised registry access | Bar Council / APHC verification service or manual admin process |
| Push notifications on devices | no Firebase project/config | Firebase project, `google-services.json`, `GoogleService-Info.plist`, APNs key, backend service account |
| Case-calling alerts | backend data model supports board + listing; alert rule not enabled to avoid speculative "being called" claims | product decision on wording/thresholds |
| Android APK/AAB | Android SDK not installed (licence acceptance) | install SDK or rely on CI job |
| iOS build/TestFlight | requires macOS/Xcode + Apple Developer account | Mac + account |
| Admin web console | API only | decide scope |
| Production-scale access | no written permission from APHC | approval + agreed rate limits |

## Credentials / approvals required
APHC permission; SMS provider; Firebase (Android + iOS) and FCM service account; Apple Developer + APNs key;
Google Play Console; Android upload keystore; Sentry DSN (optional); hosting account + domain + TLS; GitHub
write access to `Advocatemate/advocatemate`.

## Next steps
1. Push branch once write access is granted; let CI build the Android APK and iOS (no-codesign).
2. Run integration tests on an emulator/simulator.
3. Provision staging; configure Firebase and an SMS provider.
4. Pursue APHC permission and access to case-details/orders.
