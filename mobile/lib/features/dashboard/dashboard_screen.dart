import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/formatters.dart';
import '../../core/loaded.dart';
import '../../shared/court_repository.dart';
import '../../shared/models/models.dart';
import '../../shared/personal_repository.dart';
import '../../shared/widgets/widgets.dart';
import '../../theme/app_theme.dart';
import '../authentication/session_controller.dart';
import '../my_cause_list/my_cause_list_screen.dart';

final publicationStatusProvider =
    FutureProvider.autoDispose<Loaded<PublicationStatus>>((ref) => ref.watch(courtRepositoryProvider).publicationStatus());

final unreadCountProvider = FutureProvider.autoDispose<int>(
    (ref) async => (await ref.watch(personalRepositoryProvider).notifications(unreadOnly: true)).unreadCount);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final me = ref.watch(currentMeProvider);
    final t = Theme.of(context);
    final today = DateTime.now();
    final code = me?.advocateCode;
    final myList = code == null ? null : ref.watch(advocateCauseListProvider((code: code, date: Fmt.isoDate(today))));
    final unread = ref.watch(unreadCountProvider).value ?? 0;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(publicationStatusProvider);
          ref.invalidate(unreadCountProvider);
          if (code != null) ref.invalidate(advocateCauseListProvider((code: code, date: Fmt.isoDate(today))));
        },
        child: CustomScrollView(slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 168,
            actions: [
              IconButton(
                tooltip: l.notifications,
                onPressed: () => context.push('/notifications'),
                icon: Badge(isLabelVisible: unread > 0, label: Text('$unread'), child: const Icon(Icons.notifications_outlined)),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: t.appBarTheme.backgroundColor,
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 72, AppSpacing.xl, AppSpacing.lg),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.welcome(me?.displayName ?? me?.advocateName ?? ''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.textTheme.titleLarge?.copyWith(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('${l.advocateCode}: ${code ?? '-'}', style: const TextStyle(color: AppColors.gold)),
                  Text(Fmt.displayDate(today, locale: context.localeName), style: const TextStyle(color: Color(0xFFCAD3E2))),
                ]),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList.list(children: [
              _MyListSummary(value: myList),
              const SizedBox(height: AppSpacing.lg),
              const _PublicationCard(),
              const SizedBox(height: AppSpacing.lg),
              GridView.count(
                crossAxisCount: MediaQuery.sizeOf(context).width > 600 ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.45,
                children: [
                  _Tile(Icons.today_outlined, l.dailyCauseList, () => context.push('/cause-list/daily')),
                  _Tile(Icons.date_range_outlined, l.weeklyCauseList, () => context.push('/cause-list/weekly')),
                  _Tile(Icons.playlist_add_outlined, l.supplementaryCauseList, () => context.push('/cause-list/supplementary')),
                  _Tile(Icons.low_priority, l.passedOverList, () => context.push('/cause-list/passed-over')),
                  _Tile(Icons.live_tv_outlined, l.liveCourts, () => context.push('/live')),
                  _Tile(Icons.search, l.searchCases, () => context.go('/search')),
                  _Tile(Icons.people_outline, l.favouriteAdvocates, () => context.go('/saved')),
                  _Tile(Icons.bookmark_border, l.favouriteCases, () => context.go('/saved')),
                  _Tile(Icons.notifications_outlined, l.notifications, () => context.push('/notifications')),
                ],
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _MyListSummary extends StatelessWidget {
  const _MyListSummary({required this.value});
  final AsyncValue<Loaded<AdvocateCauseList>>? value;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context);
    final v = value;
    Widget body;
    if (v == null) {
      body = Text(l.notYetAvailable);
    } else {
      body = switch (v) {
        AsyncData(:final value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.casesCount(value.data.totalCases), style: t.textTheme.headlineSmall),
            if (value.data.courts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Wrap(spacing: 6, runSpacing: 6, children: [
                  for (final c in value.data.courts) StatusChip('${l.court(c.courtNo)} · ${c.cases.length}'),
                ]),
              ),
            if (!value.data.dateOfferedBySource) Text(l.dateNotOffered, style: t.textTheme.bodySmall),
            if (!value.isCurrent) Text(l.offlineBanner, style: const TextStyle(color: AppColors.warning, fontSize: 12)),
          ]),
        AsyncError() => Text(l.errorGeneric),
        _ => const LinearProgressIndicator(),
      };
    }
    return SectionCard(
      title: '${l.myCauseList} · ${l.today}',
      trailing: TextButton(onPressed: () => context.go('/my-list'), child: Text(l.continueAction)),
      child: body,
    );
  }
}

class _PublicationCard extends ConsumerWidget {
  const _PublicationCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final status = ref.watch(publicationStatusProvider);
    return SectionCard(
      title: l.publicationStatus,
      child: switch (status) {
        AsyncData(:final value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(Fmt.displayDate(value.data.listDate, locale: context.localeName),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final e in value.data.summary.entries)
                StatusChip('${e.key} · ${e.value}', color: e.key == 'UPLOADED' ? AppColors.success : AppColors.muted),
            ]),
            if (!value.isCurrent) ...[
              const SizedBox(height: 6),
              Text(l.staleBanner, style: const TextStyle(color: AppColors.warning, fontSize: 12)),
            ],
          ]),
        AsyncError() => Text(l.notYetAvailable),
        _ => const LinearProgressIndicator(),
      },
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.icon, this.label, this.onTap);
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Icon(icon, color: AppColors.gold, size: 28),
            Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, style: t.textTheme.titleSmall),
          ]),
        ),
      ),
    );
  }
}
