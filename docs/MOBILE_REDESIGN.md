# AdvocateMate mobile — UI/UX redesign (premium legal-tech)

Status: implemented on `main` (Nov 2026). This file is the plan and the reference for the design language.

## Ground rules

- UI only. API endpoints, repositories, `SessionController`, advocate-code verification, models,
  providers, caching and cause-list processing are unchanged. Routes in `lib/routing/app_router.dart`
  are unchanged (same paths, same query parameters, same deep links).
- Every screen keeps its existing widgets keys (`googleSignInButton`, `advocateCodeField`,
  `dailyViewSwitch`, `liveStaleBanner`, `pdfVerifiedBanner`, …) so tests and deep links keep working.
- No screen is rewritten from scratch: build methods are restyled on top of shared components.

## Design tokens (`lib/theme/app_theme.dart`)

| Token | Value | Use |
|---|---|---|
| `AppColors.navy` | `#14243D` | primary: buttons, headings, selected states |
| `AppColors.navyDeep` | `#0B1930` | hero headers, splash |
| `AppColors.gold` | `#C49A45` | accents only (bars, icons, indicator) — never body text on white |
| `AppColors.goldDeep` | `#8C6A2A` | gold-toned *text* (meets 4.5:1 on white) |
| `AppColors.goldSoft` | `#F3E9D2` | soft gold fills (selected nav pill, notices) |
| `AppColors.background` | `#F5F7FA` | scaffold |
| `AppColors.surface` | `#FFFFFF` | cards |
| `AppColors.textPrimary` | `#202B3C` | body text |
| `AppColors.textSecondary` | `#5D6676` | secondary text (darkened from `#7A8493` for AA contrast) |
| `AppColors.textTertiary` | `#7A8493` | hints, inactive icons, captions on large text only |

Dark mode keeps working: components read colours from `Theme.of(context)` / the `AppTokens`
theme extension (`context.tokens`) rather than hard-coded light values.

Typography: **Inter** (bundled, SIL OFL), falling back to Noto Sans and Noto Sans Telugu for
glyphs Inter lacks (Telugu, ₹, …). Device/OEM fonts are still ignored.

Spacing scale: 4 / 8 / 12 / 16 / 20 / 24 / 32. Radii: 10 (chips, small), 16 (cards), 24 (hero).
Elevation: one soft shadow (`AppShadows.card`); no heavy gradients.

## Icon system (`lib/shared/widgets/app_icons.dart`)

Lucide only (`lucide_icons_flutter`), one stroke weight, sizes 18 / 20 / 22 / 24. Screens use
semantic names (`AppIcons.home`, `AppIcons.court`, `AppIcons.liveBoard`, …), never `Icons.*`.

| Concept | Lucide |
|---|---|
| Home / My List / Search / Saved / More | `house` / `listChecks` / `search` / `bookmark` / `layoutGrid` |
| Daily / Weekly / Supplementary | `calendarDays` / `calendarRange` / `calendarPlus` |
| Court / Cases / Judge | `landmark` / `briefcaseBusiness` / `scale` |
| Live display board | `monitorPlay` |
| Notifications / Profile / Settings / Support | `bell` / `circleUserRound` / `settings` / `lifeBuoy` |

## Shared components (`lib/shared/widgets/`)

- `AppCard` — rounded white card with soft shadow, optional tap ripple.
- `SectionCard`, `SectionHeader` — titled card / list heading with optional action.
- `StatusChip` (status badge) — tinted pill with optional icon; tones for success/warning/danger.
- `AppSearchField` / `SearchField` — 52 px rounded field with search icon and clear button.
- `PrimaryButton` — full-width filled button with built-in busy spinner.
- `SkeletonList` — rounded placeholders; `AppLoader` — small spinner.
- `EmptyState` / `ErrorState` — icon in a soft circle, message, optional action.
- `InfoBanner` — rounded inline notice (offline, stale, PDF check, enrichment).
- `IconBadge` — icon in a tinted rounded square (tiles, list rows).
- `AppBottomNav` — white bar, top hairline, gold-soft pill behind the selected icon.
- `BrandMark`, `AvatarInitials`, `FadeSlideIn` (one-shot entrance animation).

## Screen structure

1. **Splash** — deep-navy background, brand mark, name, tagline, slim gold progress.
2. **Google sign-in** — navy hero with brand; white sheet with title, subtitle, Google button,
   verification note, error, data notice.
3. **Advocate Code** — "Step 2 of 2", signed-in Google account pill, code field, verify, switch account.
4. **Home** — navy hero (avatar, bell with unread badge, time-of-day greeting, *Welcome, name*, advocate
   code pill) → *Today's cause list* card (total cases, court-wise chips, link to My List) →
   *Cause-list publication* card (date, uploaded progress bar, status badges e.g. UPLOADED / ON LEAVE) →
   *Quick access* 2×2 grid (Daily, Weekly, Supplementary, Live display) → *Shortcuts* card
   (Passed-over, Search cases, Favourite advocates, Saved cases, Notifications).
5. **Daily cause list** — light app bar, segmented Court-wise / Advocate code switch, date chips,
   search, court cards (navy number badge, name, bench · count).
6. **Weekly / Supplementary** — same browser as Daily (weekly adds the PDF action).
7. **Court-wise listing** — summary card (bench, date, count, headings), PDF-check banner, search,
   stage filters, case cards.
8. **Live display board** — status row (Live / Not current + last updated), auto-refresh card, court
   filter chips, grid of court tiles with the current item in large type.
9. **My List** — date chips, summary (advocate, date, count), search, court filters, court-grouped cards.
10. **Search** — prominent search field, filter toggle panel, results, recent searches card.
11. **Saved** — tabs (Saved cases / Favourite advocates) with gold indicator on a light app bar.
12. **Notifications** — cards with category icon, unread dot, title, body, time.
13. **Profile** — identity header card (avatar, name, code, verification badge), details, edit form.
14. **Settings** — grouped cards: Appearance, Notification preferences, Data, About.
15. **More** — profile header card, grouped menu sections, switch account, log out.
16. **Detail screens** — case details (sections as cards, enrichment banner), passed-over list,
    PDF viewer (notice banner, progress, page pill).

## Not in this redesign

- **Lexika chatbot**: the app has no chatbot screen or API. "Lexika" is the High Court data
  service the backend reads advocate lists from. A chatbot needs a backend endpoint first.
- **Support screen**: no support route exists; the icon is defined for when one is added.

## Implementation notes

- Tests: all existing tests kept. One finder changed: the advocate-favourite toggle used Material's filled
  star; Lucide has no filled glyphs, so the saved state is now `AppIcons.savedOn` (bookmark-check) and
  `advocate_lookup_test.dart` looks for that icon instead.
- Formatting: the codebase does not follow `dart format` output, so only redesigned UI code was formatted
  (page width 120); untouched logic keeps its original layout.
- Package size: `lucide_icons_flutter` also bundles six stroke-weight fonts (~3.2 MB) the app does not use.
  The main Lucide font is tree-shaken in release builds; check the release APK size and vendor a single
  font if the extra weight matters.
- Inter is the Latin subset (~67 KB per weight); other glyphs fall back to the bundled Noto fonts.

## Stages

1. Design system: tokens, theme, Inter, Lucide, shared components.
2. Auth screens (splash, sign-in, advocate code) and the bottom navigation shell.
3. Home dashboard and cause-list screens (daily, weekly, supplementary, court-wise, My List).
4. Live board, search, saved, notifications, profile, settings, more, details, passed-over, PDF.
5. `dart format`, `flutter analyze`, full test suite.
