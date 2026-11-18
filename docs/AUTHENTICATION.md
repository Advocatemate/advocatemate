# Authentication

## Flow
1. `POST /auth/register {advocate_code}` — validates the code with the Lexika chatbot and returns the advocate
   name as published by APHC, whether the code already has an account, and a masked hint of its mobile.
2. The app shows the name and asks **"Is this you?"**; `send-otp` requires `identity_confirmed=true`.
3. `POST /auth/send-otp {advocate_code, mobile, identity_confirmed}` — Indian 10-digit mobile, normalised to
   E.164. If the code is already bound to an account, only that account's verified mobile is accepted.
4. `POST /auth/verify-otp {advocate_code, mobile, otp}` — on first success creates user + profile + verified
   mobile; returns `access_token` (JWT HS256, 15 min, claims `sub`, `sid`, `role`, `iss`, `exp`, `jti`) and an
   opaque `refresh_token` (30 days).
5. `POST /auth/refresh` — **rotation**: each refresh token is single-use; presenting a used token revokes the
   whole session (`refresh_reused`). `POST /auth/logout` revokes the session and its tokens.

## What is and is not verified — read this
* **Advocate codes are public** and are never treated as a secret.
* **No authorised source of advocates' registered mobile numbers was found** (APHC pages and the chatbot do
  not expose one). Therefore the OTP proves **possession of the mobile number only**. It does *not* prove that
  the person is the advocate who holds the code.
* Accounts are created with `identity_verification = self_declared`. The profile screen shows this status.
  An administrator can set `verified`/`rejected` (`POST /admin/advocates/verify`) after an out-of-band check
  (e.g. Bar Council ID / APHC registry). A proper integration needs an authorised verification service.
* First-come binding: the first verified mobile for a code owns it; later attempts with another number get
  `mobile_mismatch`. A dispute/transfer process must be defined by the product owner.
* All data the app exposes is public court information, which limits the impact of a false claim, but the
  limitation must be stated to users and is shown in the UI.

## OTP delivery
`OTP_PROVIDER`:
* `dev_echo` — development/test only; the OTP is returned in the API response (`dev_otp`) and shown in the app.
  The settings validator **refuses to start** staging/production with this value.
* `disabled` — `send-otp` returns `503 otp_unavailable`; nothing pretends an SMS was sent.

**Required before launch:** an SMS gateway account (DLT-registered sender ID and OTP template as required by
TRAI in India, e.g. MSG91/Gupshup/Twilio Verify), its API credentials in the secret manager, and an adapter in
`app/services/auth.py` (interface point: `send_otp`). Not implemented because no provider/credentials exist yet.

## Controls
* OTP: 6 digits, 5 min expiry, stored as HMAC-SHA256 with per-OTP salt; max 5 verify attempts then locked;
  max 5 sends/hour per phone and 20/hour per IP; new OTP invalidates older ones; constant-time compare.
* Refresh tokens stored as HMAC; access tokens checked against a live session row on every request.
* Disabled/deleted users are rejected even with a valid token.
* Mobile: tokens in Android Keystore / iOS Keychain (`first_unlock_this_device`), excluded from backups.
* Audit records: `otp_sent`, `otp_failed`, `account_registered`, `login`, `logout`, `refresh_reuse_detected`,
  `profile_updated`, admin actions — no OTPs, tokens or phone numbers in details.
