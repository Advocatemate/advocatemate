import 'package:flutter/services.dart' show SystemUiOverlayStyle;
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
    final today = DateTime.now();
    final code = me?.advocateCode;
    final myList = code == null ? null : ref.watch(advocateCauseListProvider((code: code, date: Fmt.isoDate(today))));
    final unread = ref.watch(unreadCountProvider).value ?? 0;
    final g = AppLayout.gutter(context);
    final wide = MediaQuery.sizeOf(context).width > 600;
    final textScale = (MediaQuery.textScalerOf(context).scale(14) / 14).clamp(1.0, 1.6);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(publicationStatusProvider);
            ref.invalidate(unreadCountProvider);
            if (code != null) ref.invalidate(advocateCauseListProvider((code: code, date: Fmt.isoDate(today))));
          },
          child: CustomScrollView(
            slivers: [
              // Hero and the two summary cards share one box: a viewport paints earlier slivers on top,
              // so cards that overlap the hero must be later children of the same Column instead.
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Hero(name: me?.displayName ?? me?.advocateName ?? '', code: code, unread: unread, today: today),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: g),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, -44),
                            child: FadeSlideIn(child: _MyListSummary(value: myList)),
                          ),
                          Transform.translate(
                            offset: const Offset(0, -28),
                            child: const FadeSlideIn(order: 1, child: _PublicationCard()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(g, 0, g, AppSpacing.xl),
                sliver: SliverList.list(
                  children: [
                    FadeSlideIn(
                      order: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SectionHeader(l.quickAccess),
                          GridView.count(
                            crossAxisCount: wide ? 4 : 2,
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: AppSpacing.md,
                            crossAxisSpacing: AppSpacing.md,
                            childAspectRatio: (wide ? 1.2 : 1.42) / textScale,
                            children: [
                              _QuickTile(AppIcons.daily, l.dailyCauseList, () => context.push('/cause-list/daily')),
                              _QuickTile(AppIcons.weekly, l.weeklyCauseList, () => context.push('/cause-list/weekly')),
                              _QuickTile(
                                AppIcons.supplementary,
                                l.supplementaryCauseList,
                                () => context.push('/cause-list/supplementary'),
                              ),
                              _QuickTile(AppIcons.liveBoard, l.liveCourts, () => context.push('/live'), accent: true),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FadeSlideIn(
                      order: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SectionHeader(l.shortcuts),
                          MenuGroup(
                            children: [
                              MenuRow(
                                icon: AppIcons.passedOver,
                                label: l.passedOverList,
                                onTap: () => context.push('/cause-list/passed-over'),
                              ),
                              MenuRow(icon: AppIcons.search, label: l.searchCases, onTap: () => context.go('/search')),
                              MenuRow(
                                icon: AppIcons.advocates,
                                label: l.favouriteAdvocates,
                                onTap: () => context.go('/saved'),
                              ),
                              MenuRow(icon: AppIcons.saved, label: l.favouriteCases, onTap: () => context.go('/saved')),
                              MenuRow(
                                icon: AppIcons.notifications,
                                label: l.notifications,
                                onTap: () => context.push('/notifications'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _greeting(BuildContext context, DateTime now) {
  final l = context.l10n;
  if (now.hour < 12) return l.greetingMorning;
  if (now.hour < 17) return l.greetingAfternoon;
  return l.greetingEvening;
}

/// Navy header: avatar, notifications, greeting, advocate name, code and date.
class _Hero extends StatelessWidget {
  const _Hero({required this.name, required this.code, required this.unread, required this.today});
  final String name;
  final String? code;
  final int unread;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context);
    final tk = context.tokens;
    final g = AppLayout.gutter(context);
    const soft = Color(0xFFC9D2E0);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [tk.heroTop, tk.heroBottom],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppSpacing.radiusLg + 4)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(g, AppSpacing.md, g, 64),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Semantics(
                    button: true,
                    label: l.profile,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => context.push('/profile'),
                      child: AvatarInitials(name: name, size: 46, onDark: true),
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: Colors.white.withValues(alpha: .08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.white.withValues(alpha: .12)),
                    ),
                    child: IconButton(
                      tooltip: l.notifications,
                      onPressed: () => context.push('/notifications'),
                      icon: Badge(
                        isLabelVisible: unread > 0,
                        label: Text('$unread'),
                        child: const Icon(AppIcons.notifications, color: Colors.white, size: AppIcons.sizeMd),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                _greeting(context, today),
                style: t.textTheme.labelLarge?.copyWith(color: AppColors.gold, letterSpacing: .3),
              ),
              const SizedBox(height: 4),
              Text(
                l.welcome(name),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: t.textTheme.headlineSmall?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gold.withValues(alpha: .45)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(AppIcons.advocateCode, size: 14, color: AppColors.gold),
                        const SizedBox(width: 6),
                        Text(
                          '${l.advocateCode}: ${code ?? '-'}',
                          style: t.textTheme.labelMedium?.copyWith(color: AppColors.goldSoft),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(AppIcons.calendar, size: 14, color: soft),
                      const SizedBox(width: 6),
                      Text(
                        Fmt.displayDate(today, locale: context.localeName),
                        style: t.textTheme.labelMedium?.copyWith(color: soft, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
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
    final tk = context.tokens;
    final muted = t.textTheme.bodyMedium?.copyWith(color: tk.textSecondary);
    final v = value;
    final Widget body;
    if (v == null) {
      body = Text(l.notYetAvailable, style: muted);
    } else {
      body = switch (v) {
        AsyncData(:final value) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.casesCount(value.data.totalCases),
              style: t.textTheme.headlineMedium?.copyWith(color: t.colorScheme.primary),
            ),
            if (value.data.courts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final c in value.data.courts)
                      StatusChip('${l.court(c.courtNo)} · ${c.cases.length}', icon: AppIcons.court),
                  ],
                ),
              ),
            if (!value.data.dateOfferedBySource)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(l.dateNotOffered, style: t.textTheme.bodySmall),
              ),
            if (!value.isCurrent)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(l.offlineBanner, style: t.textTheme.bodySmall?.copyWith(color: tk.warning)),
              ),
          ],
        ),
        AsyncError() => Text(l.errorGeneric, style: muted),
        _ => const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: LinearProgressIndicator(),
        ),
      };
    }
    return AppCard(
      onTap: () => context.go('/my-list'),
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.sm, AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(AppIcons.cases, size: 36, iconSize: 18, background: tk.goldSoft, color: tk.onGoldSoft),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Semantics(header: true, child: Text(l.todaysCauseList, style: t.textTheme.titleMedium)),
              ),
              TextButton(onPressed: () => context.go('/my-list'), child: Text(l.viewMyList)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md, right: AppSpacing.sm),
            child: body,
          ),
        ],
      ),
    );
  }
}

class _PublicationCard extends ConsumerWidget {
  const _PublicationCard();

  static Color _tone(String key) {
    final k = key.toUpperCase();
    if (k == 'UPLOADED') return AppColors.success;
    if (k.contains('LEAVE')) return AppColors.warning;
    return AppColors.muted;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = Theme.of(context);
    final tk = context.tokens;
    final status = ref.watch(publicationStatusProvider);
    final listDate = status.value?.data.listDate;

    final Widget body = switch (status) {
      AsyncData(:final value) => () {
        final summary = value.data.summary;
        final total = summary.values.fold<int>(0, (a, b) => a + b);
        final uploaded = summary.entries
            .where((e) => e.key.toUpperCase() == 'UPLOADED')
            .fold<int>(0, (a, e) => a + e.value);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (total > 0) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: uploaded / total,
                  minHeight: 6,
                  color: tk.success,
                  backgroundColor: tk.subtleFill,
                ),
              ),
              const SizedBox(height: 6),
              Text(l.courtsUploaded(uploaded, total), style: t.textTheme.bodySmall),
              const SizedBox(height: AppSpacing.md),
            ],
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [for (final e in summary.entries) StatusChip('${e.key} · ${e.value}', color: _tone(e.key))],
            ),
            if (!value.isCurrent) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(l.staleBanner, style: t.textTheme.bodySmall?.copyWith(color: tk.warning)),
            ],
          ],
        );
      }(),
      AsyncError() => Text(l.notYetAvailable, style: t.textTheme.bodyMedium?.copyWith(color: tk.textSecondary)),
      _ => const LinearProgressIndicator(),
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBadge(AppIcons.publication, size: 36, iconSize: 18),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(header: true, child: Text(l.publicationStatus, style: t.textTheme.titleMedium)),
                    if (listDate != null)
                      Text(Fmt.displayDate(listDate, locale: context.localeName), style: t.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          body,
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile(this.icon, this.label, this.onTap, {this.accent = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final tk = context.tokens;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconBadge(
                icon,
                size: 42,
                iconSize: 21,
                background: accent ? tk.goldSoft : tk.subtleFill,
                color: accent ? tk.onGoldSoft : t.colorScheme.primary,
              ),
              const Spacer(),
              Icon(AppIcons.chevronRight, size: 16, color: tk.textTertiary),
            ],
          ),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: t.textTheme.titleSmall?.copyWith(height: 1.25),
          ),
        ],
      ),
    );
  }
}
