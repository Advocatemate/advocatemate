# Admin portal

Internal web portal for AdvocateMate administrators, served by the FastAPI backend at **`/admin`**
(server-rendered Jinja2 pages, HTMX for partial updates, Chart.js for charts; no separate front-end build).
It is never listed in the public API documentation.

> The separate **AdvocateMate Admin** web app (own repository and deployment) uses the same accounts,
> sessions, permissions and audit trail through the JSON API at `/admin-api/v1` — see
> [ADMIN_APP_API.md](ADMIN_APP_API.md). Both share the rules in `app/admin/guards.py`.
>
> The **AdvocateMate Admin phone app** (Android/iOS, Flutter, separate repository) uses the same accounts
> through `/admin-mobile/v1` with bearer tokens — see [ADMIN_MOBILE_API.md](ADMIN_MOBILE_API.md).

**Status:** Phase 1 (foundation) complete — sign-in, sessions, roles, Admin Access, layout and theme, audit
trail. Monitoring and support modules arrive in phases 2–7 (see "Build phases").

## Principles
* Admins are **separate from advocates**. An admin is an explicitly authorised Google account in
  `admin_accounts`; it does not need an advocate code and never goes through the advocate registry.
* **No manual advocate verification.** Advocate access is decided only by Google sign-in plus the automatic
  registry match. The registry changes only through the official import (phase 4).
* Every admin action goes through the backend service layer and is written to `audit_records`
  (`actor_admin_id`). Audit records are **append-only** (a PostgreSQL rule refuses updates and deletes).
* Real data only. Pages for modules that are not built yet say so; they never show sample numbers.

## Signing in
1. The admin clicks **Sign in with Google** (Google Identity Services, popup).
2. Google posts the ID token to `POST /admin/auth/google` together with its `g_csrf_token` double-submit value.
3. The backend verifies the token with the same verifier as the app (`app/integrations/google_identity.py`:
   signature, issuer, expiry, audience = the Web client ID, verified email).
4. The email must belong to an **active** `admin_accounts` row. The Google account ID is bound at first sign-in;
   a different Google identity with the same email is refused afterwards.
5. A server-side session is created (`admin_sessions`); the browser only receives a random token in the
   `am_admin` cookie (HttpOnly, SameSite=Strict, Path=/admin, Secure in staging/production). Only a hash of the
   token is stored.

Sessions end after **30 minutes without activity** or **8 hours** at most (`ADMIN_SESSION_IDLE_MINUTES`,
`ADMIN_SESSION_MAX_HOURS`). Sign-out revokes the session. Deactivating an admin revokes all their sessions.

**Re-authentication:** registry import, announcements and admin management need a Google sign-in within the
last 10 minutes (`ADMIN_REAUTH_MINUTES`); otherwise the admin is sent to `/admin/reauth` and returned afterwards.

### First owner (there is no sign-up)
```
cd backend
python -m scripts.admin_accounts add owner@example.com --role owner
python -m scripts.admin_accounts list
```
Other commands: `set-role <email> <owner|admin|support>`, `deactivate <email>`, `activate <email>`. There is
always at least one active owner (the last owner cannot be demoted or deactivated).

### Google Cloud setting
On the **Web** OAuth client used for `GOOGLE_CLIENT_IDS` (or `ADMIN_GOOGLE_CLIENT_ID`), add the portal's
address under **Authorized JavaScript origins** — `http://localhost:8000` for local development and the real
admin address (for example `https://admin.<domain>`) for staging and production.

## Roles and permissions
Enforced on the server for every route (`app/admin/permissions.py`, tested role by role). Hiding a button is not
the protection.

| Permission | Owner | Admin | Support |
|---|---|---|---|
| View monitoring pages | ✓ | ✓ | ✓ |
| Re-sync court, re-read court PDF, retry failed job | ✓ | ✓ | ✓ |
| Reset source circuit, revoke device, test push | ✓ | ✓ | – |
| Disable / enable users, sign out all sessions, reveal masked data | ✓ | ✓ | – |
| Import the advocate registry (re-auth) | ✓ | ✓ | – |
| Send announcements (re-auth, if enabled) | ✓ | ✓ | – |
| Manage admins and roles (re-auth) | ✓ | – | – |

## Security
* **Network:** restrict `/admin` at the reverse proxy to a VPN or office IP allow-list. As a second layer, set
  `ADMIN_ALLOWED_IPS` (comma-separated IPs/CIDRs); requests from elsewhere get 404.
* **CSRF:** every state-changing request carries the session's CSRF token (HTMX header `X-CSRF-Token`, or a
  hidden form field). Google's sign-in posts are protected by Google's double-submit cookie instead.
* **Headers:** strict Content-Security-Policy (own scripts only; Google's sign-in script and inline styles are
  allowed on the two sign-in pages only), `X-Frame-Options: DENY`, `X-Robots-Tag: noindex`,
  `Cache-Control: no-store`, `Permissions-Policy`.
* **Rate limits:** 10 sign-in attempts per IP per 10 minutes; 120 state-changing requests per admin per minute.
* **Data minimisation:** emails and device tokens masked by default; reveals require a reason and are audited
  (phase 3). IP addresses are stored only as keyed hashes. No configuration or secrets are shown in the portal.

Audited actions so far: `admin_login`, `admin_login_denied`, `admin_logout`, `admin_reauth`,
`admin_reauth_denied`, `admin_account_created`, `admin_role_changed`, `admin_account_activated`,
`admin_account_deactivated`.

## Code layout
```
backend/app/admin/       router.py (routes, headers, error handling), dependencies.py (session, CSRF, roles,
                         IP allow-list), permissions.py, templating.py, templates/, static/ (css, js, fonts,
                         vendor/htmx.min.js 2.0.4 and chart.umd.min.js 4.4.7 - see vendor/VENDOR.md)
backend/app/services/admin_access.py   accounts, Google sign-in, sessions
backend/app/models/admin.py            admin_accounts, admin_sessions, user_daily_activity, sync_events
backend/app/db/audit_guard.py          append-only rule for audit_records (installed by migration 0004)
backend/scripts/admin_accounts.py      command-line account management
backend/tests/admin/                   sign-in, sessions, CSRF, permission matrix, Admin Access, audit rule
```

## Build phases
| Phase | Scope | Status |
|---|---|---|
| 1 Foundation | Migration 0004, admin accounts and sessions, Google sign-in, CSRF, roles, layout/theme, Admin Access, audit | ✅ Done |
| 2 Monitoring | Overview (charts), System health, Court data, Jobs, Notifications, Devices, Activity log | Pending |
| 3 Support actions | Users (disable/enable, sign out all, reveal), retry jobs, reset circuits, re-sync, re-read PDFs | Pending |
| 4 Registry | CSV upload, validation, preview of new/updated/deactivated, confirm, import history | Pending |
| 5 Data quality | PDF comparison reports, passed-over monitor, live board | Pending |
| 6 Announcements | Optional, if approved | Not approved yet |
| 7 Hardening | Security review, full permission tests, accessibility, proxy rule, docs | Pending |
