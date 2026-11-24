# Admin App API (`/admin-api/v1`)

JSON API used by **AdvocateMate Admin**, the separate admin web app (its own repository `advocatemate-admin`,
React + TypeScript, its own deployment at e.g. `admin.advocatemate.com`). It is part of this backend and uses
the same database, the same `admin_accounts` / `admin_sessions`, the same Google verifier, permission matrix
and audit trail as the server-rendered portal at `/admin` (see [ADMIN_PORTAL.md](ADMIN_PORTAL.md)).
It is never listed in the API documentation.

**Status:** B1 (authentication foundation) — sign-in, session, re-authentication, logout, own sessions.
Module endpoints (overview, users, registry, court data, jobs, notifications, devices, health, activity,
admin access, announcements, settings) follow in later phases.

## How the Admin App reaches it
```
Browser ── https://admin.<domain>/api/* ──► Admin App reverse proxy ──► backend /admin-api/v1/*
                                            (adds X-Admin-Proxy-Key,
                                             X-Forwarded-For)
```
* The app and its API share one origin, so the session cookie is first-party, `SameSite=Strict` works and
  **no CORS is involved** (`CORS_ORIGINS` stays empty for it).
* With `ADMIN_PROXY_SECRET` set, any request without the matching `X-Admin-Proxy-Key` header gets **404**,
  as does any request from outside `ADMIN_ALLOWED_IPS` (when set). The public API host should not route
  `/admin-api` at all.
* Local development: the Vite dev server (`http://localhost:5173`) proxies `/api` to
  `http://127.0.0.1:8000/admin-api/v1`. `ADMIN_API_ENABLED` defaults to on in development/test.

## Sign-in
1. `GET auth/nonce` → `{nonce, client_id, expires_in}` and an HttpOnly `am_admin_nonce` cookie (10 min).
2. The app initialises Google Identity Services with `client_id` and `nonce`; Google returns an ID token to
   the page's JavaScript callback.
3. `POST auth/google {"credential": "<ID token>"}` — the backend checks the `Origin`, the per-IP rate limit
   (10 per 10 min), then `admin_access.sign_in()`: Google signature/issuer/expiry/audience/verified email,
   **nonce in the token == nonce cookie**, active `admin_accounts` row, bound Google account. It opens an
   `admin_sessions` row and sets the session cookie; the nonce cookie is cleared.
4. `GET auth/session` → account, role, `permissions[]`, `csrf_token`, session expiry and `reauth_until`.

Cookies (HttpOnly, `SameSite=Strict`, `Path=/`, no `Domain`):

| Environment | Session cookie | Nonce cookie |
|---|---|---|
| staging / production (Secure) | `__Host-am_admin_app` | `__Host-am_admin_nonce` |
| development / test | `am_admin_app` | `am_admin_nonce` |

Session limits are the portal's: 30 min idle, 8 h absolute, revoked on sign-out or deactivation.

## Every state-changing request
`POST`/`PUT`/`PATCH`/`DELETE` must carry `Origin` = one of `ADMIN_APP_ORIGINS` and
`X-CSRF-Token: <csrf_token>` (kept in memory by the app, never in localStorage). 120 changes per admin per
minute. Permissions are checked on the server for each endpoint (`app/admin/permissions.py`); actions in
`REAUTH_REQUIRED` need a Google sign-in within `ADMIN_REAUTH_MINUTES`, otherwise `403 reauth_required` and
the app calls `POST auth/reauth` (new nonce first) and retries.

## Endpoints (B1)
| Method | Path | Notes |
|---|---|---|
| GET | `auth/nonce` | 30 per IP per 10 min |
| POST | `auth/google` | `{credential}` → session payload, sets session cookie |
| GET | `auth/session` | current session payload |
| POST | `auth/reauth` | `{credential}` (needs a fresh nonce) → session payload with new `reauth_until` |
| POST | `auth/logout` | 204, revokes the session, clears the cookie |
| GET | `auth/sessions` | the admin's own live sessions (`current` flag) |
| DELETE | `auth/sessions/{id}` | end one of the admin's own sessions |

## Errors
`{"error": {"code": "...", "message": "...", "request_id": "..."}}`

| Status | Codes |
|---|---|
| 401 | `not_authenticated`, `session_expired`, `sign_in_expired`, `google_token_invalid` |
| 403 | `not_authorised` (not an active admin), `different_account`, `forbidden`, `reauth_required`, `csrf_failed`, `origin_denied` |
| 404 | `not_found` (also: no proxy key / IP not allowed) |
| 422 | `validation_error` |
| 429 | `rate_limited` |

All responses: `Cache-Control: no-store`, `X-Robots-Tag: noindex`, `X-Frame-Options: DENY`,
`Content-Security-Policy: default-src 'none'; frame-ancestors 'none'`.

## Configuration
| Variable | Meaning |
|---|---|
| `ADMIN_API_ENABLED` | empty = on in development/test, off in staging/production |
| `ADMIN_APP_ORIGINS` | comma-separated Admin App origins (`https://` required in staging/production) |
| `ADMIN_PROXY_SECRET` | 32+ characters, shared with the Admin App's reverse proxy; required in staging/production |
| `ADMIN_GOOGLE_CLIENT_ID` | Google Web client for admin sign-in (defaults to the first `GOOGLE_CLIENT_IDS`) |
| `ADMIN_ALLOWED_IPS` | optional second-layer IP allow-list (shared with `/admin`) |
| `FORWARDED_ALLOW_IPS` | proxy address(es) uvicorn trusts for `X-Forwarded-For` (default `127.0.0.1`) |

Add the Admin App origins (`http://localhost:5173`, staging, production) to the Google Web client's
**Authorized JavaScript origins**.

## Code layout
```
backend/app/admin/guards.py        shared rules: IP allow-list, CSRF compare, action rate limit, permission/re-auth
backend/app/admin_api/deps.py      proxy gate, cookies, Origin check, session + CSRF dependency, require()
backend/app/admin_api/auth.py      auth endpoints
backend/app/admin_api/schemas.py   request/response models
backend/app/admin_api/router.py    mounting, 404 gate, response headers
backend/tests/admin_api/           sign-in, nonce, Origin/CSRF, sessions, re-auth, roles, gate, configuration
```
