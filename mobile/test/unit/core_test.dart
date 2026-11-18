import 'package:advocatemate/core/case_identity.dart';
import 'package:advocatemate/core/errors.dart';
import 'package:advocatemate/core/formatters.dart';
import 'package:advocatemate/features/court_wise_cases/court_wise_screen.dart';
import 'package:advocatemate/network/api_client.dart';
import 'package:advocatemate/routing/app_router.dart';
import 'package:advocatemate/shared/court_repository.dart';
import 'package:advocatemate/shared/models/models.dart';
import 'package:advocatemate/storage/cache_store.dart';
import 'package:advocatemate/storage/token_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_backend.dart';

ApiClient _client(FakeBackend b, MemoryTokenStore t) =>
    ApiClient(tokens: t, dio: Dio(BaseOptions(baseUrl: 'http://test/api/v1'))..httpClientAdapter = b);

void main() {
  group('CaseIdentity', () {
    test('parses slash and spaced forms', () {
      expect(CaseIdentity.tryParse('WP/32115/2023')?.slash, 'WP/32115/2023');
      expect(CaseIdentity.tryParse(' wp 32115/2023 ')?.slash, 'WP/32115/2023');
      expect(CaseIdentity.tryParse('WP(PIL)/206/2024')?.caseType, 'WP(PIL)');
    });
    test('rejects malformed and ambiguous input', () {
      for (final bad in ['', 'WP', 'WP/abc/2023', 'WP/012/2023', 'WP/1/23', 'hello world']) {
        expect(CaseIdentity.tryParse(bad), isNull, reason: bad);
      }
    });
  });

  group('Deep links', () {
    test('maps notification links to routes', () {
      expect(deepLinkToLocation('advocatemate://cases/abc'), '/cases/abc');
      expect(deepLinkToLocation('advocatemate://cause-list/advocate/12345?date=2026-11-18'),
          '/advocate/12345?date=2026-11-18');
      expect(deepLinkToLocation('advocatemate://cause-list/daily?date=2026-11-18'), '/cause-list/daily?date=2026-11-18');
      expect(deepLinkToLocation('https://evil.example/cases/1'), isNull);
      expect(deepLinkToLocation('advocatemate://unknown/x'), isNull);
      expect(deepLinkToLocation(null), isNull);
    });
  });

  group('Court listing filter', () {
    const items = [
      ListingItem(sequence: 2, itemNo: '59', caseNumber: 'WP/333/2017', petitioner: 'GAMMA', stage: 'REVENUE'),
      ListingItem(sequence: 1, itemNo: '1', caseNumber: 'WP/11111/2026', petitioner: 'ALPHA', stage: 'ADMISSION'),
      ListingItem(sequence: 3, itemNo: '59.1', caseNumber: 'WP/444/2018', petitionerAdvocates: ['ADVOCATE FIVE'], stage: 'REVENUE'),
    ];
    test('keeps original source sequence by default', () {
      expect(filterListing(items).map((i) => i.itemNo), ['1', '59', '59.1']);
    });
    test('search, stage filter and sort', () {
      expect(filterListing(items, query: 'five').single.itemNo, '59.1');
      expect(filterListing(items, stage: 'REVENUE').length, 2);
      expect(filterListing(items, sort: CourtSort.caseNumber).first.caseNumber, 'WP/11111/2026');
    });
  });

  group('ApiClient', () {
    test('maps backend error envelope', () async {
      final b = FakeBackend()..on('GET', '/x', (_) => apiError(422, 'invalid_case_number', 'Bad case'));
      final c = _client(b, MemoryTokenStore());
      await expectLater(c.get('/x'), throwsA(isA<ApiException>()
          .having((e) => e.code, 'code', 'invalid_case_number')
          .having((e) => e.statusCode, 'status', 422)));
    });

    test('network failure is classified for offline fallback', () async {
      final b = FakeBackend()..offline = true;
      try {
        await _client(b, MemoryTokenStore()).get('/x');
        fail('should throw');
      } on ApiException catch (e) {
        expect(e.isNetwork, isTrue);
        expect(e.allowsCachedFallback, isTrue);
      }
    });

    test('refreshes once on 401 and retries with the rotated token', () async {
      final tokens = MemoryTokenStore()..tokens = const StoredTokens(accessToken: 'old', refreshToken: 'r1-r1-r1-r1-r1-r1-r1');
      final b = FakeBackend();
      b.on('GET', '/auth/me', (r) => r.headers['Authorization'] == 'Bearer new'
          ? {'ok': true}
          : apiError(401, 'token_expired', 'expired'));
      b.on('POST', '/auth/refresh', (r) => {'access_token': 'new', 'refresh_token': 'r2-r2-r2-r2-r2-r2-r2', 'expires_in': 900,
            'session_id': 's'});
      final res = await _client(b, tokens).get('/auth/me');
      expect(res, {'ok': true});
      expect(tokens.tokens!.refreshToken, 'r2-r2-r2-r2-r2-r2-r2');
      expect(b.paths().where((p) => p.startsWith('POST /api/v1/auth/refresh')).length, 1);
    });

    test('failed refresh clears tokens and signals session expiry', () async {
      final tokens = MemoryTokenStore()..tokens = const StoredTokens(accessToken: 'old', refreshToken: 'r1-r1-r1-r1-r1-r1-r1');
      final b = FakeBackend()
        ..on('GET', '/auth/me', (_) => apiError(401, 'token_expired', 'expired'))
        ..on('POST', '/auth/refresh', (_) => apiError(401, 'refresh_reused', 'reused'));
      var expired = false;
      final c = _client(b, tokens)..onSessionExpired = () => expired = true;
      await expectLater(c.get('/auth/me'), throwsA(isA<ApiException>()));
      expect(expired, isTrue);
      expect(tokens.tokens, isNull);
    });
  });

  group('Offline caching', () {
    test('serves saved cause list when offline and flags it', () async {
      final b = standardBackend();
      final cache = MemoryCacheStore();
      final repo = CourtRepository(_client(b, MemoryTokenStore()), cache);
      final first = await repo.courtListing('D', '2026-11-18', '3');
      expect(first.fromCache, isFalse);
      expect(first.isCurrent, isTrue);
      b.offline = true;
      final second = await repo.courtListing('D', '2026-11-18', '3');
      expect(second.fromCache, isTrue);
      expect(second.isCurrent, isFalse);
      expect(second.data.items.length, 3);
    });

    test('no cache + offline surfaces the error', () async {
      final b = standardBackend()..offline = true;
      final repo = CourtRepository(_client(b, MemoryTokenStore()), MemoryCacheStore());
      await expectLater(repo.courtListing('D', '2026-11-18', '3'), throwsA(isA<ApiException>()));
    });

    test('cached live board is never presented as current', () async {
      final b = standardBackend();
      final repo = CourtRepository(_client(b, MemoryTokenStore()), MemoryCacheStore());
      expect((await repo.liveBoard()).data.isCurrent, isTrue);
      b.offline = true;
      final cached = await repo.liveBoard();
      expect(cached.data.isCurrent, isFalse);
      expect(cached.data.stale, isTrue);
    });

    test('4xx errors do not fall back to cache', () async {
      final b = standardBackend();
      final cache = MemoryCacheStore();
      final repo = CourtRepository(_client(b, MemoryTokenStore()), cache);
      await repo.courtListing('D', '2026-11-18', '3');
      b.on('GET', '/cause-list/court/3', (_) => apiError(422, 'bad', 'bad'));
      await expectLater(repo.courtListing('D', '2026-11-18', '3'), throwsA(isA<ApiException>()));
    });
  });

  test('formatters', () {
    expect(Fmt.isoDate(DateTime(2026, 11, 8)), '2026-11-08');
    expect(Fmt.humanise('filing_date'), 'Filing date');
    expect(Fmt.age(DateTime.now().subtract(const Duration(minutes: 5))), '5 min ago');
  });
}
