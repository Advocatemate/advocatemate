import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/errors.dart';
import '../core/formatters.dart';
import '../core/loaded.dart';
import '../core/providers.dart';
import '../network/api_client.dart';
import '../storage/cache_store.dart';
import 'models/models.dart';

/// All court data goes through the AdvocateMate backend - never directly to APHC.
class CourtRepository {
  CourtRepository(this._api, this._cache);
  final ApiClient _api;
  final CacheStore _cache;

  static const _offlineMaxAge = Duration(days: 14);

  Future<Loaded<T>> _cached<T>(
    String key,
    Future<dynamic> Function() fetch,
    T Function(Map<String, dynamic>) parse, {
    bool Function(Map<String, dynamic>)? serverStale,
  }) async {
    try {
      final json = (await fetch()) as Map<String, dynamic>;
      await _cache.write(key, json);
      return Loaded(parse(json),
          serverStale: serverStale?.call(json) ?? (json['stale'] == true),
          fetchedAt: Fmt.parse(json['fetched_at'] as String?));
    } on ApiException catch (e) {
      if (!e.allowsCachedFallback) rethrow;
      final c = await _cache.read(key, maxAge: _offlineMaxAge);
      if (c == null) rethrow;
      final json = c.json as Map<String, dynamic>;
      return Loaded(parse(json), fromCache: true, savedAt: c.savedAt, fetchedAt: Fmt.parse(json['fetched_at'] as String?));
    }
  }

  // ------------------------------------------------------------------ cause lists
  Future<Loaded<AdvocateCauseList>> advocateCauseList(String code, DateTime date, {bool refresh = false}) {
    final d = Fmt.isoDate(date);
    return _cached('advocate:$code:$d',
        () => _api.get('/cause-list/advocate/$code', query: {'date': d, if (refresh) 'refresh': 'true'}),
        AdvocateCauseList.fromJson);
  }

  Future<Loaded<ListDates>> listDates(String listType) =>
      _cached('dates:$listType', () => _api.get('/cause-list/dates', query: {'list_type': listType}), ListDates.fromJson);

  Future<Loaded<CourtsResponse>> courts(String listType, String isoDate) => _cached('courts:$listType:$isoDate',
      () => _api.get('/cause-list/courts', query: {'list_type': listType, 'date': isoDate}), CourtsResponse.fromJson);

  Future<Loaded<CourtListing>> courtListing(String listType, String isoDate, String courtNo, {bool refresh = false}) =>
      _cached(
          'court:$listType:$isoDate:$courtNo',
          () => _api.get('/cause-list/court/$courtNo',
              query: {'list_type': listType, 'date': isoDate, if (refresh) 'refresh': 'true'}),
          CourtListing.fromJson);

  /// Items courts kept back (passed over), from the APHC display board. [date] defaults to today.
  Future<Loaded<PassedOverList>> passedOver({DateTime? date}) {
    final d = date == null ? null : Fmt.isoDate(date);
    return _cached('passed-over:${d ?? 'today'}',
        () => _api.get('/cause-list/passed-over', query: {'date': ?d}), PassedOverList.fromJson,
        serverStale: (json) => json['board_stale'] == true);
  }

  Future<Loaded<PublicationStatus>> publicationStatus() =>
      _cached('publication', () => _api.get('/cause-list/status'), PublicationStatus.fromJson);

  /// Live board: a cached copy is NEVER presented as current.
  Future<Loaded<LiveBoard>> liveBoard() async {
    final l = await _cached('live', () => _api.get('/live-courts'), LiveBoard.fromJson);
    if (l.fromCache) {
      return Loaded(l.data.copyWith(isCurrent: false, stale: true), fromCache: true, savedAt: l.savedAt);
    }
    return l;
  }

  // ------------------------------------------------------------------ cases
  Future<Loaded<CaseDetails>> caseById(String id) =>
      _cached('case:$id', () => _api.get('/cases/$id'), CaseDetails.fromJson, serverStale: (_) => false);

  Future<Loaded<CaseDetails>> caseByNumber(String caseNumber) async {
    final l = await _cached('casenum:$caseNumber', () => _api.get('/case-details', query: {'case_number': caseNumber}),
        CaseDetails.fromJson, serverStale: (_) => false);
    if (!l.fromCache) await _cache.write('case:${l.data.caseId}', l.data.toJson());
    return l;
  }

  Future<EnrichmentStatus> enrichmentStatus(String caseId) async =>
      EnrichmentStatus.fromJson(await _api.get('/cases/$caseId/enrichment-status'));

  Future<EnrichmentStatus> requestRefresh(String caseId) async =>
      EnrichmentStatus.fromJson(await _api.post('/cases/$caseId/refresh'));

  // ------------------------------------------------------------------ search
  Future<SearchResponse> search({String? q, String? caseType, int? year, String? party, String? advocate}) async =>
      SearchResponse.fromJson(await _api.get('/search/cases', query: {
        'q': q,
        'case_type': caseType,
        'case_year': year?.toString(),
        'party': party,
        'advocate': advocate,
      }));

  Future<List<String>> searchHistory() async {
    final json = await _api.get('/search/history') as Map<String, dynamic>;
    return [for (final i in (json['items'] as List)) (i as Map)['query'] as String];
  }

  Future<void> clearSearchHistory() => _api.delete('/search/history');

  Future<List<String>> suggestions(String prefix) async {
    final json = await _api.get('/search/suggestions', query: {'prefix': prefix}) as Map<String, dynamic>;
    return (json['items'] as List).cast<String>();
  }
}

final courtRepositoryProvider =
    Provider<CourtRepository>((ref) => CourtRepository(ref.watch(apiClientProvider), ref.watch(cacheStoreProvider)));
