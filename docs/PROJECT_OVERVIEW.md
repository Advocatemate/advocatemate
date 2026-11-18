# Project overview

**AdvocateMate** is a mobile app (Android + iOS) and backend that help advocates of the High Court of Andhra
Pradesh follow their cause lists, court-wise listings, case details and live court displays.

## Users
Advocates practising before APHC (primary), their clerks/juniors (via favourite advocates), administrators.

## Capabilities
* Sign-in with advocate code + mobile OTP (identity self-declared until verified — see AUTHENTICATION.md).
* My Cause List for the advocate's code, grouped by court, with date selection, search and filters.
* Daily, weekly and supplementary cause lists (kept separate), court-wise listings in source order.
* Case details from APHC's Lexika chatbot, fetched asynchronously with freshness indicators.
* Official weekly/court cause-list PDFs (proxied) and a clearly labelled generated case summary.
* Live court display (backend-polled), publication status, favourites, notifications, search, offline mode,
  English and Telugu, light and dark themes.

## Data sources
Public pages of `aphc.gov.in` (Hcdbs) and the APHC Lexika chatbot. See APHC_INTEGRATION.md and
LEXIKA_INTEGRATION.md for the verified contracts and the approvals still required.

## Non-goals (current)
Filing, e-payment, official certified copies, or anything implying the app is an official court service.

## Documents
ARCHITECTURE · TECH_STACK · DATABASE_SCHEMA · API_DOCUMENTATION · APHC_INTEGRATION · LEXIKA_INTEGRATION ·
AUTHENTICATION · SECURITY · TESTING · ANDROID_RELEASE · IOS_RELEASE · DEPLOYMENT · DEVELOPMENT_PROGRESS
