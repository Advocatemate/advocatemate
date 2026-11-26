import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/widgets/widgets.dart';
import '../../theme/app_theme.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: shell,
      bottomNavigationBar: AppBottomNav(
        selectedIndex: shell.currentIndex,
        onSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        items: [
          (AppIcons.home, l.navHome),
          (AppIcons.myList, l.navMyCauseList),
          (AppIcons.search, l.navSearch),
          (AppIcons.saved, l.navFavourites),
          (AppIcons.more, l.navMore),
        ],
      ),
    );
  }
}

/// White bottom navigation with a hairline top edge; the selected item sits on a soft gold pill.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.selectedIndex, required this.onSelected, required this.items});
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<(IconData, String)> items;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        border: Border(top: BorderSide(color: context.tokens.cardBorder)),
        boxShadow: t.brightness == Brightness.light
            ? const [BoxShadow(color: Color(0x0D0B1930), blurRadius: 16, offset: Offset(0, -4))]
            : null,
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        destinations: [for (final (icon, label) in items) NavigationDestination(icon: Icon(icon), label: label)],
      ),
    );
  }
}
