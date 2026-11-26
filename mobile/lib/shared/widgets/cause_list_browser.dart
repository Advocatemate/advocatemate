import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/formatters.dart';
import '../../core/loaded.dart';
import '../../theme/app_theme.dart';
import '../court_repository.dart';
import '../models/models.dart';
import 'widgets.dart';

final listDatesProvider = FutureProvider.autoDispose.family<Loaded<ListDates>, String>(
    (ref, listType) => ref.watch(courtRepositoryProvider).listDates(listType));

typedef CourtsKey = ({String listType, String date});

final courtsProvider = FutureProvider.autoDispose.family<Loaded<CourtsResponse>, CourtsKey>(
    (ref, k) => ref.watch(courtRepositoryProvider).courts(k.listType, k.date));

/// Shared court picker used by the separate Daily / Weekly / Supplementary screens.
/// Each list type has its own route, title, provider keys and cache - they never mix.
class CauseListBrowser extends ConsumerStatefulWidget {
  const CauseListBrowser(
      {super.key, required this.listType, required this.title, this.initialDate, this.actions = const [], this.header});
  final String listType; // D | W | S
  final String title;
  final DateTime? initialDate;
  final List<Widget> actions;
  final Widget? header; // shown above the date chips (e.g. the Daily list's view switch)

  @override
  ConsumerState<CauseListBrowser> createState() => _CauseListBrowserState();
}

class _CauseListBrowserState extends ConsumerState<CauseListBrowser> {
  DateTime? _date;
  final _caseQuery = TextEditingController();

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;
  }

  @override
  void dispose() {
    _caseQuery.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final dates = ref.watch(listDatesProvider(widget.listType));
    final offered = dates.value?.data.dates ?? const <String>[];
    final selected = _date ?? (offered.isNotEmpty ? DateTime.parse(offered.first) : DateTime.now());
    final key = (listType: widget.listType, date: Fmt.isoDate(selected));
    final dateOffered = offered.contains(key.date);
    final courts = dateOffered ? ref.watch(courtsProvider(key)) : null;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: [
        ...widget.actions,
        IconButton(
            tooltip: l.refresh,
            icon: const Icon(AppIcons.refresh),
            onPressed: () {
              ref.invalidate(listDatesProvider(widget.listType));
              ref.invalidate(courtsProvider(key));
            },
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: dates.isLoading && !dates.hasValue
          ? Column(
              children: [
                ?widget.header,
                const Expanded(child: SkeletonList(height: 76)),
              ],
            )
          : dates.hasError && !dates.hasValue
          ? Column(
              children: [
                ?widget.header,
                Expanded(
                  child: ErrorState(
                    error: dates.error!,
                    onRetry: () => ref.invalidate(listDatesProvider(widget.listType)),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                ?widget.header,
                DateSelector(selected: selected, offered: offered, onChanged: (d) => setState(() => _date = d)),
                Padding(
                  padding: AppLayout.page(context, top: AppSpacing.xs, bottom: AppSpacing.xs),
                  child: SearchField(
                    controller: _caseQuery,
                    onChanged: (_) {},
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty) {
                        context.push(Uri(path: '/search', queryParameters: {'q': v.trim()}).toString());
                      }
                    },
                  ),
                ),
                Expanded(
                  child: courts == null
                      ? EmptyState(message: l.dateNotOffered, icon: AppIcons.dateMissing)
                      : AsyncBody<Loaded<CourtsResponse>>(
                          value: courts,
                          onRetry: () => ref.invalidate(courtsProvider(key)),
                          builder: (loaded) => RefreshIndicator(
                            onRefresh: () => refreshProvider(ref, courtsProvider(key)),
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                FreshnessBanner(loaded),
                                if (loaded.data.courts.isEmpty) EmptyState(message: l.emptyCauseList),
                                for (final c in loaded.data.courts)
                                  Padding(
                                    padding: AppLayout.page(context, top: AppSpacing.md),
                                    child: CourtCard(
                                      courtNo: c.courtNo,
                                      title: c.courtName,
                                      subtitle: [
                                        if (c.bench != null) c.bench!,
                                        if (c.caseCount != null) l.casesCount(c.caseCount!),
                                      ].join(' · '),
                                      onTap: () =>
                                          context.push('/court/${widget.listType}/${c.courtNo}?date=${key.date}'),
                                    ),
                                  ),
                                const SizedBox(height: AppSpacing.xxl),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

/// One court in a cause list: navy number tile, court name, bench and case count.
class CourtCard extends StatelessWidget {
  const CourtCard({super.key, required this.courtNo, required this.title, this.subtitle, this.onTap});
  final String courtNo;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final tk = context.tokens;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      child: Row(
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 46),
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.navyLight, AppColors.navy],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: ExcludeSemantics(
              child: Text(
                courtNo,
                style: t.textTheme.titleMedium?.copyWith(color: AppColors.gold, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.textTheme.titleSmall),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(subtitle!, style: t.textTheme.bodySmall),
                ],
              ],
            ),
          ),
          Icon(AppIcons.chevronRight, size: 18, color: tk.textTertiary),
        ],
      ),
    );
  }
}
