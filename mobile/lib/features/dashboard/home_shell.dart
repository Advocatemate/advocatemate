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

/// White bottom bar with rounded top corners. The selected item sits on a navy tile with a white icon,
/// a bold navy label and a short gold bar underneath.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.selectedIndex, required this.onSelected, required this.items});
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<(IconData, String)> items;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: context.tokens.cardBorder)),
        boxShadow: t.brightness == Brightness.light
            ? const [BoxShadow(color: Color(0x140B1930), blurRadius: 20, offset: Offset(0, -6))]
            : null,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
          child: Row(
            children: [
              for (final (i, (icon, label)) in items.indexed)
                Expanded(
                  child: _NavItem(icon: icon, label: label, selected: i == selectedIndex, onTap: () => onSelected(i)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final tk = context.tokens;
    final light = t.brightness == Brightness.light;
    final active = light ? AppColors.navy : t.colorScheme.primary;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 54,
              height: 38,
              decoration: BoxDecoration(
                color: selected ? active : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 22,
                color: selected ? (light ? Colors.white : AppColors.navyDeep) : tk.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.textTheme.labelMedium?.copyWith(
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? active : tk.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: selected ? 28 : 0,
              height: 3,
              decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(2)),
            ),
          ],
        ),
      ),
    );
  }
}
