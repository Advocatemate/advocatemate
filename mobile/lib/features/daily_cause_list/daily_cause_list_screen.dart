import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/widgets/cause_list_browser.dart';
import '../../shared/widgets/widgets.dart';
import '../../theme/app_theme.dart';
import 'advocate_lookup_panel.dart';

enum DailyView { courtWise, advocateCode }

/// Daily cause list (APHC list type "D"): court-wise, or advocate code-wise for any advocate.
class DailyCauseListScreen extends StatefulWidget {
  const DailyCauseListScreen({super.key, this.initialDate, this.initialView = DailyView.courtWise, this.advocateCode});
  final DateTime? initialDate;
  final DailyView initialView;
  final String? advocateCode;

  @override
  State<DailyCauseListScreen> createState() => _DailyCauseListScreenState();
}

class _DailyCauseListScreenState extends State<DailyCauseListScreen> {
  late DailyView _view = widget.advocateCode != null ? DailyView.advocateCode : widget.initialView;

  Widget _switcher(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: AppLayout.page(context, top: AppSpacing.xs, bottom: AppSpacing.xs),
      child: SegmentedButton<DailyView>(
        key: const Key('dailyViewSwitch'),
        showSelectedIcon: false,
        expandedInsets: EdgeInsets.zero,
        segments: [
          ButtonSegment(value: DailyView.courtWise, label: Text(l.courtWise), icon: const Icon(AppIcons.court)),
          ButtonSegment(
            value: DailyView.advocateCode,
            label: Text(l.advocateCodeWise),
            icon: const Icon(AppIcons.advocateCode),
          ),
        ],
        selected: {_view},
        onSelectionChanged: (s) => setState(() => _view = s.first),
      ),
    );
  }

  Widget _passedOverAction(BuildContext context) => IconButton(
    key: const Key('openPassedOver'),
    tooltip: context.l10n.passedOverList,
    icon: const Icon(AppIcons.passedOver),
    onPressed: () => context.push('/cause-list/passed-over'),
  );

  @override
  Widget build(BuildContext context) {
    if (_view == DailyView.courtWise) {
      return CauseListBrowser(
        listType: 'D',
        title: context.l10n.dailyCauseList,
        initialDate: widget.initialDate,
        header: _switcher(context),
        actions: [_passedOverAction(context)],
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.dailyCauseList), actions: [_passedOverAction(context)]),
      body: Column(children: [
        _switcher(context),
        Expanded(child: AdvocateLookupPanel(initialCode: widget.advocateCode)),
      ]),
    );
  }
}
