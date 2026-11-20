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
      appBar: AppBar(title: Text(l.passedOverList), actions: [
        IconButton(
          tooltip: l.refresh,
          icon: const Icon(Icons.refresh),
          onPressed: () => ref.invalidate(passedOverProvider(_date)),
        ),
      ]),
      body: AsyncBody<Loaded<PassedOverList>>(
        value: value,
        onRetry: () => ref.invalidate(passedOverProvider(_date)),
        builder: (loaded) {
          final data = loaded.data;
          final t = Theme.of(context);
          final muted = t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurface.withValues(alpha: .65));
          return RefreshIndicator(
            onRefresh: () => refreshProvider(ref, passedOverProvider(_date)),
            child: ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
              FreshnessBanner(loaded),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(Fmt.displayDate(data.listDate, locale: context.localeName), style: t.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(l.passedOverIntro, style: t.textTheme.bodyMedium),
                  if (data.observedFrom != null)
                    Text(l.passedOverRecordedSince(Fmt.time(data.observedFrom, locale: context.localeName)), style: muted),
                  if (data.total > 0) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(l.passedOverSummary(data.total, data.pending),
                        key: const Key('passedOverSummary'), style: t.textTheme.titleSmall),
                  ],
                ]),
              ),
              if (data.isToday && data.boardStale == true)
                Container(
                  key: const Key('passedOverBoardStale'),
                  margin: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
                  child: Text(l.passedOverBoardStale,
                      style: t.textTheme.bodySmall?.copyWith(color: AppColors.warning, fontWeight: FontWeight.w600)),
                ),
              if (data.availableDates.length > 1)
                SizedBox(
                  height: 52,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
                    children: [
                      for (final d in data.availableDates)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(Fmt.shortDate(d, locale: context.localeName)),
                            selected: d == data.listDate,
                            onSelected: (_) => setState(() => _date = d),
                          ),
                        ),
                    ],
                  ),
                ),
              if (data.courts.isEmpty)
                EmptyState(message: l.passedOverNone, icon: Icons.fact_check_outlined)
              else
                for (final c in data.courts) _CourtSection(court: c),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl),
                child: Text(l.passedOverNote, style: muted),
              ),
            ]),
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
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(header, style: t.textTheme.titleSmall?.copyWith(color: AppColors.navy)),
        const SizedBox(height: AppSpacing.sm),
        for (final e in court.items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _entry(context, e),
          ),
      ]),
    );
  }

  Widget _entry(BuildContext context, PassedOverEntry e) {
    final l = context.l10n;
    final chip = switch (e.status) {
      'pending' => StatusChip(l.passedOverPending, color: AppColors.warning, icon: Icons.schedule),
      'no_longer_pending' => StatusChip(l.passedOverNoLongerPending, color: AppColors.success, icon: Icons.check),
      _ => StatusChip(l.passedOverOffBoard, color: AppColors.muted, icon: Icons.remove_circle_outline),
    };
    final kept = Text(l.passedOverKeptAt(Fmt.time(e.firstSeenAt, locale: context.localeName)));
    final it = e.listing;
    if (it == null) {
      return Card(
        child: ListTile(
          leading: CircleAvatar(backgroundColor: AppColors.navy, foregroundColor: AppColors.gold, child: Text(e.itemNo)),
          title: Text(l.passedOverItemNotFound(e.itemNo)),
          subtitle: kept,
          trailing: chip,
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
