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
    final exact = CaseIdentity.tryParse(_q.text);
    return Scaffold(
      appBar: AppBar(title: Text(l.searchCases), actions: [
        IconButton(
          tooltip: l.filters,
          icon: Icon(_showFilters ? Icons.filter_alt : Icons.filter_alt_outlined),
          onPressed: () => setState(() => _showFilters = !_showFilters),
        ),
      ]),
      body: ListView(padding: const EdgeInsets.all(AppSpacing.lg), children: [
        TextField(
          key: const Key('searchField'),
          controller: _q,
          onChanged: _onChanged,
          onSubmitted: (_) => _search(),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: l.searchHint,
            suffixIcon: IconButton(
              tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
              icon: const Icon(Icons.close),
              onPressed: () => setState(() {
                _q.clear();
                _result = null;
                _suggestions = const [];
              }),
            ),
          ),
        ),
        for (final s in _suggestions)
          ListTile(
            dense: true,
            leading: const Icon(Icons.north_west, size: 18),
            title: Text(s),
            onTap: () {
              _q.text = s;
              _search();
            },
          ),
        if (_showFilters) ...[
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            Expanded(child: TextField(controller: _type, decoration: InputDecoration(labelText: l.caseType))),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
                child: TextField(
                    controller: _year, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l.caseYear))),
          ]),
          const SizedBox(height: AppSpacing.sm),
          TextField(controller: _party, decoration: InputDecoration(labelText: l.partyName)),
          const SizedBox(height: AppSpacing.sm),
          TextField(controller: _advocate, decoration: InputDecoration(labelText: l.advocateName)),
        ],
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
            onPressed: _busy ? null : _search, icon: const Icon(Icons.search), label: Text(l.searchCases)),
        const SizedBox(height: AppSpacing.lg),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) ErrorState(error: _error!, onRetry: _search),
        if (_result != null) ..._results(context, _result!, exact),
        if (_result == null && !_busy) _history(context),
      ]),
    );
  }

  List<Widget> _results(BuildContext context, SearchResponse r, CaseIdentity? exact) {
    final l = context.l10n;
    return [
      Text(l.casesCount(r.total), style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: AppSpacing.sm),
      if (r.results.isEmpty) ...[
        EmptyState(message: r.hint ?? l.emptySearch, icon: Icons.search_off),
        if (exact != null)
          OutlinedButton.icon(
            icon: const Icon(Icons.open_in_new),
            label: Text('${l.caseDetails}: ${exact.slash}'),
            onPressed: () => openCase(context, caseNumber: exact.slash),
          ),
      ],
      for (final s in r.results)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
    ];
  }

  Widget _history(BuildContext context) {
    final l = context.l10n;
    final h = ref.watch(searchHistoryProvider);
    final items = h.value ?? const <String>[];
    if (items.isEmpty) return const SizedBox.shrink();
    return SectionCard(
      title: l.searchHistory,
      trailing: TextButton(
        onPressed: () async {
          await ref.read(courtRepositoryProvider).clearSearchHistory();
          ref.invalidate(searchHistoryProvider);
        },
        child: Text(l.clearHistory),
      ),
      child: Wrap(spacing: 6, runSpacing: 6, children: [
        for (final q in items)
          ActionChip(
            label: Text(q),
            onPressed: () {
              _q.text = q;
              _search();
            },
          ),
      ]),
    );
  }
}
