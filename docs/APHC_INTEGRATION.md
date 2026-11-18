# APHC source integration (Hcdbs website)

Status legend: **VERIFIED** = request/response observed from the AdvocateMate backend on 2026-11-18 and
covered by a parser + tests. **BLOCKED** = the source refused server-side requests. **NOT USED** = exists
but deliberately not integrated.

All requests originate from the backend only (`app/integrations/aphc`). Mobile apps never contact APHC.

> These are APHC **website** pages and form actions used by the official site's own JavaScript, not a
> published API. They can change without notice. Formal permission from the High Court for
> production-scale automated access has **not** been obtained yet — see "Approvals" below.

## Transport behaviour (all Hcdbs calls)

| Aspect | Behaviour |
|---|---|
| Base URL | `https://aphc.gov.in` (TLS verified, system CAs) |
| Session | Server sets `HCDBS_ID` cookie (`Path=/Hcdbs`, HttpOnly, Secure). The court-wise flow keeps one cookie jar per `HcdbsSession`. Cookies never leave the backend and are never logged. |
| Redirects | None observed. The client sets `follow_redirects=False` and treats any 3xx as `upstream_protocol_error`. |
| Throttle | ≥ `APHC_MIN_INTERVAL_SECONDS` (default 1.5 s) between requests to the same host, per process. Background sync is single-concurrency (`sync` queue, `-c 1`). |
| Block page | Some URLs answer `404` with *"The specified URL cannot be found."*. Classified as `upstream_blocked`, not retried. |
| robots.txt | `https://aphc.gov.in/robots.txt` returned 404 (no robots policy published). |
| User-Agent | `AdvocateMate/<ver> (+server-side; contact via app support)` — configurable. |

## Endpoint catalogue

### 1. Cause-list dates — VERIFIED
`GET /Hcdbs/getdates.jsp?listtype={D|W|S}`
Response: `text/html`, body `dd-mm-yyyy@dd-mm-yyyy@…` (newest first). Single-character error codes from the
page JS: `0` no lists, `1` invalid request, `2` invalid list type.
Parser: `parse_list_dates`. Weekly (`W`) and supplementary (`S`) verified as well as daily.

### 2. Court-wise cause list — VERIFIED
Request sequence (one cookie jar):

| # | Method & path | Form / query |
|---|---|---|
| 1 | `GET /Hcdbs/search.jsp` | – (establishes `HCDBS_ID`) |
| 2 | `POST /Hcdbs/searchdates.action` | `causelisttype=D\|W\|S` |
| 3 | `POST /Hcdbs/searchtypeinput.action` | `listdate=dd-mm-yyyy`, `caset=courtsearch`, `causelisttype` |
| 4 | `GET /Hcdbs/courtlist.jsp` | `listtype1`, `listdate1` → **base64-encoded JSON** `[{"court_code","court_name"}]` (error codes `0`–`6`) |
| 5 | `POST /Hcdbs/searchtype.action` | `court={n}`, `caset=courtsearch`, `listdate`, `causelisttype` → HTML |

Response of step 5: `<table id="clisttable">` containing one or more list sections. Each section starts with
single-cell header rows (`COURT NO. n`, bench, "To be Heard on…", `(LIST TITLE)`), then a 6-column header
(`S.No | Case | Party | Petitioner Advocate | Respondent Advocate | District[/Remarks]`), then rows.
Data cells carry `data-label` attributes (`S.No`, `Case Det`, `Party`, `Pet Adv`, `Res Adv`, `District`).
Single-cell rows inside a section are stage headings (e.g. `ADMISSION (REVENUE)`) or grouping notes
(`59.1 ,59.2 along with 59`). Item numbers can be decimal (`59.1`). IA lines follow the case number inside the
`Case Det` cell. Parser: `parse_court_cause_list` — preserves original order (`sequence`).

Live check (2026-11-18): daily list, 26 courts, court 1 = 61 items, court 3 = 114 items.

**Advocate-code-wise search on this site (`caset=advcdsearch`) requires a CAPTCHA → NOT USED.** AdvocateMate
does not bypass CAPTCHAs; the advocate view uses the Lexika chatbot instead (see LEXIKA_INTEGRATION.md).

### 3. Publication status (online board) — VERIFIED
`GET /Hcdbs/online_board.jsp` → HTML with `CAUSE LIST DATE : dd-mm-yyyy` and `<table id="display">`
(Court Hall No., Hon'ble Bench, Coram, Teams Meeting ID, Pass-Code, VC LINK, Status, Uploaded Date, PDF).
Parser: `parse_online_board`. **Meeting IDs, pass-codes and VC links are deliberately not parsed or stored.**
Status values observed: `UPLOADED`, `ON LEAVE`. The PDF cell links to `/Hcdbs/upload/court{n}_{yyyymmdd}.pdf`;
AdvocateMate only uses links discovered on this page (it does not construct PDF URLs).

### 4. Live display board — VERIFIED
`GET /Hcdbs/displaytext.jsp` → `text/html; charset=ISO-8859-1`, records separated by `$`, fields by `@`.
Field meaning taken from the official `displayboard.jsp` renderer:

| Index | Meaning |
|---|---|
| 0 | Court number |
| 2 | Item: `-` = not in session, `D-0` = session started, otherwise current item (e.g. `D-52`, `P23`) |
| 4 | Kept-back cases (column "KEPT BACK CASES") |
| 5 | Pending serials (tooltip), comma-separated |
| 6 | Coram |
| 1, 3 | Not rendered by the official page; ignored |

Parser: `parse_display_text`. Polled by Celery beat every `LIVE_BOARD_POLL_SECONDS` (60 s) during court hours
(Mon–Sat 09:30–18:00 IST). Snapshots older than `LIVE_BOARD_STALE_SECONDS` (180 s) are returned with
`stale=true, is_current=false`. Fallback candidates listed in the API document (`displayboard.jsp`,
`/displayboard`, …) are **not used**: `displayboard.jsp` is only the HTML page that calls `displaytext.jsp`.

### 5. Weekly cause-list PDF — VERIFIED
`GET /Hcdbs/upload/weeklylist.pdf` → `200 application/pdf` (~318 KB, `Last-Modified` present). Proxied and cached
for 1 h; served with `X-Document-Official: true` and `X-Source-Url`.

### 6. Court cause-list PDFs — VERIFIED
`GET /Hcdbs/upload/court{n}_{yyyymmdd}.pdf` as linked from the online board → `application/pdf`.
Download is restricted to paths under `/Hcdbs/upload/` ending in `.pdf`, checked for the `%PDF` signature and a
40 MB cap.

### 7. Complete case details (`caseDetails1.jsp`) — BLOCKED
The official cause-list page calls `POST /Hcdbs/caseDetails1.jsp?casedet=WP/11111/2026` from the browser. From
the backend it returned **404 with the block page** (both raw and URL-encoded identity, with and without
`X-Requested-With`). No further attempts were made. The response field names are visible in the official page
JavaScript (`casenum, mainnum, cino, filingdate, registrationdate, pdrstatus, petitioner, respondent, advocate,
resadv, district, judname, purname, nexthdate, iasrdetails[], usrdetails[], mpdetails[], vakalathdetails[],
orderdetails[] …`) and the same JS builds order links as
`https://aphc.gov.in/hcorders/{cino[12:16]}/{orderno}.pdf`. **Because the endpoint cannot be reached, orders,
IA/USR/MP lists and connected matters are not implemented**; the app labels them "not yet available".
Unblocking this needs APHC permission/whitelisting (see Approvals).

### 8. Other references in the supplied document
| Reference | Status |
|---|---|
| `GET /Hcdbs/search.jsp` | VERIFIED (session start) |
| `POST /Hcdbs/searchtype.action` | VERIFIED |
| `POST /Hcdbs/courtlist.jsp` (weekly) | Observed as **GET** `courtlist.jsp?listtype1=W&listdate1=…` in page JS; same parser |
| `https://aphc.gov.in/displayboard`, `/displayboard.jsp`, `/Hcdbs/displayboard` | NOT USED |
| "Date wise", "Advanced", "Advocate wise" lists (`P`, `A`, `F`) | Not integrated (not in scope; advocate-wise requires CAPTCHA) |

## Failure handling
`upstream_timeout`, `upstream_unavailable` (5xx/transport), `upstream_blocked` (403/404/block page),
`upstream_protocol_error` (redirect/unexpected status), `parser_failure` (layout change), `not_found`.
Every source has its own circuit (`lexika_safety_circuits` rows: `aphc_hcdbs_cause_list`,
`aphc_hcdbs_online_board`, `aphc_hcdbs_display_board`, `aphc_hcdbs_pdf`): 5 consecutive failures open it for
300 s; `not_found` does not count. When the source fails the API serves the last stored copy with `stale=true`.

## Approvals and open questions
1. **Written permission from the AP High Court (Registrar / IT cell)** for automated, production-scale access to
   Hcdbs and the chatbot, request-rate limits, and attribution requirements. No site terms specific to
   automated access were found; that is not the same as permission.
2. Access to `caseDetails1.jsp` (or an official case-status/orders API) for orders, IA and connected matters.
3. Whether VC links on the online board may be shown to advocates (currently intentionally excluded).

## How to re-verify
`python -m scripts.live_smoke` (backend folder, ~13 throttled requests, prints counts only) and
`python -m scripts.e2e_local <api> <code> <test-mobile>` against a local API. Never run either in CI.
