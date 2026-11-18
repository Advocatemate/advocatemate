# Database schema (PostgreSQL 16, Alembic revision `0001`)

UUID primary keys unless noted; all timestamps `timestamptz` (UTC). JSON columns are `JSONB` on PostgreSQL.
Migrations: `backend/migrations/versions/`. CI runs `alembic upgrade head && alembic check && alembic downgrade base`.

## Identity & auth
| Table | Purpose / key constraints |
|---|---|
| `users` | role (`advocate`/`admin`), status, preferred_language, last_login_at, soft-delete `deleted_at` |
| `advocates` | PK `advocate_code`; name + source + fetched_at (public directory from Lexika) |
| `advocate_profiles` | 1:1 user; `advocate_code` UNIQUE FK; `source_name` (read-only), editable `display_name`/`email`; `identity_verification` (`self_declared`/`verified`/`rejected`) + verifier |
| `verified_mobiles` | UNIQUE(user_id, phone_e164) |
| `otp_records` | HMAC of OTP only (never the code), attempts, expires_at, consumed_at; index (phone, created_at) |
| `auth_sessions` | per device; revoked_at + reason |
| `refresh_tokens` | `token_hash` UNIQUE (HMAC), used_at (rotation), revoked_at |

## Court data
| Table | Purpose / key constraints |
|---|---|
| `cases` | canonical identity: UNIQUE(case_type, case_number, case_year); `canonical_key` (slash) UNIQUE; `compact_key` UNIQUE |
| `courts` | PK court_no; bench code/coram |
| `cause_lists` | UNIQUE(list_type, list_date, court_no); headings JSON, item_count, content_hash, status (`synced`/`empty`/`failed`), fetched_at |
| `cause_list_items` | FK cause_list (CASCADE); UNIQUE(cause_list_id, sequence) — preserves source order; case_id FK; applications, advocates JSON; trigram indexes on petitioner/respondent when `pg_trgm` is available |
| `publication_statuses` | UNIQUE(list_date, court_no); status, uploaded time, PDF path (no VC credentials) |
| `advocate_case_links` | association *asserted by Lexika* for a date; UNIQUE(advocate_code, case_id, list_date, court_no, item_no, application_key) |

## Lexika projections (handover entities)
| Table | Purpose / key constraints |
|---|---|
| `lexika_case_status_cache` | 1:1 case (UNIQUE case_id, UNIQUE compact_key); normalised primary fields, `extra_fields`, `sections` (present/empty/parse_failed/not_offered), source, client/parser version, fetched_at |
| `lexika_case_parties` | UNIQUE(case_id, side, party_no) |
| `lexika_case_vakalath_mappings` | UNIQUE(case_id, side, party_no, advocate_name); advocate_code indexed |
| `lexika_case_status_enrichment_jobs` | status (`pending`/`running`/`succeeded`/`failed`/`cancelled`), attempts/max, next_attempt_at, lease_owner/lease_expires_at, last_error_code/message, requested_by; **partial UNIQUE(case_id) WHERE status IN ('pending','running')**; index (status, next_attempt_at) |
| `lexika_safety_circuits` | PK source name; state, consecutive failures, open_until, last success/failure, latency, totals (also serves as source-health record) |

## Engagement & operations
| Table | Purpose / key constraints |
|---|---|
| `favourite_advocates` | UNIQUE(user_id, advocate_code) |
| `favourite_cases` | UNIQUE(user_id, case_id) |
| `device_tokens` | token UNIQUE; platform; revoked_at |
| `notification_preferences` | PK user_id; six category toggles |
| `notifications` | UNIQUE(user_id, dedupe_key) — idempotent events; read_at; delivery_status (`pending`/`sent`/`failed`/`skipped`) |
| `pdf_documents` | UNIQUE(kind, cache_key); `is_official`; sha256, size, storage path, source URL, expires_at |
| `source_cache` | PK key; **parsed** payloads only (never raw HTML); expires_at |
| `audit_records` | action, actor, target, hashed IP, redacted details |
| `search_history` | per user |

## Retention (housekeeping task, daily 03:05 IST)
OTP records > 1 day; refresh tokens expired > 7 days; source cache expired > 2 days; advocate-case links > 180
days; generated summary PDFs after expiry. Raw upstream responses are never persisted.

## Access control
The application connects with a single least-privilege role that owns the schema (create it without SUPERUSER).
Admin API endpoints expose aggregates only. Backups: see DEPLOYMENT.md.
