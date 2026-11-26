import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/formatters.dart';
import '../../core/loaded.dart';
import '../../shared/court_repository.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/brand_art.dart';
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

const _soft = Color(0xFFC9D2E0);

/// "My Cause List" (signed-in advocate) and any advocate's list (favourites / deep links / the Daily
/// cause list's advocate-code view). [embedded] drops the screen's own header so the list can sit inside
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

  void _pickDate(DateTime d) => setState(() {
    _date = d;
    _datePicked = true;
    _court = null;
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final code = widget.advocateCode ?? ref.watch(currentMeProvider)?.advocateCode;
    if (code == null) {
      return _framed(_ListHeader(title: l.myCauseList), Expanded(child: EmptyState(message: l.notYetAvailable)));
    }
    final key = (code: code, date: Fmt.isoDate(_date));
    final value = ref.watch(advocateCauseListProvider(key));
    final title = widget.advocateCode == null ? l.myCauseList : '${l.advocateCode} $code';
    final offered = value.value?.data.availableDates ?? const <String>[];

    if (widget.embedded) _jumpToOfferedDate(value.value?.data);
    final list = Expanded(
      child: AsyncBody<Loaded<AdvocateCauseList>>(
        value: value,
        onRetry: () => ref.invalidate(advocateCauseListProvider(key)),
        builder: (loaded) => RefreshIndicator(
          onRefresh: () => refreshProvider(ref, advocateCauseListProvider(key)),
          child: _content(context, loaded),
        ),
      ),
    );
    if (widget.embedded) {
      return Column(
        children: [
          DateSelector(selected: _date, offered: offered, onChanged: _pickDate),
          list,
        ],
      );
    }
    return _framed(
      _ListHeader(
        title: title,
        subtitle: Fmt.displayDate(_date, locale: context.localeName),
        onRefresh: () async {
          try {
            await ref.read(courtRepositoryProvider).advocateCauseList(code, _date, refresh: true);
          } catch (_) {}
          ref.invalidate(advocateCauseListProvider(key));
        },
        dates: DateSelector(selected: _date, offered: offered, onChanged: _pickDate, onDark: true),
      ),
      list,
    );
  }

  Widget _framed(Widget header, Widget body) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light,
    child: Scaffold(body: Column(children: [header, body])),
  );

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
          child: FadeSlideIn(
            child: _SummaryCard(
              data: data,
              selectedCourt: _court,
              onCourt: (c) => setState(() => _court = _court == c ? null : c),
            ),
          ),
        ),
        Padding(
          padding: AppLayout.page(context, top: AppSpacing.md),
          child: SearchField(controller: _search, onChanged: (v) => setState(() => _query = v)),
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
              padding: AppLayout.page(context, top: AppSpacing.md, bottom: AppSpacing.sm + 2),
              child: _CourtHeader(court: g.court, count: g.cases.length),
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

/// Navy header with a gold curved edge (as on Home): back (when pushed), title, date, refresh, date chips.
class _ListHeader extends StatelessWidget {
  const _ListHeader({required this.title, this.subtitle, this.onRefresh, this.dates});
  final String title;
  final String? subtitle;
  final VoidCallback? onRefresh;
  final Widget? dates;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context);
    final tk = context.tokens;
    final g = AppLayout.gutter(context);
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    return CustomPaint(
      painter: HeroBackgroundPainter(top: tk.heroTop, bottom: tk.heroBottom, curve: 26),
      child: Stack(
        children: [
          Positioned.fill(
            child: HeroPhoto(top: tk.heroTop, bottom: tk.heroBottom, curve: 26, textSide: .97),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(canPop ? g - 12 : g, 0, g - 8, 0),
                    child: Row(
                      children: [
                        if (canPop) const BackButton(color: Colors.white),
                        if (!canPop) ...[
                          const Icon(LucideIcons.gavel, color: AppColors.gold, size: 26),
                          const SizedBox(width: AppSpacing.md),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Semantics(
                                header: true,
                                child: Text(title, style: t.textTheme.headlineSmall?.copyWith(color: Colors.white)),
                              ),
                              if (subtitle != null)
                                Row(
                                  children: [
                                    const Icon(AppIcons.calendar, size: 14, color: _soft),
                                    const SizedBox(width: 6),
                                    Text(subtitle!, style: t.textTheme.bodyMedium?.copyWith(color: _soft)),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        if (onRefresh != null)
                          IconButton(
                            tooltip: l.refresh,
                            onPressed: onRefresh,
                            icon: const Icon(AppIcons.refresh, color: Colors.white),
                          ),
                      ],
                    ),
                  ),
                  if (dates != null) ...[const SizedBox(height: AppSpacing.xs), dates!],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dark summary card (as on Home): advocate, total, and court pills that filter the list.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data, required this.selectedCourt, required this.onCourt});
  final AdvocateCauseList data;
  final String? selectedCourt;
  final ValueChanged<String> onCourt;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.tokens.featureBorder),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [context.tokens.featureTop, context.tokens.featureBottom],
        ),
        boxShadow: const [BoxShadow(color: Color(0x330B1930), blurRadius: 18, offset: Offset(0, 8))],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: 18,
            top: 24,
            child: ExcludeSemantics(child: Icon(LucideIcons.scale, size: 88, color: Color(0x14FFFFFF))),
          ),
          const Positioned(
            right: 0,
            bottom: 0,
            width: 140,
            height: 64,
            child: CustomPaint(painter: GoldSwooshPainter()),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg + 4, AppSpacing.md + 2, AppSpacing.lg, AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(AppIcons.advocate, color: AppColors.gold, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        data.advocateName ?? l.myCauseList,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l.casesCount(data.totalCases),
                  style: t.textTheme.headlineMedium?.copyWith(color: Colors.white, fontSize: 32, letterSpacing: -0.5),
                ),
                if (data.courts.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in data.courts)
                        _CourtFilterPill(
                          label: '${l.court(c.courtNo)} · ${c.cases.length}',
                          selected: selectedCourt == c.courtNo,
                          onTap: () => onCourt(c.courtNo),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Court pill on the dark card; tapping filters the list to that court, tapping again shows all.
class _CourtFilterPill extends StatelessWidget {
  const _CourtFilterPill({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.navyDeep : Colors.white;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.gold : Colors.white.withValues(alpha: .10),
        shape: StadiumBorder(side: BorderSide(color: selected ? AppColors.gold : Colors.white.withValues(alpha: .12))),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(selected ? AppIcons.check : AppIcons.court, size: 15, color: fg),
                const SizedBox(width: 7),
                Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Court heading: gold-soft circle, court name and a case-count pill.
class _CourtHeader extends StatelessWidget {
  const _CourtHeader({required this.court, required this.count});
  final String court;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context);
    final tk = context.tokens;
    return Semantics(
      header: true,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: tk.goldSoft, shape: BoxShape.circle),
            child: Icon(AppIcons.court, size: 18, color: tk.goldText),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l.court(court),
              style: t.textTheme.titleMedium?.copyWith(color: t.colorScheme.primary, fontWeight: FontWeight.w700),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: tk.subtleFill, borderRadius: BorderRadius.circular(20)),
            child: Text(l.casesCount(count), style: t.textTheme.labelMedium?.copyWith(color: t.colorScheme.primary)),
          ),
        ],
      ),
    );
  }
}
