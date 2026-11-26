import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/formatters.dart';
import '../../core/loaded.dart';
import '../../shared/court_repository.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';
import '../../theme/app_theme.dart';
import '../my_cause_list/my_cause_list_screen.dart';

/// null = today (the backend's court date).
final passedOverProvider = FutureProvider.autoDispose.family<Loaded<PassedOverList>, String?>(
    (ref, isoDate) => ref.watch(courtRepositoryProvider).passedOver(date: isoDate == null ? null : DateTime.parse(isoDate)));

/// Passed-over list: items courts kept back, from "Kept Back Cases" on the APHC display board.
class PassedOverScreen extends ConsumerStatefulWidget {
  const PassedOverScreen({super.key, this.initialDate});
  final DateTime? initialDate;

  @override
  ConsumerState<PassedOverScreen> createState() => _PassedOverScreenState();
}

class _PassedOverScreenState extends ConsumerState<PassedOverScreen> {
  late String? _date = widget.initialDate == null ? null : Fmt.isoDate(widget.initialDate!);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final value = ref.watch(passedOverProvider(_date));
    return Scaffold(
      appBar: AppBar(
        title: Text(l.passedOverList),
        actions: [
          IconButton(
            tooltip: l.refresh,
            icon: const Icon(AppIcons.refresh),
            onPressed: () => ref.invalidate(passedOverProvider(_date)),
          ),
        ],
      ),
      body: AsyncBody<Loaded<PassedOverList>>(
        value: value,
        onRetry: () => ref.invalidate(passedOverProvider(_date)),
        builder: (loaded) {
          final data = loaded.data;
          final t = Theme.of(context);
          final muted = t.textTheme.bodySmall;
          return RefreshIndicator(
            onRefresh: () => refreshProvider(ref, passedOverProvider(_date)),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                FreshnessBanner(loaded),
                Padding(
                  padding: AppLayout.page(context, top: AppSpacing.md),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const IconBadge(AppIcons.passedOver, size: 38, iconSize: 19),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Fmt.displayDate(data.listDate, locale: context.localeName),
                                    style: t.textTheme.titleMedium,
                                  ),
                                  if (data.observedFrom != null)
                                    Text(
                                      l.passedOverRecordedSince(
                                        Fmt.time(data.observedFrom, locale: context.localeName),
                                      ),
                                      style: muted,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          l.passedOverIntro,
                          style: t.textTheme.bodyMedium?.copyWith(color: context.tokens.textSecondary),
                        ),
                        if (data.total > 0) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            l.passedOverSummary(data.total, data.pending),
                            key: const Key('passedOverSummary'),
                            style: t.textTheme.titleSmall?.copyWith(color: t.colorScheme.primary),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (data.isToday && data.boardStale == true)
                  InfoBanner(
                    key: const Key('passedOverBoardStale'),
                    color: context.tokens.warning,
                    icon: AppIcons.warning,
                    text: l.passedOverBoardStale,
                  ),
                if (data.availableDates.length > 1)
                  ChipStrip(
                    padding: EdgeInsets.fromLTRB(
                      AppLayout.gutter(context),
                      AppSpacing.sm,
                      AppLayout.gutter(context),
                      0,
                    ),
                    children: [
                      for (final d in data.availableDates)
                        ChoiceChip(
                          label: Text(Fmt.shortDate(d, locale: context.localeName)),
                          selected: d == data.listDate,
                          onSelected: (_) => setState(() => _date = d),
                        ),
                    ],
                  ),
                if (data.courts.isEmpty)
                  EmptyState(message: l.passedOverNone, icon: AppIcons.factCheck)
                else
                  for (final c in data.courts) _CourtSection(court: c),
                Padding(
                  padding: AppLayout.page(context, top: AppSpacing.lg, bottom: AppSpacing.xxl),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(AppIcons.info, size: 14, color: context.tokens.textTertiary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(l.passedOverNote, style: muted?.copyWith(color: context.tokens.textTertiary)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CourtSection extends StatelessWidget {
  const _CourtSection({required this.court});
  final PassedOverCourt court;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context);
    final header = [
      l.court(court.courtNo),
      if (court.coram != null) court.coram!,
      if (court.currentItem != null) l.passedOverNowAt(court.currentItem!),
    ].join(' · ');
    return Padding(
      key: Key('passedOverCourt-${court.courtNo}'),
      padding: AppLayout.page(context, top: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Row(
              children: [
                Icon(AppIcons.court, size: 16, color: context.tokens.goldText),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(header, style: t.textTheme.titleSmall?.copyWith(color: t.colorScheme.primary)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md - 2),
          for (final e in court.items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md - 2),
              child: _entry(context, e),
            ),
        ],
      ),
    );
  }

  Widget _entry(BuildContext context, PassedOverEntry e) {
    final l = context.l10n;
    final chip = switch (e.status) {
      'pending' => StatusChip(l.passedOverPending, color: AppColors.warning, icon: AppIcons.pending),
      'no_longer_pending' => StatusChip(l.passedOverNoLongerPending, color: AppColors.success, icon: AppIcons.check),
      _ => StatusChip(l.passedOverOffBoard, color: AppColors.muted, icon: AppIcons.offBoard),
    };
    final kept = Text(l.passedOverKeptAt(Fmt.time(e.firstSeenAt, locale: context.localeName)));
    final it = e.listing;
    if (it == null) {
      final t = Theme.of(context);
      return AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              constraints: const BoxConstraints(minWidth: 46),
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(e.itemNo, style: t.textTheme.titleSmall?.copyWith(color: AppColors.gold)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.passedOverItemNotFound(e.itemNo), style: t.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  DefaultTextStyle.merge(style: t.textTheme.bodySmall, child: kept),
                  const SizedBox(height: 8),
                  chip,
                ],
              ),
            ),
          ],
        ),
      );
    }
    return CaseCard(
      itemNo: e.itemNo,
      caseNumber: it.caseNumber,
      petitioner: it.petitioner,
      respondent: it.respondent,
      subtitle: [
        l.passedOverKeptAt(Fmt.time(e.firstSeenAt, locale: context.localeName)),
        if (it.stage != null) it.stage!,
      ].join(' · '),
      advocates: [...it.petitionerAdvocates, ...it.respondentAdvocates],
      badges: [chip],
      onTap: () => openCase(context, caseId: it.caseId, caseNumber: it.caseNumber),
    );
  }
}
