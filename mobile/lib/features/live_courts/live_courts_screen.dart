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
    final settings = ref.watch(appSettingsProvider);
    final value = ref.watch(liveBoardProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.liveCourts), actions: [
        IconButton(tooltip: l.refresh, icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(liveBoardProvider)),
      ]),
      body: AsyncBody<Loaded<LiveBoard>>(
        value: value,
        onRetry: () => ref.invalidate(liveBoardProvider),
        builder: (loaded) {
          final b = loaded.data;
          final current = b.isCurrent && !b.stale && !loaded.fromCache;
          final courts = _court == null ? b.courts : b.courts.where((c) => c.courtNo == _court).toList();
          return RefreshIndicator(
            onRefresh: () => refreshProvider(ref, liveBoardProvider),
            child: ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
              if (!current)
                Container(
                  key: const Key('liveStaleBanner'),
                  color: AppColors.danger.withValues(alpha: .1),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(b.note ?? l.liveStaleBanner,
                      style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
                child: Row(children: [
                  StatusChip(current ? l.liveCurrent : l.liveNotCurrent,
                      color: current ? AppColors.success : AppColors.danger,
                      icon: current ? Icons.circle : Icons.history),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(l.lastUpdated(Fmt.timestamp(b.fetchedAt, locale: context.localeName)),
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                ]),
              ),
              SwitchListTile(
                title: Text(l.autoRefresh),
                value: settings.liveAutoRefresh,
                onChanged: (v) => ref.read(appSettingsProvider.notifier).setLiveAutoRefresh(v),
              ),
              SizedBox(
                height: 48,
                child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(label: Text(l.filters), selected: _court == null, onSelected: (_) => setState(() => _court = null)),
                  ),
                  for (final c in b.courts)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                          label: Text(c.courtNo), selected: _court == c.courtNo, onSelected: (_) => setState(() => _court = c.courtNo)),
                    ),
                ]),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.25),
                itemCount: courts.length,
                itemBuilder: (_, i) => _CourtTile(court: courts[i], current: current),
              ),
              if (b.source != null)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(l.source(b.source!), style: Theme.of(context).textTheme.bodySmall),
                ),
            ]),
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
    final active = court.state == 'in_progress';
    final stateText = switch (court.state) {
      'not_in_session' => l.notInSession,
      'session_started' => l.sessionStarted,
      _ => l.currentItem,
    };
    return Card(
      child: Semantics(
        label: '${l.court(court.courtNo)}, $stateText ${court.currentItem ?? ''}${current ? '' : ', ${l.liveNotCurrent}'}',
        excludeSemantics: true,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(l.court(court.courtNo), style: t.textTheme.titleSmall),
              const Spacer(),
              if (court.coram != null) Text(court.coram!, style: t.textTheme.labelSmall?.copyWith(color: AppColors.gold)),
            ]),
            const Spacer(),
            Text(stateText, style: t.textTheme.bodySmall),
            if (active)
              Text(court.currentItem ?? '-',
                  style: t.textTheme.headlineSmall?.copyWith(
                      color: current ? t.colorScheme.primary : t.colorScheme.onSurface.withValues(alpha: .45))),
            if (court.keptBack != null) Text('${l.keptBack}: ${court.keptBack}', style: t.textTheme.labelSmall),
          ]),
        ),
      ),
    );
  }
}
