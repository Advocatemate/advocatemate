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
  const CauseListBrowser({super.key, required this.listType, required this.title, this.initialDate, this.actions = const []});
  final String listType; // D | W | S
  final String title;
  final DateTime? initialDate;
  final List<Widget> actions;

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
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(listDatesProvider(widget.listType));
              ref.invalidate(courtsProvider(key));
            }),
      ]),
      body: dates.isLoading && !dates.hasValue
          ? const SkeletonList()
          : dates.hasError && !dates.hasValue
              ? ErrorState(error: dates.error!, onRetry: () => ref.invalidate(listDatesProvider(widget.listType)))
              : Column(children: [
                  DateSelector(selected: selected, offered: offered, onChanged: (d) => setState(() => _date = d)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
                    child: TextField(
                      controller: _caseQuery,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l.searchHint),
                      onSubmitted: (v) {
                        if (v.trim().isNotEmpty) {
                          context.push(Uri(path: '/search', queryParameters: {'q': v.trim()}).toString());
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: courts == null
                        ? EmptyState(message: l.dateNotOffered, icon: Icons.event_busy)
                        : AsyncBody<Loaded<CourtsResponse>>(
                            value: courts,
                            onRetry: () => ref.invalidate(courtsProvider(key)),
                            builder: (loaded) => RefreshIndicator(
                              onRefresh: () => refreshProvider(ref, courtsProvider(key)),
                              child: ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
                                FreshnessBanner(loaded),
                                if (loaded.data.courts.isEmpty) EmptyState(message: l.emptyCauseList),
                                for (final c in loaded.data.courts)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
                                    child: Card(
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: AppColors.navy,
                                          foregroundColor: AppColors.gold,
                                          child: Text(c.courtNo),
                                        ),
                                        title: Text(c.courtName),
                                        subtitle: Text([
                                          if (c.bench != null) c.bench!,
                                          if (c.caseCount != null) l.casesCount(c.caseCount!),
                                        ].join(' · ')),
                                        trailing: const Icon(Icons.chevron_right),
                                        onTap: () => context.push('/court/${widget.listType}/${c.courtNo}?date=${key.date}'),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: AppSpacing.xxl),
                              ]),
                            ),
                          ),
                  ),
                ]),
    );
  }
}
