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

/// "My Cause List" (signed-in advocate) and any advocate's list (favourites / deep links / the Daily
/// cause list's advocate-code view). [embedded] drops the screen's own app bar so the list can sit inside
/// another screen, and moves to the latest date the source offers when today is not offered yet.
class MyCauseListScreen extends ConsumerStatefulWidget {
  const MyCauseListScreen({super.key, this.advocateCode, this.initialDate, this.embedded = false});
  final String? advocateCode;
  final DateTime? initialDate;
  final bool embedded;

  @override
  ConsumerState<MyCauseListScreen> createState() => _MyCauseListScreenState();
}

class _MyCauseListScreenState extends ConsumerState<MyCauseListScreen> {
  late DateTime _date = widget.initialDate ?? DateTime.now();
  bool _datePicked = false;
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

    if (widget.embedded) _jumpToOfferedDate(value.value?.data);
    final body = Column(children: [
        DateSelector(
          selected: _date,
          offered: value.value?.data.availableDates ?? const [],
          onChanged: (d) => setState(() {
            _date = d;
            _datePicked = true;
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
      ]);
    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: l.refresh,
            icon: const Icon(AppIcons.refresh),
            onPressed: () async {
              try {
                await ref.read(courtRepositoryProvider).advocateCauseList(code, _date, refresh: true);
              } catch (_) {}
              ref.invalidate(advocateCauseListProvider(key));
            },
          ),
        ],
      ),
      body: body,
    );
  }

  /// The High Court's advocate service can lag the Daily list by a day: when the chosen date is not
  /// offered and the user has not picked one, show the latest offered date (never a future one first).
  void _jumpToOfferedDate(AdvocateCauseList? data) {
    if (_datePicked || data == null || data.dateOfferedBySource || data.availableDates.isEmpty) return;
    final today = Fmt.isoDate(DateTime.now());
    final offered = [...data.availableDates]..sort((a, b) => b.compareTo(a));
    final target = offered.firstWhere((d) => d.compareTo(today) <= 0, orElse: () => offered.last);
    if (target == Fmt.isoDate(_date)) return;
    _datePicked = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _date = DateTime.parse(target));
    });
  }

  Widget _content(BuildContext context, Loaded<AdvocateCauseList> loaded) {
    final l = context.l10n;
    final t = Theme.of(context);
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
          padding: AppLayout.page(context, top: AppSpacing.md),
          child: AppCard(
            child: Row(
              children: [
                IconBadge(
                  AppIcons.cases,
                  size: 40,
                  iconSize: 20,
                  background: context.tokens.goldSoft,
                  color: context.tokens.onGoldSoft,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data.advocateName != null) Text(data.advocateName!, style: t.textTheme.titleMedium),
                      Text(Fmt.displayDate(data.listDate, locale: context.localeName), style: t.textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l.casesCount(data.totalCases),
                  style: t.textTheme.titleSmall?.copyWith(color: t.colorScheme.primary),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: AppLayout.page(context, top: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SearchField(controller: _search, onChanged: (v) => setState(() => _query = v)),
              if (data.courts.length > 1)
                ChipStrip(
                  children: [
                    ChoiceChip(
                      label: Text(l.filters),
                      selected: _court == null,
                      onSelected: (_) => setState(() => _court = null),
                    ),
                    for (final g in data.courts)
                      ChoiceChip(
                        label: Text(l.court(g.courtNo)),
                        selected: _court == g.courtNo,
                        onSelected: (_) => setState(() => _court = g.courtNo),
                      ),
                  ],
                ),
            ],
          ),
        ),
        if (!data.dateOfferedBySource && data.totalCases == 0)
          EmptyState(message: l.dateNotOffered, icon: AppIcons.dateMissing)
        else if (groups.isEmpty)
          EmptyState(
            message: q.isEmpty ? l.emptyCauseList : l.emptySearch,
            icon: q.isEmpty ? AppIcons.empty : AppIcons.searchEmpty,
          )
        else
          for (final g in groups) ...[
            Padding(
              padding: AppLayout.page(context, top: AppSpacing.xl, bottom: AppSpacing.md - 2),
              child: Semantics(
                header: true,
                child: Row(
                  children: [
                    Icon(AppIcons.court, size: 16, color: context.tokens.goldText),
                    const SizedBox(width: 8),
                    Text(l.court(g.court), style: t.textTheme.titleSmall?.copyWith(color: t.colorScheme.primary)),
                    const SizedBox(width: 8),
                    Text('· ${l.casesCount(g.cases.length)}', style: t.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
            for (final c in g.cases)
              Padding(
                padding: AppLayout.page(context, bottom: AppSpacing.md - 2),
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
