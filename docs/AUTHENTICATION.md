# Authentication

Sign-in is **Google Sign-In + automatic advocate verification against the advocate registry**.
There is no admin approval, no manual verification and no "pending" state: access is granted only when a
server-verified Google identity matches the authoritative registry. The earlier advocate-code + mobile-OTP
login is retired (its endpoints return `410 login_method_retired`).

## Flow
```
App: Google account picker ──ID token──► POST /auth/google
                                         backend verifies the token with Google (google-auth)
          ┌── Google account already linked & advocate still eligible ──► session (Scenario B) ──► dashboard
          └── otherwise ──► { status: advocate_code_required, link_token (10 min, single use), google_email }
App: Advocate Code screen ──► POST /auth/google/link { link_token, advocate_code }
                              checks, in one locked transaction:
                              C code not in registry ............ 404 invalid_advocate_code
                              F Google account linked elsewhere .. 409 google_account_linked_elsewhere
                              G registry status not active ....... 403 advocate_not_eligible
                                registry has no email ............ 403 registry_email_missing
                              D Google email ≠ registry email .... 403 email_mismatch
                              E code linked to another Google acct 409 advocate_already_linked
                              A all pass ─► link (one-to-one) + session ─► dashboard
Later launches: saved session ─► GET /auth/me (re-checks link + eligibility) ─► dashboard
```
Message for C (shown verbatim): *"Invalid Advocate Code. Please check your code and try again."*

## Security properties
* **Google ID token is verified only on the server** (`app/integrations/google_identity.py`): signature
  against Google's certificates, issuer `accounts.google.com`, expiry, audience = `GOOGLE_CLIENT_IDS`, and
  `email_verified = true`. The app never sends an email or Google ID that the server trusts; extra request
  fields are rejected (422).
* Identity is Google's stable `sub`; the email is compared (lower-cased, exact) only at link time.
* **An advocate code alone never grants access**: linking needs a server-signed link token that only exists
  after Google verification. Link tokens are HS256 JWTs (`typ=google_link`), expire after
  `GOOGLE_LINK_TOKEN_MINUTES` (10), and are single-use after a successful link. A wrong code can be retried
  with the same token (rate-limited: 10 attempts/hour per Google account, 30/hour per IP).
* **One-to-one links** are enforced by unique constraints on `advocate_profiles.google_sub`,
  `advocate_profiles.advocate_code` and `advocate_profiles.user_id`, plus a row lock on the registry entry
  during linking; a lost race maps to `google_account_linked_elsewhere`.
* **Eligibility is re-checked on every authenticated request and every token refresh.** If the registry marks
  an advocate inactive/suspended, the session is revoked and the app returns to sign-in with
  "Access ended: this advocate code is no longer active." The link itself is kept.
* Nothing is stored for failed attempts except audit records (`advocate_link_attempt` with the result code,
  never the email or tokens).
* Sessions are unchanged: 15-minute JWT access token bound to a live session row, 30-day single-use refresh
  token stored as an HMAC, reuse detection revokes the session. Tokens live in Android Keystore / iOS
  Keychain via `flutter_secure_storage`.

## Logout and switching Google accounts
* **Log out** revokes this device's session, clears tokens and cached data, and signs out of Google on the device.
* **Switch Google account** (More, Profile, or "Use a different Google account" on the code screen) does the
  same and shows the account picker again. **The permanent Google ↔ advocate link in the database is not
  deleted**; signing in again with the linked account goes straight to the dashboard (Scenario B).

## Existing and new users
* **Profiles from the retired OTP login** were marked `legacy_unverified` by migration `0002`. They cannot
  sign in (`401 google_link_required`) until the advocate signs in with Google and passes the registry check;
  then the **same profile is reused** (favourites, notification history kept) and every older session for it
  is revoked.
* **New / unregistered users** can complete Google sign-in, but are refused with C, D, F or G as applicable.
  Nothing is saved and there is no waiting list. With no admin path, fixes are: sign in with the Google
  account that uses the registered email, or have the registry corrected at its source.

## The advocate registry (required)
`advocate_registry` holds the authoritative data: advocate code, full name, registered email, status. It is
separate from the public `advocates` directory (names scraped from APHC), which is never used for
verification and never modified by imports.

```
python -m scripts.import_registry registry.csv --source "<official source>" --dry-run
python -m scripts.import_registry registry.csv --source "<official source>"
```
CSV header: `advocate_code,full_name,email,status[,source_reference]`; status ∈ active, inactive, suspended,
struck_off, deceased, retired. Codes missing from a full import become `inactive` (use `--keep-missing` to
avoid). Imports with no valid rows are refused. A fictional sample is in
`backend/tests/fixtures/registry/sample_registry.csv`.

**Status:** only sample data has been imported in tests. Real verification requires the official registry
(with advocates' registered emails) and permission to use it.

## Configuration
| Setting | Where | Notes |
|---|---|---|
| `GOOGLE_CLIENT_IDS` | backend env | Web OAuth client ID (the `serverClientId` the apps use); comma-separate several. Required in staging/production. |
| `GOOGLE_LINK_TOKEN_MINUTES` | backend env | default 10 |
| `GOOGLE_SERVER_CLIENT_ID` | app `--dart-define` | same Web client ID |
| `GOOGLE_IOS_CLIENT_ID` | app `--dart-define` | iOS OAuth client ID |

Google Cloud setup (project owner): OAuth consent screen; OAuth clients for **Web**, **Android** (package
`in.advocatemate.app` + SHA-1 of the debug keystore and of the release / Play app-signing key) and **iOS**
(bundle `in.advocatemate.app`; add its reversed client ID as a URL scheme in `ios/Runner/Info.plist`).
Until configured, the app shows "Google sign-in is not set up in this version of the app".
