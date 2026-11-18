# Lexika integration

## What Lexika is (resolved)
"Lexika" is the **AP High Court website's own chatbot** (branding image `images/Lexika.png` on
`https://aphc.gov.in/`). Its widget script `https://aphc.gov.in/chat_assets/chat.js` posts forms to
**one endpoint: `POST https://aphc.gov.in/chatbot.php`** and renders the returned HTML fragments.

Access mechanism: direct HTTPS form POSTs from the AdvocateMate backend (no proxy, no credentials, no API key).
State is kept server-side in a PHP session (`PHPSESSID` cookie), so each multi-step flow must reuse one cookie
jar. The handover's question "six POSTs or six URLs?" is answered: **six logical operations, one URL**, each
distinguished by form fields.

The previous AdvocateMate repository referenced in the supplied API document was
not accessible (404), so this contract was re-derived from the live site and `chat.js`, not from old code.

## Six-operation case-status contract — VERIFIED 2026-11-18

| # | Operation | Form body | Response (HTML fragment) | Parser |
|---|---|---|---|---|
| 1 | Transition | `case_status_main=Case Status` | `<li id="case_entry_menu">` with `<select id="case_type">` options `value="WP-63">WP` (81 types) | `parse_case_type_options` |
| 2 | Case type/number/year | `main_case_type=<option value, e.g. WP-63>`, `case_no=<n>`, `case_year=<yyyy>` | `<li id="case_status_menu"><p><span>WP</span> 11111/2026</p>` + section menu | `parse_case_selection` (identity validated here) |
| 3 | Primary details | `case_status_query=Case Primary Details` | Sections `PRIMARY DETAILS`, `CATEGORY` with `<span>Label</span><b>Value</b>` | `parse_primary_details` (+ `normaliser.py`) |
| 4 | Vakalath | `case_status_query=Case Vakalath Details` | Blocks: `P/R No.` → number + `P`/`R`, then `Advocate Name` → `NAME (code)` | `parse_vakalath` |
| 5 | Petitioners | `case_status_query=Case Petitioners Details` | `PETITIONER(S)` → numbered `<b>name</b><p>description</p>` | `parse_parties(…, "PETITIONER")` |
| 6 | Respondents | `case_status_query=Case Respondents Details` | `RESPONDENT(S)` → same structure | `parse_parties(…, "RESPONDENT")` |

Important details:
* Op 2 must send the **option value** (`WP-63`), not the label. Sending `WP` returned HTTP 500. The value is read
  from op 1's response every time — never hard-coded.
* Op 2 without a prior op 1 in the same session returned 500 → session continuity is required.
* An empty op-2 body means the case was not found.
* The section menu (op 2) also offers *IA Details, USR Details, Connected Matters, Prayer, Orders*. These are
  **not called**: the six-call cap from the handover is kept and their response formats are unverified.
* Primary-detail labels observed: Main Number, SR Number, Petitioner, Respondent, Petitioner Advocate,
  Respondent Advocate, Case Category, District, Filing/Registration/Listing/Disposal Date, Status,
  Disposal Type, Purpose, Hon'ble Judges, Category, Sub Category. `-` means absent. Unknown labels are kept in
  `extra_fields`, never dropped or guessed.

### Identity validation
Requested identity must equal (structurally: type, number, year) both the op-2 header (`WP 11111/2026`) and the
op-3 `Main Number`. Otherwise `identity_mismatch` → job fails, nothing is stored.

### Resilience
`follow_redirects=False`; any redirect = protocol error. No per-call retry (the session state would be
ambiguous). A failure aborts the run; the **job** retries later with a fresh session and exponential backoff
(60 s × 2^(attempt-1), max 3 attempts). Optional sections (4–6) that fail to parse are marked `parse_failed`
without corrupting the others and without wiping previously stored data for that section.

## Advocate operations — VERIFIED

| Step | Form body | Response |
|---|---|---|
| a | `query=Advocate Code Wise Search` | empty body (sets session state) |
| b | `chat_input={advocate_code}` | `<li>{code} - {NAME}</li>` + `Cause List Dated : dd-mm-yyyy` options; unknown code → "couldn not find any advocate linked to that code" |
| c | `query={dd-mm-yyyy}` | `<table>` Item No. / Case No. / Court No. (`CH - 3`) / List Type (`Daily`) |

Case No. can be an application row: `IA/1/2026-Condone Delay Petition,CMA/506/2012` → main case `CMA/506/2012`,
application `IA/1/2026`. Used for: registration lookup (advocate name), My Cause List, favourite advocates.
This response does not include parties; the API joins parties from the official court-wise list for the same
date/court/item **only when that list has been synced** — otherwise parties are shown as unavailable.

## Data flow
```
/case-details or /cases/{id}  ──► request_enrichment()  (returns immediately, job row)
Celery beat (15 s) ──► dispatch_enrichment ──► claim_due_jobs (FOR UPDATE SKIP LOCKED, lease 180 s)
   ──► run_enrichment_job ──► circuit check ──► LexikaClient.case_status() (≤ 6 POSTs)
   ──► identity validation ──► replace_case_status() (one transaction, row lock on case)
   ──► lexika_case_status_cache / lexika_case_parties / lexika_case_vakalath_mappings
   ──► job succeeded ──► notification to requester ──► mobile polls /enrichment-status (2,3,5,8,13,21,30 s)
```

## Tables
See DATABASE_SCHEMA.md. Duplicate prevention: partial unique index (one `pending|running` job per case);
`UNIQUE(case_id, side, party_no)` for parties; `UNIQUE(case_id, side, party_no, advocate_name)` for vakalath.
Raw upstream HTML is **not stored**.

## Compact vs slash identity
`app/utils/case_identity.py` is the only place that converts. Compact (`WP321152023`) is used for
`lexika_case_status_cache.compact_key` and `cases.compact_key`; slash (`WP/32115/2023`) is the canonical key and
the form used by APHC pages. Leading zeros are rejected as ambiguous (no source confirms they are equivalent).

## Open items
* Permission for automated use of the chatbot at production volume (see APHC_INTEGRATION.md → Approvals).
* Verify and add IA / USR / connected matters / orders operations (would exceed the six-call cap; needs an
  approved change).
