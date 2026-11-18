import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/formatters.dart';
import '../../core/loaded.dart';
import '../../shared/court_repository.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';
import '../../theme/app_theme.dart';
import '../my_cause_list/my_cause_list_screen.dart';

typedef CourtListingKey = ({String listType, String date, String court});

final courtListingProvider = FutureProvider.autoDispose.family<Loaded<CourtListing>, CourtListingKey>(
    (ref, k) => ref.watch(courtRepositoryProvider).courtListing(k.listType, k.date, k.court));

enum CourtSort { sequence, caseNumber }

/// Pure filtering/sorting so it can be unit tested. Default keeps the source order.
List<ListingItem> filterListing(List<ListingItem> items,
    {String query = '', String? stage, CourtSort sort = CourtSort.sequence}) {
  final q = query.trim().toLowerCase();
  final out = items.where((i) {
    if (stage != null && i.stage != stage) return false;
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
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => context.push('/pdf?kind=court&court=${widget.courtNo}&date=${widget.isoDate}'),
          ),
          PopupMenuButton<CourtSort>(
            tooltip: l.sortBy,
            icon: const Icon(Icons.sort),
            initialValue: _sort,
            onSelected: (s) => setState(() => _sort = s),
            itemBuilder: (_) => [
              PopupMenuItem(value: CourtSort.sequence, child: Text(l.sortSequence)),
              PopupMenuItem(value: CourtSort.caseNumber, child: Text(l.sortCaseNumber)),
            ],
          ),
          IconButton(
            tooltip: l.refresh,
            icon: const Icon(Icons.refresh),
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
          final items = filterListing(data.items, query: _query, stage: _stage, sort: _sort);
          return RefreshIndicator(
            onRefresh: () => refreshProvider(ref, courtListingProvider(_key)),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length + 2,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    FreshnessBanner(loaded),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (data.bench != null) Text(data.bench!, style: Theme.of(context).textTheme.titleMedium),
                        Text('${Fmt.displayDate(data.listDate, locale: context.localeName)} · ${l.casesCount(data.totalCases)}'),
                        for (final h in data.headings)
                          Text(h, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted)),
                        const SizedBox(height: AppSpacing.md),
                        SearchField(controller: _search, onChanged: (v) => setState(() => _query = v)),
                        if (stages.length > 1)
                          SizedBox(
                            height: 48,
                            child: ListView(scrollDirection: Axis.horizontal, children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 6, right: 6),
                                child: ChoiceChip(
                                    label: Text(l.filters), selected: _stage == null, onSelected: (_) => setState(() => _stage = null)),
                              ),
                              for (final s in stages)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6, right: 6),
                                  child: ChoiceChip(label: Text(s), selected: _stage == s, onSelected: (_) => setState(() => _stage = s)),
                                ),
                            ]),
                          ),
                      ]),
                    ),
                    if (items.isEmpty) EmptyState(message: data.items.isEmpty ? l.emptyCauseList : l.emptySearch),
                  ]);
                }
                if (i == items.length + 1) return const SizedBox(height: AppSpacing.xxl);
                final it = items[i - 1];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
                  child: CaseCard(
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
                    badges: [for (final a in it.applications.take(4)) StatusChip(a.number, color: AppColors.muted)],
                    onTap: () => openCase(context, caseId: it.caseId, caseNumber: it.caseNumber),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
