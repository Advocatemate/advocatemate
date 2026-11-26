import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/case_identity.dart';
import '../../core/formatters.dart';
import '../../shared/court_repository.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';
import '../../theme/app_theme.dart';
import '../my_cause_list/my_cause_list_screen.dart';

final searchHistoryProvider =
    FutureProvider.autoDispose<List<String>>((ref) => ref.watch(courtRepositoryProvider).searchHistory());

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _q = TextEditingController();
  final _party = TextEditingController();
  final _advocate = TextEditingController();
  final _type = TextEditingController();
  final _year = TextEditingController();
  bool _showFilters = false;
  bool _busy = false;
  Object? _error;
  SearchResponse? _result;
  List<String> _suggestions = const [];
  Timer? _debounce;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final initial = GoRouterState.of(context).uri.queryParameters['q'];
    if (initial != null && _q.text.isEmpty) {
      _q.text = initial;
      Future.microtask(_search);
    }
  }

  @override
  void dispose() {
    for (final c in [_q, _party, _advocate, _type, _year]) {
      c.dispose();
    }
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    if (v.trim().length < 2) {
      setState(() => _suggestions = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      try {
        final s = await ref.read(courtRepositoryProvider).suggestions(v.trim());
        if (mounted) setState(() => _suggestions = s);
      } catch (_) {}
    });
  }

  Future<void> _search() async {
    final q = _q.text.trim();
    final hasFilter = [_party, _advocate, _type, _year].any((c) => c.text.trim().isNotEmpty);
    if (q.isEmpty && !hasFilter) return;
    setState(() {
      _busy = true;
      _error = null;
      _suggestions = const [];
    });
    try {
      final r = await ref.read(courtRepositoryProvider).search(
            q: q.isEmpty ? null : q,
            party: _party.text.trim().isEmpty ? null : _party.text.trim(),
            advocate: _advocate.text.trim().isEmpty ? null : _advocate.text.trim(),
            caseType: _type.text.trim().isEmpty ? null : _type.text.trim().toUpperCase(),
            year: int.tryParse(_year.text.trim()),
          );
      setState(() => _result = r);
      ref.invalidate(searchHistoryProvider);
    } catch (e) {
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context);
    final tk = context.tokens;
    final exact = CaseIdentity.tryParse(_q.text);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.searchCases),
        actions: [
          IconButton(
            tooltip: l.filters,
            isSelected: _showFilters,
            style: IconButton.styleFrom(backgroundColor: _showFilters ? tk.goldSoft : null),
            icon: Icon(AppIcons.filters, color: _showFilters ? tk.onGoldSoft : null),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: ListView(
        padding: AppLayout.page(context, top: AppSpacing.sm, bottom: AppSpacing.xxl),
        children: [
          TextField(
            key: const Key('searchField'),
            controller: _q,
            onChanged: _onChanged,
            onSubmitted: (_) => _search(),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              prefixIcon: const Icon(AppIcons.search, size: AppIcons.size),
              hintText: l.searchHint,
              suffixIcon: IconButton(
                tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                icon: const Icon(AppIcons.clear, size: AppIcons.size),
                onPressed: () => setState(() {
                  _q.clear();
                  _result = null;
                  _suggestions = const [];
                }),
              ),
            ),
          ),
          if (_suggestions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: AppCard(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Column(
                  children: [
                    for (final s in _suggestions)
                      ListTile(
                        dense: true,
                        leading: Icon(AppIcons.suggestion, size: 16, color: tk.textTertiary),
                        title: Text(s),
                        onTap: () {
                          _q.text = s;
                          _search();
                        },
                      ),
                  ],
                ),
              ),
            ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: !_showFilters
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(AppIcons.filters, size: 16, color: tk.goldText),
                              const SizedBox(width: 8),
                              Text(l.filters, style: t.textTheme.titleSmall),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _type,
                                  decoration: InputDecoration(labelText: l.caseType),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: TextField(
                                  controller: _year,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(labelText: l.caseYear),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextField(
                            controller: _party,
                            decoration: InputDecoration(labelText: l.partyName),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextField(
                            controller: _advocate,
                            decoration: InputDecoration(labelText: l.advocateName),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(onPressed: _search, busy: _busy, icon: AppIcons.search, label: l.searchCases),
          const SizedBox(height: AppSpacing.lg),
          if (_error != null) ErrorState(error: _error!, onRetry: _search),
          if (_result != null) ..._results(context, _result!, exact),
          if (_result == null && !_busy) _history(context),
        ],
      ),
    );
  }

  List<Widget> _results(BuildContext context, SearchResponse r, CaseIdentity? exact) {
    final l = context.l10n;
    return [
      SectionHeader(l.casesCount(r.total)),
      if (r.results.isEmpty) ...[
        EmptyState(message: r.hint ?? l.emptySearch, icon: AppIcons.searchEmpty),
        if (exact != null)
          OutlinedButton.icon(
            icon: const Icon(AppIcons.openExternal, size: AppIcons.sizeSm),
            label: Text('${l.caseDetails}: ${exact.slash}'),
            onPressed: () => openCase(context, caseNumber: exact.slash),
          ),
      ],
      for (final (i, s) in r.results.indexed)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md - 2),
          child: FadeSlideIn(
            order: i,
            child: CaseCard(
              caseNumber: s.caseNumber,
              petitioner: s.petitioner,
              respondent: s.respondent,
              subtitle: s.lastListed == null
                  ? s.status
                  : '${Fmt.shortDate(s.lastListed!.listDate, locale: context.localeName)} · '
                        '${l.court(s.lastListed!.courtNo)} · ${l.itemNo(s.lastListed!.itemNo)}',
              badges: [if (s.status != null) StatusChip(s.status!, color: AppColors.navyLight)],
              onTap: () => openCase(context, caseId: s.caseId),
            ),
          ),
        ),
    ];
  }

  Widget _history(BuildContext context) {
    final l = context.l10n;
    final h = ref.watch(searchHistoryProvider);
    final items = h.value ?? const <String>[];
    if (items.isEmpty) return const SizedBox.shrink();
    return SectionCard(
      title: l.searchHistory,
      icon: AppIcons.history,
      trailing: TextButton(
        onPressed: () async {
          await ref.read(courtRepositoryProvider).clearSearchHistory();
          ref.invalidate(searchHistoryProvider);
        },
        child: Text(l.clearHistory),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final q in items)
            ActionChip(
              avatar: const Icon(AppIcons.history, size: 14),
              label: Text(q),
              onPressed: () {
                _q.text = q;
                _search();
              },
            ),
        ],
      ),
    );
  }
}
