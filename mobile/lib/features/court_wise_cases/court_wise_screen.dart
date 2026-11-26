import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/formatters.dart';
import '../../core/loaded.dart';
import '../../shared/court_repository.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/pdf_check.dart';
import '../../shared/widgets/widgets.dart';
import '../../theme/app_theme.dart';
import '../my_cause_list/my_cause_list_screen.dart';

typedef CourtListingKey = ({String listType, String date, String court});

final courtListingProvider = FutureProvider.autoDispose.family<Loaded<CourtListing>, CourtListingKey>(
    (ref, k) => ref.watch(courtRepositoryProvider).courtListing(k.listType, k.date, k.court));

enum CourtSort { sequence, caseNumber }

/// Pure filtering/sorting so it can be unit tested. Default keeps the source order.
List<ListingItem> filterListing(List<ListingItem> items,
    {String query = '', String? stage, CourtSort sort = CourtSort.sequence, bool onlyPdfDifferences = false}) {
  final q = query.trim().toLowerCase();
  final out = items.where((i) {
    if (stage != null && i.stage != stage) return false;
    if (onlyPdfDifferences && (i.pdfCheck == null || i.pdfCheck!.status == 'match')) return false;
    if (q.isEmpty) return true;
    return [
      i.caseNumber,
      i.itemNo,
      i.petitioner,
      i.respondent,
      ...i.petitionerAdvocates,
      ...i.respondentAdvocates,
      ...i.applications.map((a) => a.number),
    ].whereType<String>().any((s) => s.toLowerCase().contains(q));
  }).toList();
  if (sort == CourtSort.caseNumber) {
    out.sort((a, b) => a.caseNumber.compareTo(b.caseNumber));
  } else {
    out.sort((a, b) => a.sequence.compareTo(b.sequence));
  }
  return out;
}

class CourtWiseScreen extends ConsumerStatefulWidget {
  const CourtWiseScreen({super.key, required this.listType, required this.courtNo, required this.isoDate});
  final String listType;
  final String courtNo;
  final String isoDate;

  @override
  ConsumerState<CourtWiseScreen> createState() => _CourtWiseScreenState();
}

class _CourtWiseScreenState extends ConsumerState<CourtWiseScreen> {
  final _search = TextEditingController();
  String _query = '';
  String? _stage;
  CourtSort _sort = CourtSort.sequence;
  bool _onlyPdfDifferences = false;

  CourtListingKey get _key => (listType: widget.listType, date: widget.isoDate, court: widget.courtNo);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final value = ref.watch(courtListingProvider(_key));
    return Scaffold(
      appBar: AppBar(
        title: Text(l.court(widget.courtNo)),
        actions: [
          IconButton(
            tooltip: l.officialPdf,
            icon: const Icon(AppIcons.pdf),
            onPressed: () => context.push('/pdf?kind=court&court=${widget.courtNo}&date=${widget.isoDate}'),
          ),
          PopupMenuButton<CourtSort>(
            tooltip: l.sortBy,
            icon: const Icon(AppIcons.sort),
            initialValue: _sort,
            onSelected: (s) => setState(() => _sort = s),
            itemBuilder: (_) => [
              PopupMenuItem(value: CourtSort.sequence, child: Text(l.sortSequence)),
              PopupMenuItem(value: CourtSort.caseNumber, child: Text(l.sortCaseNumber)),
            ],
          ),
          IconButton(
            tooltip: l.refresh,
            icon: const Icon(AppIcons.refresh),
            onPressed: () async {
              try {
                await ref.read(courtRepositoryProvider).courtListing(widget.listType, widget.isoDate, widget.courtNo, refresh: true);
              } catch (_) {}
              ref.invalidate(courtListingProvider(_key));
            },
          ),
        ],
      ),
      body: AsyncBody<Loaded<CourtListing>>(
        value: value,
        onRetry: () => ref.invalidate(courtListingProvider(_key)),
        builder: (loaded) {
          final data = loaded.data;
          final stages = {for (final i in data.items) if (i.stage != null) i.stage!}.toList();
          final items = filterListing(data.items,
              query: _query, stage: _stage, sort: _sort, onlyPdfDifferences: _onlyPdfDifferences);
          final pdfOnly = data.pdfVerification?.pdfOnlyItems ?? const <ListingItem>[];
          return RefreshIndicator(
            onRefresh: () => refreshProvider(ref, courtListingProvider(_key)),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              // header, items, [PDF-only title, PDF-only items], bottom spacer
              itemCount: items.length + 2 + (pdfOnly.isEmpty ? 0 : pdfOnly.length + 1),
              itemBuilder: (context, i) {
                if (i > 0 && i == items.length + 1 + (pdfOnly.isEmpty ? 0 : pdfOnly.length + 1)) {
                  return const SizedBox(height: AppSpacing.xxl);
                }
                if (i == 0) {
                  final tk = context.tokens;
                  final tt = Theme.of(context).textTheme;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FreshnessBanner(loaded),
                      PdfCheckBanner(
                        listing: data,
                        showingDifferences: _onlyPdfDifferences,
                        onToggleDifferences: () => setState(() => _onlyPdfDifferences = !_onlyPdfDifferences),
                      ),
                      Padding(
                        padding: AppLayout.page(context, top: AppSpacing.md),
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const IconBadge(AppIcons.judge, size: 38, iconSize: 19),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (data.bench != null) Text(data.bench!, style: tt.titleSmall),
                                        Text(
                                          '${Fmt.displayDate(data.listDate, locale: context.localeName)} · ${l.casesCount(data.totalCases)}',
                                          style: tt.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (data.headings.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.md),
                                const Divider(height: 1),
                                const SizedBox(height: AppSpacing.sm),
                                for (final h in data.headings)
                                  Text(h, style: tt.bodySmall?.copyWith(color: tk.textTertiary)),
                              ],
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: AppLayout.page(context, top: AppSpacing.md, bottom: AppSpacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SearchField(controller: _search, onChanged: (v) => setState(() => _query = v)),
                            if (stages.length > 1)
                              ChipStrip(
                                children: [
                                  ChoiceChip(
                                    label: Text(l.filters),
                                    selected: _stage == null,
                                    onSelected: (_) => setState(() => _stage = null),
                                  ),
                                  for (final s in stages)
                                    ChoiceChip(
                                      label: Text(s),
                                      selected: _stage == s,
                                      onSelected: (_) => setState(() => _stage = s),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      if (items.isEmpty)
                        EmptyState(
                          message: data.items.isEmpty ? l.emptyCauseList : l.emptySearch,
                          icon: data.items.isEmpty ? AppIcons.empty : AppIcons.searchEmpty,
                        ),
                    ],
                  );
                }
                if (i == items.length + 1) {
                  return Padding(
                    key: const Key('pdfOnlySection'),
                    padding: AppLayout.page(context, top: AppSpacing.lg, bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Icon(AppIcons.pdf, size: 16, color: context.tokens.warning),
                        const SizedBox(width: 8),
                        Expanded(child: Text(l.pdfOnlyTitle, style: Theme.of(context).textTheme.titleSmall)),
                      ],
                    ),
                  );
                }
                if (i > items.length + 1) {
                  final p = pdfOnly[i - items.length - 2];
                  return Padding(
                    padding: AppLayout.page(context, bottom: AppSpacing.md - 2),
                    child: _card(context, p, badges: [StatusChip(l.pdfOnlyTitle, color: AppColors.warning)]),
                  );
                }
                final it = items[i - 1];
                return Padding(
                  padding: AppLayout.page(context, bottom: AppSpacing.md - 2),
                  child: _card(context, it, badges: [?pdfCheckBadge(context, it.pdfCheck)]),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _card(BuildContext context, ListingItem it, {List<Widget> badges = const []}) => CaseCard(
        itemNo: it.itemNo,
        caseNumber: it.caseNumber,
        petitioner: it.petitioner,
        respondent: it.respondent,
        subtitle: [
          if (it.stage != null) it.stage!,
          if (it.district != null) it.district!,
          if (it.remarks != null) it.remarks!,
        ].join(' · '),
        advocates: [...it.petitionerAdvocates, ...it.respondentAdvocates],
        badges: [
          ...badges,
          for (final a in it.applications.take(4)) StatusChip(a.number, color: AppColors.muted),
        ],
        onTap: () => openCase(context, caseId: it.caseId, caseNumber: it.caseNumber),
      );
}
