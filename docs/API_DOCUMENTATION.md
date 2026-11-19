# API documentation

Interactive docs: `http://localhost:8000/docs` (Swagger) and `/redoc` in development/staging; machine-readable
spec committed at [`docs/api/openapi.json`](api/openapi.json). These are **AdvocateMate's own endpoints**, not APHC's.

Base: `/api/v1`. Auth: `Authorization: Bearer <access_token>` on everything except `/auth/google`,
`/auth/google/link`, `/auth/refresh`, `/health/*`. Every authenticated call also re-checks that the account is
Google-linked and the advocate is still active in the registry (403 `advocate_not_eligible` otherwise). Errors:
`{"error": {"code": "...", "message": "...", "request_id": "..."}}`. Dates: ISO `yyyy-mm-dd`.

## Authentication
| Method | Path | Notes |
|---|---|---|
| POST | `/auth/google` | `{id_token, device_label?}` → `{status: "signed_in", access_token, refresh_token, …}` if this Google account is already linked, else `{status: "advocate_code_required", link_token, link_expires_in, google_email}` |
| POST | `/auth/google/link` | `{link_token, advocate_code, device_label?}` → session, or 404 `invalid_advocate_code`, 403 `email_mismatch` / `advocate_not_eligible` / `registry_email_missing`, 409 `advocate_already_linked` / `google_account_linked_elsewhere` (see AUTHENTICATION.md) |
| POST | `/auth/register`, `/auth/send-otp`, `/auth/verify-otp` | retired: 410 `login_method_retired` |
| POST | `/auth/refresh` | `{refresh_token}` → rotated tokens |
| POST | `/auth/logout` | revokes current session |
| GET/PATCH | `/auth/me` | profile; PATCH accepts only `display_name`, `email`, `preferred_language` |

## Advocates & cause lists
| Method | Path | Notes |
|---|---|---|
| GET | `/advocates/{code}` | name + dates offered by Lexika |
| GET | `/advocates/{code}/profile` | directory record |
| GET | `/cause-list/advocate/{code}?date=&refresh=` | grouped by court; `association_note`, `date_offered_by_source`, `stale` |
| GET | `/cause-list/dates?list_type=D\|W\|S` | dates APHC offers |
| GET | `/cause-list?list_type=&date=` | overview (dates + courts) |
| GET | `/cause-list/courts?list_type=&date=` | courts with case counts when synced |
| GET | `/cause-list/court/{n}?list_type=&date=&refresh=` | items in source order, headings, bench |
| GET | `/cause-list/status` | court-wise publication status |
| GET | `/cause-list/weekly.pdf` | official PDF (proxied) |
| GET | `/cause-list/court/{n}/pdf?date=` | official court PDF if APHC published one |

## Cases
| Method | Path | Notes |
|---|---|---|
| GET | `/case-details?case_number=WP/32115/2023` | accepts slash, spaced or compact form; returns immediately; queues enrichment |
| GET | `/cases/{id}` | same payload by id |
| GET | `/cases/{id}/enrichment-status` | `state`: `not_requested`/`pending`/`running`/`completed`/`failed`; `freshness`: `fresh`/`stale`; `poll_after_seconds` |
| POST | `/cases/{id}/refresh` | force a new enrichment (rate-limited) |
| GET | `/cases/{id}/pdf?kind=summary` | AdvocateMate-generated summary (`X-Document-Official: false`); `kind=order` → 404 `official_order_unavailable` |

Case-details payload sections: `identity`, `information`, `parties`, `advocates`, `additional`, `enrichment`,
`provenance`, `unavailable_sections`, `unavailable_note`. Keys are omitted when the source did not supply them.

## Live courts, search
| Method | Path | Notes |
|---|---|---|
| GET | `/live-courts?court_no=` | snapshot polled by the backend; `stale`, `is_current`, `age_seconds`; 503 before first poll |
| GET | `/search/cases?q=&case_type=&case_number=&case_year=&party=&advocate=` | over synced data; exact case numbers recognised |
| GET/DELETE | `/search/history` | per user |
| GET | `/search/suggestions?prefix=` | case-number prefix suggestions |

## Favourites, devices, notifications
| Method | Path |
|---|---|
| GET/POST | `/favourites/advocates` · DELETE `/favourites/advocates/{id}` · POST `/favourites/advocates/{id}/refresh-cause-list` |
| GET/POST | `/favourites/cases` · DELETE `/favourites/cases/{id}` |
| POST | `/devices` `{token, platform, app_version?, locale?}` · DELETE `/devices/{id}` |
| GET | `/notifications?unread_only=` · POST `/notifications/read {ids[]|all}` |
| GET/PUT | `/notifications/preferences` |

## Admin (role `admin`)
`GET /admin/dashboard`, `/admin/sync-status`, `/admin/jobs?status=`, `POST /admin/jobs/{id}/retry`,
`GET /admin/source-health`, `POST /admin/source-health/{name}/reset`, `GET /admin/audit`.
(Manual advocate verification was removed: access is decided only by the automatic registry match.)

## Health
`GET /health/live`, `GET /health/ready` (checks DB).
