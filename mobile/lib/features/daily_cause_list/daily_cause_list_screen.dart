import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/widgets/cause_list_browser.dart';
import '../../shared/widgets/widgets.dart';

/// Daily cause list (APHC list type "D").
class DailyCauseListScreen extends StatelessWidget {
  const DailyCauseListScreen({super.key, this.initialDate});
  final DateTime? initialDate;

  @override
  Widget build(BuildContext context) => CauseListBrowser(
        listType: 'D',
        title: context.l10n.dailyCauseList,
        initialDate: initialDate,
        actions: [
          IconButton(
            key: const Key('openPassedOver'),
            tooltip: context.l10n.passedOverList,
            icon: const Icon(Icons.low_priority),
            onPressed: () => context.push('/cause-list/passed-over'),
          ),
        ],
      );
}
