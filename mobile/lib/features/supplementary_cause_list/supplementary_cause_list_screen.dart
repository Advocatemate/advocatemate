import 'package:material_ui/material_ui.dart';

import '../../shared/widgets/cause_list_browser.dart';
import '../../shared/widgets/widgets.dart';

/// Supplementary cause list (APHC list type "S").
class SupplementaryCauseListScreen extends StatelessWidget {
  const SupplementaryCauseListScreen({super.key, this.initialDate});
  final DateTime? initialDate;

  @override
  Widget build(BuildContext context) =>
      CauseListBrowser(listType: 'S', title: context.l10n.supplementaryCauseList, initialDate: initialDate);
}
