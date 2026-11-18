import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/formatters.dart';
import '../../core/loaded.dart';
import '../../shared/court_repository.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';
import '../../theme/app_theme.dart';
import '../authentication/session_controller.dart';

typedef AdvocateListKey = ({String code, String date});

final advocateCauseListProvider = FutureProvider.autoDispose.family<Loaded<AdvocateCauseList>, AdvocateListKey>(
    (ref, k) => ref.watch(courtRepositoryProvider).advocateCauseList(k.code, DateTime.parse(k.date)));

void openCase(BuildContext context, {String? caseId, String? caseNumber}) {
  if (caseId != null) {
    context.push('/cases/$caseId');
  } else if (caseNumber != null) {
    context.push(Uri(path: '/case', queryParameters: {'number': caseNumber}).toString());
  }
}

/// "My Cause List" (signed-in advocate) and any advocate's list (favourites / deep links).
class MyCauseListScreen extends ConsumerStatefulWidget {
  const MyCauseListScreen({super.key, this.advocateCode, this.initialDate});
  final String? advocateCode;
  final DateTime? initialDate;

  @override
  ConsumerState<MyCauseListScreen> createState() => _MyCauseListScreenState();
}

class _MyCauseListScreenState extends ConsumerState<MyCauseListScreen> {
  late DateTime _date = widget.initialDate ?? DateTime.now();
  final _search = TextEditingController();
  String _query = '';
  String? _court;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final code = widget.advocateCode ?? ref.watch(currentMeProvider)?.advocateCode;
    if (code == null) return Scaffold(appBar: AppBar(title: Text(l.myCauseList)), body: EmptyState(message: l.notYetAvailable));
    final key = (code: code, date: Fmt.isoDate(_date));
    final value = ref.watch(advocateCauseListProvider(key));
    final title = widget.advocateCode == null ? l.myCauseList : '${l.advocateCode} $code';

    return Scaffold(
      appBar: AppBar(title: Text(title), actions: [
        IconButton(
          tooltip: l.refresh,
          icon: const Icon(Icons.refresh),
          onPressed: () async {
            try {
              await ref.read(courtRepositoryProvider).advocateCauseList(code, _date, refresh: true);
            } catch (_) {}
            ref.invalidate(advocateCauseListProvider(key));
          },
        ),
      ]),
      body: Column(children: [
        DateSelector(
          selected: _date,
          offered: value.value?.data.availableDates ?? const [],
          onChanged: (d) => setState(() {
            _date = d;
            _court = null;
          }),
        ),
        Expanded(
          child: AsyncBody<Loaded<AdvocateCauseList>>(
            value: value,
            onRetry: () => ref.invalidate(advocateCauseListProvider(key)),
            builder: (loaded) => RefreshIndicator(
              onRefresh: () => refreshProvider(ref, advocateCauseListProvider(key)),
              child: _content(context, loaded),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _content(BuildContext context, Loaded<AdvocateCauseList> loaded) {
    final l = context.l10n;
    final data = loaded.data;
    final q = _query.toLowerCase();
    bool match(AdvocateListing c) =>
        q.isEmpty ||
        [c.caseNumber, c.rawCase, c.petitioner, c.respondent, c.itemNo].whereType<String>().any((s) => s.toLowerCase().contains(q));
    final groups = [
      for (final g in data.courts)
        if (_court == null || g.courtNo == _court) (court: g.courtNo, cases: g.cases.where(match).toList()),
    ].where((g) => g.cases.isNotEmpty).toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        FreshnessBanner(loaded),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (data.advocateName != null)
              Text(data.advocateName!, style: Theme.of(context).textTheme.titleMedium),
            Text('${Fmt.displayDate(data.listDate, locale: context.localeName)} · ${l.casesCount(data.totalCases)}'),
            const SizedBox(height: AppSpacing.md),
            SearchField(controller: _search, onChanged: (v) => setState(() => _query = v)),
            if (data.courts.length > 1)
              SizedBox(
                height: 48,
                child: ListView(scrollDirection: Axis.horizontal, children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 6, top: 6),
                    child: ChoiceChip(label: Text(l.filters), selected: _court == null, onSelected: (_) => setState(() => _court = null)),
                  ),
                  for (final g in data.courts)
                    Padding(
                      padding: const EdgeInsets.only(right: 6, top: 6),
                      child: ChoiceChip(
                        label: Text(l.court(g.courtNo)),
                        selected: _court == g.courtNo,
                        onSelected: (_) => setState(() => _court = g.courtNo),
                      ),
                    ),
                ]),
              ),
          ]),
        ),
        if (!data.dateOfferedBySource && data.totalCases == 0)
          EmptyState(message: l.dateNotOffered, icon: Icons.event_busy)
        else if (groups.isEmpty)
          EmptyState(message: q.isEmpty ? l.emptyCauseList : l.emptySearch)
        else
          for (final g in groups) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
              child: Semantics(
                header: true,
                child: Row(children: [
                  Text(l.court(g.court), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.gold)),
                  const SizedBox(width: 8),
                  Text('· ${l.casesCount(g.cases.length)}'),
                ]),
              ),
            ),
            for (final c in g.cases)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
                child: CaseCard(
                  itemNo: c.itemNo,
                  caseNumber: c.caseNumber ?? c.rawCase,
                  petitioner: c.petitioner,
                  respondent: c.respondent,
                  subtitle: [
                    if (c.application != null) '${c.application}${c.applicationDescription != null ? ' – ${c.applicationDescription}' : ''}',
                    c.listType,
                    if (c.stage != null) c.stage!,
                  ].join(' · '),
                  advocates: [...c.petitionerAdvocates, ...c.respondentAdvocates],
                  onTap: c.caseNumber == null ? null : () => openCase(context, caseId: c.caseId, caseNumber: c.caseNumber),
                ),
              ),
          ],
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}
