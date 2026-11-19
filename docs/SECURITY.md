# Security

## Review summary (2026-11-18)
| Area | Implementation | Status |
|---|---|---|
| Transport | HTTPS required (release Android: cleartext disabled; iOS ATS default, local networking only for dev); HSTS header in staging/prod | Done |
| AuthN | Google ID token verified on the server (google-auth) + automatic advocate-registry match; JWT access (15 min) + rotating refresh tokens with reuse detection; eligibility re-checked on every request | Done — needs the real registry (AUTHENTICATION.md) |
| AuthZ | Every route except auth/health requires a live session; admin routes require `role=admin`; favourites/devices/notifications scoped by user id (tested for cross-user access) | Done |
| Rate limiting | Global per IP/user (120/min), Google sign-in (per IP), advocate linking (per Google account and per IP), refresh, case refresh; Redis-backed, in-process fallback | Done |
| Input validation | Pydantic schemas (`extra=forbid`), regex on codes/court numbers/case identities, LIKE wildcards escaped | Done |
| Error handling | Uniform `{"error":{code,message,request_id}}`; no stack traces; upstream errors mapped to safe messages | Done |
| Secrets | Env/secret manager only; `.env`, keystores, Firebase files git-ignored; startup refuses dev secrets in staging/prod | Done |
| Logging | JSON logs, request IDs, redaction of tokens/OTP/cookies/authorization; httpx URL logging silenced | Done |
| Upstream | Server-side only; TLS verified; no redirects; throttled; circuit breakers; CAPTCHA-protected flows not used; cookies never exposed | Done |
| Files | PDF download allow-list (`/Hcdbs/upload/*.pdf`), PDF signature + size checks; generated PDFs stamped "NOT an official court document"; served with `X-Document-Official` | Done |
| Data minimisation | VC meeting IDs/pass-codes not stored; raw upstream HTML not stored; IPs stored only as keyed hashes; retention jobs | Done |
| Mobile storage | Tokens in Keystore/Keychain; cache in app-private storage; backups disabled | Done |
| CORS | Off unless `CORS_ORIGINS` set (mobile apps don't need it) | Done |
| Admin exposure | OpenAPI docs disabled in production; admin endpoints return aggregates only. **Additionally restrict `/api/v1/admin/*` at the reverse proxy (IP allow-list/VPN).** | Proxy rule pending |
| Dependency scanning | Not yet configured — add Dependabot + `pip-audit` / `flutter pub outdated` review | Pending |
| Penetration test | Not performed | Pending |

## Known limitations / risks
1. Verification is only as good as the imported advocate registry; until the official registry is loaded, no real advocate can sign in.
2. No formal permission yet from APHC for automated access (see APHC_INTEGRATION.md).
3. Certificate pinning is not implemented (would complicate certificate rotation; reconsider before launch).
4. Root/jailbreak detection not implemented.

## Reporting
Security issues should be reported privately to the project owner; do not open public issues.
