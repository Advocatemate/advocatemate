import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/widgets/cause_list_browser.dart';
import '../../shared/widgets/widgets.dart';

/// Weekly cause list (APHC list type "W") with the official weekly PDF.
class WeeklyCauseListScreen extends StatelessWidget {
  const WeeklyCauseListScreen({super.key, this.initialDate});
  final DateTime? initialDate;

  @override
  Widget build(BuildContext context) => CauseListBrowser(
    listType: 'W',
    title: context.l10n.weeklyCauseList,
    initialDate: initialDate,
    actions: [
      IconButton(
        tooltip: context.l10n.weeklyPdf,
        icon: const Icon(AppIcons.pdf),
        onPressed: () => context.push('/pdf?kind=weekly'),
      ),
    ],
  );
}
