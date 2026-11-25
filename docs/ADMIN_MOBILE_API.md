# Admin mobile API (`/admin-mobile/v1`)

JSON API for **AdvocateMate Admin**, the separate Android/iOS admin app (Flutter, own repository and store
listings). Part of this backend: the same database, `admin_accounts`, roles and permissions
(`app/admin/permissions.py`), Google verification, session limits and audit trail as the browser portal
(`/admin`) and the browser Admin App API (`/admin-api/v1`, which is unchanged). Never listed in the API docs.

**Status:** B1-M (authentication). Module endpoints follow phase by phase.

## Why it differs from the browser API
Browsers send cookies automatically, so the browser API needs CSRF tokens, an Origin check and a reverse-proxy
secret. A phone app sends its token itself in `Authorization: Bearer`, which no other app or website can make it
do, so none of those apply. A secret built into a phone app could be extracted, so there is no proxy key here:
protection comes from Google sign-in, the admin list, one-time nonces, short-lived tokens, rate limits and the
audit trail (optional later: Firebase App Check with Play Integrity / App Attest).

## Sign-in
```
App                                        Backend                                    Google
1 POST auth/challenge  ──────────────────► one-time nonce (hash stored, 5 min)
2 Google sign-in with that nonce  ───────────────────────────────────────────────────► account picker
  ◄───────────────────────────────────────────────────────────────────────────────── ID token (nonce inside)
3 POST auth/google {challenge_id, id_token, device}
                                           challenge used up (works once, even if sign-in fails)
                                           Google checks: signature, issuer, expiry, verified email,
                                           audience = ADMIN_MOBILE_GOOGLE_CLIENT_IDS (not the advocate app's)
                                           token nonce == challenge nonce
                                           active admin_accounts row, same Google account as before
  ◄─────────────────────────────────────── access token (15 min) + refresh token (single use)
4 Authorization: Bearer <access token> on every request
5 401 token_expired → POST auth/refresh {refresh_token} → new pair (the old refresh token stops working)
```
* **Storage on the phone:** refresh token in the iOS Keychain / Android Keystore only; access token in memory.
  The server stores only SHA-256 hashes of tokens and nonces.
* **Refresh reuse:** presenting an already-used refresh token ends the whole session (`refresh_reused`,
  audited as `admin_refresh_reuse_detected`): one copy is in someone else's hands.
* **Session limits** are the portal's: 30 min without requests, 8 h at most (`ADMIN_SESSION_*`). An access
  token never outlives its session. Sign-out, ending a session from the sessions list, or deactivating the admin
  revokes it at once.
* **Re-authentication** (actions in `REAUTH_REQUIRED`): `403 reauth_required` → `POST auth/reauth/challenge`
  (bound to this session) → Google sign-in with that nonce → `POST auth/reauth` → retry the action.
* Browser and phone sessions are kept apart (`admin_sessions.client`): a phone token is never accepted as a
  browser cookie and a browser cookie never as a bearer token.
* `ADMIN_ALLOWED_IPS` (portal allow-list) does not apply here: admins use phones on mobile networks.

## Endpoints
| Method | Path | Auth | Notes |
|---|---|---|---|
| POST | `auth/challenge` | – | 30 per IP per 10 min |
| POST | `auth/google` | – | `{challenge_id, id_token, device: {installation_id, platform: android\|ios, device_name, app_version}}` → tokens; 10 per IP per 10 min |
| POST | `auth/refresh` | – | `{refresh_token}` → tokens; 60 per IP per minute |
| GET | `auth/session` | Bearer | account, role, permissions, session limits |
| POST | `auth/reauth/challenge` | Bearer | one-time nonce for this session |
| POST | `auth/reauth` | Bearer | `{challenge_id, id_token}` |
| POST | `auth/logout` | Bearer | 204 |
| GET | `auth/sessions` | Bearer | the admin's live browser and phone sessions |
| DELETE | `auth/sessions/{id}` | Bearer | end one of them |

Token response: `{access_token, token_type: "bearer", expires_in, refresh_token, session}`.

## Errors
`{"error": {"code", "message", "request_id"}}`

| Status | Codes | What the app does |
|---|---|---|
| 401 | `token_expired` | refresh once, retry |
| 401 | `not_authenticated`, `session_expired`, `invalid_refresh`, `refresh_reused` | clear tokens, sign in again |
| 401 | `sign_in_expired`, `google_token_invalid` | start a new sign-in (new challenge) |
| 403 | `not_authorised`, `different_account`, `forbidden`, `reauth_required` | explain / re-authenticate |
| 422 / 429 | `validation_error` / `rate_limited` | |

## Configuration
| Variable | Meaning |
|---|---|
| `ADMIN_MOBILE_API_ENABLED` | empty = on in development/test, off in staging/production |
| `ADMIN_MOBILE_GOOGLE_CLIENT_IDS` | the admin app's own Google OAuth client IDs (server/Web client used as `serverClientId`, and the iOS client). Required in staging/production; development falls back to `GOOGLE_CLIENT_IDS` |
| `ADMIN_ACCESS_TOKEN_MINUTES` | access-token lifetime (default 15) |
| `ADMIN_CHALLENGE_MINUTES` | how long a sign-in nonce is usable (default 5) |

Google Cloud (owner): create OAuth clients for the admin app — Android (package `in.advocatemate.admin` + the
SHA-1 of every signing key: debug, upload, Play app signing), iOS (bundle `in.advocatemate.admin`), and a Web
client used as the app's `serverClientId`.

## Data (migration 0005)
* `admin_sessions`: `client` (`browser` | `mobile`), `token_expires_at`, `platform`, `device_name`,
  `app_version`, `installation_id` (random per install, not a hardware identifier).
* `admin_refresh_tokens`: hashed single-use refresh tokens (deleted by the daily housekeeping job once their
  session has ended).
* `admin_auth_challenges`: hashed one-time nonces (purged a day after expiry).

## Code layout
```
backend/app/services/admin_mobile_auth.py  challenges, sign-in, refresh + reuse detection, bearer check, reauth
backend/app/services/admin_access.py       shared steps: verify_google_sign_in, authorise_identity, check_live
backend/app/admin_mobile/                  deps (bearer, require), auth endpoints, schemas, router
backend/tests/admin_mobile/                sign-in, replay, refresh, reuse, limits, revocation, isolation, roles
```
