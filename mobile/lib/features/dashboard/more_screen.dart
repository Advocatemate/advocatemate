import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/widgets/widgets.dart';
import '../../theme/app_theme.dart';
import '../authentication/session_controller.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = Theme.of(context);
    final me = ref.watch(currentMeProvider);
    final name = me?.displayName ?? me?.advocateName ?? '';
    MenuRow row(IconData i, String label, String route) =>
        MenuRow(icon: i, label: label, onTap: () => context.push(route));
    return Scaffold(
      appBar: AppBar(title: Text(l.navMore)),
      body: ListView(
        padding: AppLayout.page(context, top: AppSpacing.sm, bottom: AppSpacing.xxl),
        children: [
          AppCard(
            onTap: () => context.push('/profile'),
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 14, AppSpacing.md, 14),
            child: Row(
              children: [
                AvatarInitials(name: name, size: 52),
                const SizedBox(width: AppSpacing.md + 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty ? '-' : name,
                        style: t.textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text('${l.advocateCode}: ${me?.advocateCode ?? '-'}', style: t.textTheme.bodySmall),
                    ],
                  ),
                ),
                Icon(AppIcons.chevronRight, size: 18, color: context.tokens.textTertiary),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg + 4),
          SectionHeader(l.sectionCauseLists),
          MenuGroup(
            children: [
              row(AppIcons.daily, l.dailyCauseList, '/cause-list/daily'),
              row(AppIcons.weekly, l.weeklyCauseList, '/cause-list/weekly'),
              row(AppIcons.supplementary, l.supplementaryCauseList, '/cause-list/supplementary'),
              row(AppIcons.passedOver, l.passedOverList, '/cause-list/passed-over'),
              row(AppIcons.liveBoard, l.liveCourts, '/live'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg + 4),
          SectionHeader(l.sectionAccount),
          MenuGroup(
            children: [
              row(AppIcons.profile, l.profile, '/profile'),
              row(AppIcons.notifications, l.notifications, '/notifications'),
              row(AppIcons.settings, l.settings, '/settings'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          MenuGroup(
            children: [
              MenuRow(
                icon: AppIcons.switchAccount,
                label: l.switchGoogleAccount,
                trailing: const SizedBox.shrink(),
                onTap: () => ref.read(sessionProvider.notifier).useDifferentAccount(),
              ),
              MenuRow(
                icon: AppIcons.logout,
                label: l.logout,
                destructive: true,
                trailing: const SizedBox.shrink(),
                onTap: () => ref.read(sessionProvider.notifier).logout(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg + 4),
          Text(
            l.dataNotice,
            textAlign: TextAlign.center,
            style: t.textTheme.bodySmall?.copyWith(color: context.tokens.textTertiary),
          ),
        ],
      ),
    );
  }
}
