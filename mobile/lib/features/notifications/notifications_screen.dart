import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/formatters.dart';
import '../../routing/app_router.dart';
import '../../shared/models/models.dart';
import '../../shared/personal_repository.dart';
import '../../shared/widgets/widgets.dart';
import '../../theme/app_theme.dart';
import '../dashboard/dashboard_screen.dart';

final notificationsProvider =
    FutureProvider.autoDispose<NotificationPage>((ref) => ref.watch(personalRepositoryProvider).notifications());

IconData _icon(String category) => switch (category) {
  'cause_list_publication' => AppIcons.publication,
  'favourite_advocate' => AppIcons.advocate,
  'case_update' => AppIcons.caseUpdate,
  'court_board' => AppIcons.liveBoard,
  'enrichment' => AppIcons.factCheck,
  _ => AppIcons.notifications,
};

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  Future<void> _open(BuildContext context, WidgetRef ref, AppNotification n) async {
    if (!n.read) {
      try {
        await ref.read(personalRepositoryProvider).markRead(ids: [n.id]);
      } catch (_) {}
      ref.invalidate(notificationsProvider);
      ref.invalidate(unreadCountProvider);
    }
    final loc = deepLinkToLocation(n.deepLink);
    if (loc != null && context.mounted) context.push(loc);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = Theme.of(context);
    final tk = context.tokens;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.notifications),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(personalRepositoryProvider).markRead(all: true);
              ref.invalidate(notificationsProvider);
              ref.invalidate(unreadCountProvider);
            },
            child: Text(l.markAllRead),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: AsyncBody<NotificationPage>(
        value: ref.watch(notificationsProvider),
        onRetry: () => ref.invalidate(notificationsProvider),
        builder: (page) => RefreshIndicator(
          onRefresh: () => refreshProvider(ref, notificationsProvider),
          child: page.items.isEmpty
              ? ListView(
                  children: [EmptyState(message: l.emptyNotifications, icon: AppIcons.notificationsOff)],
                )
              : ListView.separated(
                  padding: AppLayout.page(context, top: AppSpacing.md, bottom: AppSpacing.xxl),
                  itemCount: page.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md - 2),
                  itemBuilder: (_, i) {
                    final n = page.items[i];
                    return AppCard(
                      onTap: () => _open(context, ref, n),
                      color: n.read
                          ? null
                          : Color.alphaBlend(tk.goldSoft.withValues(alpha: .35), t.colorScheme.surface),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconBadge(
                            _icon(n.category),
                            size: 40,
                            iconSize: 19,
                            background: n.read ? tk.subtleFill : tk.goldSoft,
                            color: n.read ? t.colorScheme.primary : tk.onGoldSoft,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        n.title,
                                        style: t.textTheme.titleSmall?.copyWith(
                                          fontWeight: n.read ? FontWeight.w500 : FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    if (!n.read)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.only(left: 8, top: 5),
                                        decoration: BoxDecoration(color: tk.gold, shape: BoxShape.circle),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(n.body, style: t.textTheme.bodyMedium?.copyWith(color: tk.textSecondary)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(AppIcons.clock, size: 12, color: tk.textTertiary),
                                    const SizedBox(width: 5),
                                    Text(
                                      Fmt.timestamp(n.createdAt, locale: context.localeName),
                                      style: t.textTheme.bodySmall?.copyWith(color: tk.textTertiary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
