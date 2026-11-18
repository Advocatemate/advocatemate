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
      'cause_list_publication' => Icons.campaign_outlined,
      'favourite_advocate' => Icons.person_outline,
      'case_update' => Icons.gavel_outlined,
      'court_board' => Icons.live_tv_outlined,
      'enrichment' => Icons.fact_check_outlined,
      _ => Icons.notifications_outlined,
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
    return Scaffold(
      appBar: AppBar(title: Text(l.notifications), actions: [
        TextButton(
          onPressed: () async {
            await ref.read(personalRepositoryProvider).markRead(all: true);
            ref.invalidate(notificationsProvider);
            ref.invalidate(unreadCountProvider);
          },
          child: Text(l.markAllRead, style: const TextStyle(color: Colors.white)),
        ),
      ]),
      body: AsyncBody<NotificationPage>(
        value: ref.watch(notificationsProvider),
        onRetry: () => ref.invalidate(notificationsProvider),
        builder: (page) => RefreshIndicator(
          onRefresh: () => refreshProvider(ref, notificationsProvider),
          child: page.items.isEmpty
              ? ListView(children: [EmptyState(message: l.emptyNotifications, icon: Icons.notifications_none)])
              : ListView.separated(
                  itemCount: page.items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final n = page.items[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: n.read ? Theme.of(context).colorScheme.surfaceContainerHighest : AppColors.goldSoft,
                        child: Icon(_icon(n.category), color: AppColors.navy),
                      ),
                      title: Text(n.title, style: TextStyle(fontWeight: n.read ? FontWeight.w400 : FontWeight.w700)),
                      subtitle: Text('${n.body}\n${Fmt.timestamp(n.createdAt, locale: context.localeName)}'),
                      isThreeLine: true,
                      onTap: () => _open(context, ref, n),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
