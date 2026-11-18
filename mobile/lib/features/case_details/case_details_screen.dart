import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/formatters.dart';
import '../../core/loaded.dart';
import '../../shared/court_repository.dart';
import '../../shared/models/models.dart';
import '../../shared/personal_repository.dart';
import '../../shared/widgets/widgets.dart';
import '../../theme/app_theme.dart';
import '../favourites/favourites_screen.dart';

typedef CaseKey = ({String? id, String? number});

final caseDetailsProvider = FutureProvider.autoDispose.family<Loaded<CaseDetails>, CaseKey>((ref, k) {
  final repo = ref.watch(courtRepositoryProvider);
  return k.id != null ? repo.caseById(k.id!) : repo.caseByNumber(k.number!);
});

/// Backoff schedule for enrichment polling (seconds); stops after the last step.
const enrichmentPollSchedule = [2, 3, 5, 8, 13, 21, 30, 30, 30];

class CaseDetailsScreen extends ConsumerStatefulWidget {
  const CaseDetailsScreen({super.key, this.caseId, this.caseNumber}) : assert(caseId != null || caseNumber != null);
  final String? caseId;
  final String? caseNumber;

  @override
  ConsumerState<CaseDetailsScreen> createState() => _CaseDetailsScreenState();
}

class _CaseDetailsScreenState extends ConsumerState<CaseDetailsScreen> {
  Timer? _timer;
  int _pollStep = 0;
  EnrichmentStatus? _live;

  CaseKey get _key => (id: widget.caseId, number: widget.caseId == null ? widget.caseNumber : null);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _maybePoll(CaseDetails d) {
    final st = (_live ?? d.enrichment).state;
    if ((st == 'pending' || st == 'running') && _timer == null && _pollStep < enrichmentPollSchedule.length) {
      _timer = Timer(Duration(seconds: enrichmentPollSchedule[_pollStep]), () => _poll(d.caseId));
    }
  }

  Future<void> _poll(String caseId) async {
    _timer = null;
    _pollStep++;
    try {
      final s = await ref.read(courtRepositoryProvider).enrichmentStatus(caseId);
      if (!mounted) return;
      setState(() => _live = s);
      if (s.state == 'completed' || s.state == 'failed') {
        _live = null;
        _pollStep = 0;
        ref.invalidate(caseDetailsProvider(_key));
        return;
      }
    } catch (_) {
      // keep polling on transient errors until the schedule runs out
    }
    if (mounted && _pollStep < enrichmentPollSchedule.length) {
      _timer = Timer(Duration(seconds: enrichmentPollSchedule[_pollStep]), () => _poll(caseId));
    }
  }

  Future<void> _refresh(String caseId) async {
    try {
      final s = await ref.read(courtRepositoryProvider).requestRefresh(caseId);
      setState(() {
        _live = s;
        _pollStep = 0;
      });
      _timer?.cancel();
      _timer = null;
      _poll(caseId);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final value = ref.watch(caseDetailsProvider(_key));
    return Scaffold(
      appBar: AppBar(
        title: Text(value.value?.data.display ?? widget.caseNumber ?? l.caseDetails),
        actions: [
          if (value.hasValue) FavouriteCaseButton(caseId: value.requireValue.data.caseId),
          if (value.hasValue)
            IconButton(
              tooltip: l.caseSummaryPdf,
              icon: const Icon(Icons.picture_as_pdf_outlined),
              onPressed: () => context.push('/pdf?kind=summary&case=${value.requireValue.data.caseId}'),
            ),
        ],
      ),
      body: AsyncBody<Loaded<CaseDetails>>(
        value: value,
        onRetry: () => ref.invalidate(caseDetailsProvider(_key)),
        builder: (loaded) {
          _maybePoll(loaded.data);
          final d = loaded.data;
          final status = _live ?? d.enrichment;
          return RefreshIndicator(
            onRefresh: () => _refresh(d.caseId),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                FreshnessBanner(loaded),
                EnrichmentBanner(status: status, onRetry: () => _refresh(d.caseId)),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: _sections(context, d)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _sections(BuildContext context, CaseDetails d) {
    final l = context.l10n;
    final loc = context.localeName;
    String fmt(String k, Object? v) =>
        k.endsWith('_date') ? Fmt.shortDate(v, locale: loc) : (v is List ? v.join(', ') : v.toString());
    Widget kv(Map<String, dynamic> m, {Set<String> skip = const {}}) => Column(children: [
          for (final e in m.entries)
            if (!skip.contains(e.key) && e.value != null && e.value is! Map && !(e.value is List && (e.value as List).isEmpty))
              if (e.value is! List || (e.value as List).every((x) => x is! Map)) LabelValue(Fmt.humanise(e.key), fmt(e.key, e.value)),
        ]);
    Widget gap() => const SizedBox(height: AppSpacing.lg);

    final parties = <Widget>[
      if (d.parties['petitioner_summary'] != null) LabelValue(l.petitioner, d.parties['petitioner_summary'].toString()),
      if (d.parties['respondent_summary'] != null) LabelValue(l.respondent, d.parties['respondent_summary'].toString()),
      for (final (label, list) in [(l.petitioner, d.petitioners), (l.respondent, d.respondents)])
        for (final p in list)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(radius: 14, child: Text('${p['party_no'] ?? ''}', style: const TextStyle(fontSize: 12))),
            title: Text('${p['name']}'),
            subtitle: Text([label, if (p['description'] != null) '${p['description']}'].join(' · ')),
          ),
    ];

    return [
      SectionCard(title: l.caseIdentity, child: kv(d.identity, skip: {'case_id'})),
      if (d.information.isNotEmpty) ...[gap(), SectionCard(title: l.caseInformation, child: kv(d.information))],
      gap(),
      SectionCard(
        title: l.parties,
        child: parties.isEmpty ? Text(l.notYetAvailable) : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: parties),
      ),
      if (d.advocates.isNotEmpty) ...[
        gap(),
        SectionCard(
          title: l.advocates,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            kv(d.advocates, skip: {'vakalath'}),
            if (d.vakalath.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(l.vakalath, style: Theme.of(context).textTheme.titleSmall),
              for (final v in d.vakalath)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: StatusChip('${v['side'] ?? ''} ${v['party_no'] ?? ''}'.trim()),
                  title: Text('${v['advocate_name']}'),
                  subtitle: v['advocate_code'] == null ? null : Text('${l.advocateCode}: ${v['advocate_code']}'),
                  onTap: v['advocate_code'] == null ? null : () => context.push('/advocate/${v['advocate_code']}'),
                ),
            ],
          ]),
        ),
      ],
      if (d.observedListings.isNotEmpty) ...[
        gap(),
        SectionCard(
          title: l.listingHistory,
          child: Column(children: [
            for (final x in d.observedListings)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: const Icon(Icons.event_note_outlined, color: AppColors.gold),
                title: Text('${Fmt.shortDate(x['list_date'], locale: loc)} · ${l.court('${x['court_no']}')} · ${l.itemNo('${x['item_no']}')}'),
                subtitle: x['stage'] == null ? null : Text('${x['stage']}'),
              ),
          ]),
        ),
      ],
      gap(),
      SectionCard(
        title: l.additionalInformation,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (d.additional['other_source_fields'] is Map) kv(Map<String, dynamic>.from(d.additional['other_source_fields'] as Map)),
          Text(l.officialOrdersUnavailable, style: Theme.of(context).textTheme.bodySmall),
          if (d.unavailableNote != null) ...[
            const SizedBox(height: 4),
            Text(d.unavailableNote!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted)),
          ],
          if (d.provenance['source'] != null) ...[
            const SizedBox(height: 8),
            Text(l.source('${d.provenance['source']}'), style: Theme.of(context).textTheme.bodySmall),
          ],
        ]),
      ),
      const SizedBox(height: AppSpacing.xxl),
    ];
  }
}

class EnrichmentBanner extends StatelessWidget {
  const EnrichmentBanner({super.key, required this.status, this.onRetry});
  final EnrichmentStatus status;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final (String text, Color color, IconData icon, bool spinner) = switch (status.state) {
      'pending' => (l.enrichmentPending, AppColors.navyLight, Icons.schedule, true),
      'running' => (l.enrichmentRunning, AppColors.navyLight, Icons.sync, true),
      'failed' => (l.enrichmentFailed, AppColors.danger, Icons.error_outline, false),
      'completed' when status.freshness == 'stale' => (l.enrichmentStale, AppColors.warning, Icons.history, false),
      'completed' => (l.enrichmentCompleted, AppColors.success, Icons.verified_outlined, false),
      _ => (l.notYetAvailable, AppColors.muted, Icons.info_outline, false),
    };
    final when = Fmt.parse(status.fetchedAt);
    return Semantics(
      liveRegion: true,
      child: Container(
        key: Key('enrichment-${status.state}'),
        color: color.withValues(alpha: .1),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 10),
        child: Row(children: [
          spinner
              ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: color))
              : Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              [text, if (when != null) l.lastUpdated(Fmt.timestamp(when, locale: context.localeName))].join('\n'),
              style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          if (!spinner && onRetry != null && status.state != 'completed')
            TextButton(onPressed: onRetry, child: Text(l.retry))
          else if (status.state == 'completed' && status.freshness == 'stale' && onRetry != null)
            TextButton(onPressed: onRetry, child: Text(l.refresh)),
        ]),
      ),
    );
  }
}

/// Keeps favourites in sync after toggling from details screens.
Future<void> toggleFavouriteCase(WidgetRef ref, String caseId, FavouriteCase? existing) async {
  final repo = ref.read(personalRepositoryProvider);
  if (existing != null) {
    await repo.removeFavouriteCase(existing.id);
  } else {
    await repo.addFavouriteCase(caseId: caseId);
  }
  ref.invalidate(favouriteCasesProvider);
}
