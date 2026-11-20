import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/widgets/widgets.dart';
import '../authentication/session_controller.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    Widget tile(IconData i, String label, String route) =>
        ListTile(leading: Icon(i), title: Text(label), trailing: const Icon(Icons.chevron_right), onTap: () => context.push(route));
    return Scaffold(
      appBar: AppBar(title: Text(l.navMore)),
      body: ListView(children: [
        tile(Icons.person_outline, l.profile, '/profile'),
        tile(Icons.today_outlined, l.dailyCauseList, '/cause-list/daily'),
        tile(Icons.date_range_outlined, l.weeklyCauseList, '/cause-list/weekly'),
        tile(Icons.playlist_add_outlined, l.supplementaryCauseList, '/cause-list/supplementary'),
        tile(Icons.low_priority, l.passedOverList, '/cause-list/passed-over'),
        tile(Icons.live_tv_outlined, l.liveCourts, '/live'),
        tile(Icons.notifications_outlined, l.notifications, '/notifications'),
        tile(Icons.settings_outlined, l.settings, '/settings'),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.switch_account_outlined),
          title: Text(l.switchGoogleAccount),
          onTap: () => ref.read(sessionProvider.notifier).useDifferentAccount(),
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: Text(l.logout),
          onTap: () => ref.read(sessionProvider.notifier).logout(),
        ),
        Padding(padding: const EdgeInsets.all(16), child: Text(l.dataNotice, style: Theme.of(context).textTheme.bodySmall)),
      ]),
    );
  }
}
