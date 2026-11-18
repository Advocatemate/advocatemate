import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/widgets/widgets.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: l.navHome),
          NavigationDestination(
              icon: const Icon(Icons.event_note_outlined), selectedIcon: const Icon(Icons.event_note), label: l.navMyCauseList),
          NavigationDestination(icon: const Icon(Icons.search), label: l.navSearch),
          NavigationDestination(
              icon: const Icon(Icons.bookmark_border), selectedIcon: const Icon(Icons.bookmark), label: l.navFavourites),
          NavigationDestination(icon: const Icon(Icons.menu), label: l.navMore),
        ],
      ),
    );
  }
}
