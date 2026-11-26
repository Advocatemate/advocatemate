import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/formatters.dart';
import '../../core/loaded.dart';
import '../../shared/court_repository.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';
import '../../theme/app_theme.dart';
import '../settings/app_settings.dart';

final liveBoardProvider = FutureProvider.autoDispose<Loaded<LiveBoard>>((ref) => ref.watch(courtRepositoryProvider).liveBoard());

/// The app only reads the backend's snapshot; the backend alone polls APHC.
class LiveCourtsScreen extends ConsumerStatefulWidget {
  const LiveCourtsScreen({super.key, this.refreshInterval = const Duration(seconds: 45)});
  final Duration refreshInterval;

  @override
  ConsumerState<LiveCourtsScreen> createState() => _LiveCourtsScreenState();
}

class _LiveCourtsScreenState extends ConsumerState<LiveCourtsScreen> {
  Timer? _timer;
  String? _court;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.refreshInterval, (_) {
      if (ref.read(appSettingsProvider).liveAutoRefresh) ref.invalidate(liveBoardProvider);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context);
    final tk = context.tokens;
    final settings = ref.watch(appSettingsProvider);
    final value = ref.watch(liveBoardProvider);
    final textScale = (MediaQuery.textScalerOf(context).scale(14) / 14).clamp(1.0, 1.6);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.liveCourts),
        actions: [
          IconButton(
            tooltip: l.refresh,
            icon: const Icon(AppIcons.refresh),
            onPressed: () => ref.invalidate(liveBoardProvider),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: AsyncBody<Loaded<LiveBoard>>(
        value: value,
        onRetry: () => ref.invalidate(liveBoardProvider),
        builder: (loaded) {
          final b = loaded.data;
          final current = b.isCurrent && !b.stale && !loaded.fromCache;
          final courts = _court == null ? b.courts : b.courts.where((c) => c.courtNo == _court).toList();
          return RefreshIndicator(
            onRefresh: () => refreshProvider(ref, liveBoardProvider),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (!current)
                  InfoBanner(
                    key: const Key('liveStaleBanner'),
                    color: tk.danger,
                    icon: AppIcons.warning,
                    text: b.note ?? l.liveStaleBanner,
                  ),
                Padding(
                  padding: AppLayout.page(context, top: AppSpacing.md),
                  child: AppCard(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.sm, AppSpacing.md),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            StatusChip(
                              current ? l.liveCurrent : l.liveNotCurrent,
                              color: current ? AppColors.success : AppColors.danger,
                              icon: current ? AppIcons.liveDot : AppIcons.stale,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l.lastUpdated(Fmt.timestamp(b.fetchedAt, locale: context.localeName)),
                                style: t.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Divider(height: 1),
                        Row(
                          children: [
                            Icon(AppIcons.sync, size: 16, color: tk.textSecondary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l.autoRefresh,
                                style: t.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ),
                            Switch(
                              value: settings.liveAutoRefresh,
                              onChanged: (v) => ref.read(appSettingsProvider.notifier).setLiveAutoRefresh(v),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (b.courts.length > 1)
                  Padding(
                    padding: AppLayout.page(context, top: AppSpacing.xs),
                    child: ChipStrip(
                      children: [
                        ChoiceChip(
                          key: const Key('filterAll'),
                          label: Text(l.filterAll),
                          selected: _court == null,
                          onSelected: (_) => setState(() => _court = null),
                        ),
                        for (final c in b.courts)
                          ChoiceChip(
                            label: Text(c.courtNo),
                            selected: _court == c.courtNo,
                            onSelected: (_) => setState(() => _court = c.courtNo),
                          ),
                      ],
                    ),
                  ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: AppLayout.page(context, top: AppSpacing.md, bottom: AppSpacing.md),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 136 * textScale,
                  ),
                  itemCount: courts.length,
                  itemBuilder: (_, i) => _CourtTile(court: courts[i], current: current),
                ),
                if (b.source != null)
                  Padding(
                    padding: AppLayout.page(context, bottom: AppSpacing.xl),
                    child: Text(l.source(b.source!), style: t.textTheme.bodySmall?.copyWith(color: tk.textTertiary)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CourtTile extends StatelessWidget {
  const _CourtTile({required this.court, required this.current});
  final BoardCourt court;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context);
    final tk = context.tokens;
    final active = court.state == 'in_progress';
    final stateText = switch (court.state) {
      'not_in_session' => l.notInSession,
      'session_started' => l.sessionStarted,
      _ => l.currentItem,
    };
    final dot = !current
        ? tk.textTertiary
        : (active ? tk.success : (court.state == 'session_started' ? tk.warning : tk.textTertiary));
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Semantics(
        label: '${l.court(court.courtNo)}, $stateText ${court.currentItem ?? ''}${current ? '' : ', ${l.liveNotCurrent}'}',
        excludeSemantics: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(AppIcons.court, size: 14, color: tk.goldText),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(l.court(court.courtNo), style: t.textTheme.titleSmall, overflow: TextOverflow.ellipsis),
                ),
                if (court.coram != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: tk.goldSoft, borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      court.coram!,
                      style: t.textTheme.labelSmall?.copyWith(color: tk.onGoldSoft, letterSpacing: .3),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(stateText, style: t.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            if (active)
              Text(
                court.currentItem ?? '-',
                style: t.textTheme.headlineMedium?.copyWith(
                  color: current ? t.colorScheme.primary : t.colorScheme.onSurface.withValues(alpha: .4),
                  height: 1.15,
                ),
              ),
            if (court.keptBack != null)
              Text(
                '${l.keptBack}: ${court.keptBack}',
                style: t.textTheme.labelSmall?.copyWith(color: tk.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
