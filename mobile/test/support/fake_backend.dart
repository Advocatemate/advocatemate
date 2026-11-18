import 'dart:convert';
import 'dart:typed_data';

import 'package:advocatemate/core/providers.dart';
import 'package:advocatemate/network/api_client.dart';
import 'package:advocatemate/storage/cache_store.dart';
import 'package:advocatemate/storage/preferences.dart';
import 'package:advocatemate/storage/token_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

typedef Handler = Object? Function(RequestOptions req);

/// In-memory AdvocateMate backend for widget / integration tests.
/// Responses mirror the real /api/v1 contract (see backend tests).
class FakeBackend implements HttpClientAdapter {
  final Map<String, Handler> routes = {};
  final List<RequestOptions> requests = [];
  bool offline = false;

  void on(String method, String path, Handler h) => routes['$method $path'] = h;

  List<String> paths() => [for (final r in requests) '${r.method} ${r.uri.path}${r.uri.query.isEmpty ? '' : '?${r.uri.query}'}'];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    if (offline) {
      throw DioException.connectionError(requestOptions: options, reason: 'offline');
    }
    final path = options.uri.path.replaceFirst('/api/v1', '');
    final h = routes['${options.method} $path'];
    if (h == null) return _json(404, {'error': {'code': 'not_found', 'message': 'No fake for ${options.method} $path'}});
    final out = h(options);
    if (out is FakeResponse) return out.body is Uint8List ? _bytes(out.status, out.body as Uint8List, out.headers) : _json(out.status, out.body);
    return _json(200, out);
  }

  ResponseBody _json(int status, Object? body) => ResponseBody.fromString(jsonEncode(body), status,
      headers: {Headers.contentTypeHeader: ['application/json']});

  ResponseBody _bytes(int status, Uint8List bytes, Map<String, List<String>> headers) =>
      ResponseBody.fromBytes(bytes, status, headers: headers);

  @override
  void close({bool force = false}) {}
}

class FakeResponse {
  FakeResponse(this.status, this.body, {this.headers = const {}});
  final int status;
  final Object? body;
  final Map<String, List<String>> headers;
}

FakeResponse apiError(int status, String code, String message) =>
    FakeResponse(status, {'error': {'code': code, 'message': message}});

/// Standard data set used across tests (synthetic names).
FakeBackend standardBackend() {
  final b = FakeBackend();
  var enrichmentPolls = 0;
  b.on('POST', '/auth/register', (_) => {
        'advocate_code': '12345',
        'advocate_name': 'ADVOCATE ONE',
        'source': 'aphc.gov.in (Lexika)',
        'already_registered': false,
        'registered_mobile_hint': null,
        'otp_available': true,
        'identity_note': 'Please confirm',
      });
  b.on('POST', '/auth/send-otp', (_) => {
        'otp_id': 'x', 'expires_in': 300, 'sent_to': '+91******3210', 'advocate_name': 'ADVOCATE ONE', 'dev_otp': '123456'});
  b.on('POST', '/auth/verify-otp', (r) {
    final data = r.data as Map;
    if (data['otp'] != '123456') return apiError(401, 'otp_invalid', 'Incorrect OTP');
    return {'access_token': 'acc', 'refresh_token': 'ref-token-ref-token-ref', 'expires_in': 900, 'session_id': 's1', 'token_type': 'bearer'};
  });
  b.on('GET', '/auth/me', (_) => {
        'user_id': 'u1',
        'role': 'advocate',
        'preferred_language': 'en',
        'advocate_code': '12345',
        'advocate_name': 'ADVOCATE ONE',
        'identity_verification': 'self_declared',
        'mobile': '+91******3210',
        'created_at': '2026-11-18T10:00:00Z',
      });
  b.on('POST', '/auth/logout', (_) => FakeResponse(204, null));
  b.on('GET', '/cause-list/status', (_) => {
        'list_date': '2026-11-18',
        'fetched_at': '2026-11-18T09:00:00Z',
        'stale': false,
        'summary': {'UPLOADED': 2, 'ON LEAVE': 1},
        'courts': [
          {'court_no': '1', 'bench_code': 'DB-I', 'status': 'UPLOADED', 'has_pdf': true},
        ],
      });
  b.on('GET', '/notifications', (r) => {
        'total': 1,
        'unread_count': 1,
        'items': [
          {
            'id': 'n1',
            'category': 'enrichment',
            'title': 'Case details updated',
            'body': 'Latest details for WP/11111/2026 are now available.',
            'deep_link': 'advocatemate://cases/c1',
            'data': {},
            'read': false,
            'created_at': '2026-11-18T09:30:00Z',
          }
        ],
      });
  b.on('POST', '/notifications/read', (_) => FakeResponse(204, null));
  b.on('GET', '/cause-list/advocate/12345', (r) => {
        'advocate_code': '12345',
        'advocate_name': 'ADVOCATE ONE',
        'list_date': r.queryParameters['date'],
        'date_offered_by_source': true,
        'available_dates': ['2026-11-20', '2026-11-18'],
        'total_cases': 3,
        'fetched_at': '2026-11-18T08:00:00Z',
        'stale': false,
        'courts': [
          {
            'court_no': '1',
            'cases': [
              {'item_no': '28.1', 'court_no': '1', 'list_type': 'Daily', 'raw_case': 'WP(PIL)/22/2025', 'case_number': 'WP(PIL)/22/2025', 'case_id': 'c2'}
            ]
          },
          {
            'court_no': '3',
            'cases': [
              {
                'item_no': '1', 'court_no': '3', 'list_type': 'Daily', 'raw_case': 'WP/11111/2026', 'case_number': 'WP/11111/2026',
                'case_id': 'c1', 'petitioner': 'PETITIONER ALPHA', 'respondent': 'THE STATE OF ANDHRA PRADESH'
              },
              {
                'item_no': '59', 'court_no': '3', 'list_type': 'Daily', 'raw_case': 'IA/1/2026-Condone Delay Petition,CMA/506/2012',
                'case_number': 'CMA/506/2012', 'case_id': 'c3', 'application': 'IA/1/2026', 'application_description': 'Condone Delay Petition'
              },
            ]
          },
        ],
      });
  b.on('GET', '/cause-list/dates', (r) => {
        'list_type': r.queryParameters['list_type'],
        'dates': ['2026-11-18', '2026-11-17'],
        'fetched_at': '2026-11-18T08:00:00Z',
        'stale': false,
      });
  b.on('GET', '/cause-list/courts', (r) => {
        'list_type': r.queryParameters['list_type'],
        'list_date': r.queryParameters['date'],
        'courts': [
          {'court_no': '1', 'court_name': 'COURT NO. 1', 'case_count': null},
          {'court_no': '3', 'court_name': 'COURT NO. 3', 'case_count': 4, 'bench': 'SAMPLE JUDGE'},
        ],
        'fetched_at': '2026-11-18T08:00:00Z',
        'stale': false,
      });
  b.on('GET', '/cause-list/court/3', (r) => {
        'list_type': r.queryParameters['list_type'],
        'list_date': r.queryParameters['date'],
        'court_no': '3',
        'bench': 'THE HONOURABLE SMT JUSTICE SAMPLE JUDGE',
        'headings': ['(CAUSE LIST MOTION HEARING)'],
        'status': 'synced',
        'total_cases': 3,
        'fetched_at': '2026-11-18T08:00:00Z',
        'stale': false,
        'items': [
          {'sequence': 1, 'item_no': '1', 'case_id': 'c1', 'case_number': 'WP/11111/2026', 'petitioner': 'PETITIONER ALPHA',
            'respondent': 'THE STATE OF ANDHRA PRADESH', 'stage': 'ADMISSION', 'applications': [{'number': 'IA 1/2026', 'description': 'Direction Petition'}]},
          {'sequence': 2, 'item_no': '59', 'case_id': 'c4', 'case_number': 'WP/333/2017', 'petitioner': 'PETITIONER GAMMA',
            'respondent': 'RESPONDENT GAMMA', 'stage': 'REVENUE'},
          {'sequence': 3, 'item_no': '59.1', 'case_id': 'c5', 'case_number': 'WP/444/2018', 'petitioner': 'PETITIONER DELTA',
            'respondent': 'RESPONDENT DELTA', 'stage': 'REVENUE', 'remarks': '59.1 along with 59'},
        ],
      });
  Map<String, Object?> details(String state) => {
        'identity': {'case_id': 'c1', 'case_type': 'WP', 'case_number': '11111', 'case_year': 2026, 'display': 'WP/11111/2026'},
        'information': state == 'completed' ? {'status': 'PENDING', 'filing_date': '2026-10-26', 'purpose': 'ADMISSION'} : {},
        'parties': state == 'completed'
            ? {
                'petitioner_summary': 'PETITIONER ALPHA',
                'respondent_summary': 'THE STATE OF ANDHRA PRADESH',
                'petitioners': [{'party_no': 1, 'name': 'PETITIONER ALPHA'}],
                'respondents': [{'party_no': 1, 'name': 'THE STATE OF ANDHRA PRADESH'}, {'party_no': 2, 'name': 'The District Collector.,'}],
              }
            : {},
        'advocates': state == 'completed'
            ? {'vakalath': [{'side': 'P', 'party_no': '1', 'advocate_name': 'ADVOCATE ONE', 'advocate_code': '12345'}]}
            : {},
        'additional': {},
        'enrichment': {'case_id': 'c1', 'state': state, 'freshness': state == 'completed' ? 'fresh' : null,
          'fetched_at': state == 'completed' ? '2026-11-18T10:00:00Z' : null},
        'provenance': {'source': state == 'completed' ? 'aphc_lexika_chatbot' : null},
        'unavailable_sections': ['orders'],
        'unavailable_note': 'Orders are not yet retrieved.',
      };
  b.on('GET', '/cases/c1', (_) => details(enrichmentPolls >= 1 ? 'completed' : 'pending'));
  b.on('GET', '/case-details', (_) => details('pending'));
  b.on('GET', '/cases/c1/enrichment-status', (_) {
    enrichmentPolls++;
    return {'case_id': 'c1', 'state': 'completed', 'freshness': 'fresh', 'fetched_at': '2026-11-18T10:00:00Z'};
  });
  b.on('GET', '/live-courts', (_) => {
        'fetched_at': DateTime.now().toUtc().toIso8601String(),
        'age_seconds': 20,
        'stale': false,
        'is_current': true,
        'stale_after_seconds': 180,
        'source': 'aphc.gov.in/Hcdbs/displaytext.jsp',
        'courts': [
          {'court_no': '1', 'state': 'in_progress', 'current_item': 'D-52', 'kept_back': '1', 'pending_serials': ['1'], 'coram': 'DB-I'},
          {'court_no': '21', 'state': 'not_in_session', 'pending_serials': []},
        ],
      });
  b.on('GET', '/favourites/cases', (_) => [
        {'id': 'f1', 'case_id': 'c1', 'case_number': 'WP/11111/2026', 'petitioner': 'PETITIONER ALPHA', 'created_at': '2026-11-18T10:00:00Z'}
      ]);
  final favAdvocates = <Map<String, Object?>>[];
  b.on('GET', '/favourites/advocates', (_) => favAdvocates);
  b.on('POST', '/favourites/advocates', (r) {
    final m = {'id': 'fa${favAdvocates.length}', 'advocate_code': (r.data as Map)['advocate_code'], 'advocate_name': 'ADVOCATE TWO',
      'created_at': '2026-11-18T10:00:00Z'};
    favAdvocates.add(m);
    return FakeResponse(201, m);
  });
  b.on('GET', '/search/history', (_) => {'items': []});
  b.on('GET', '/search/suggestions', (_) => {'items': []});
  b.on('GET', '/search/cases', (_) => {
        'total': 1,
        'results': [
          {'case_id': 'c4', 'case_number': 'WP/333/2017', 'petitioner': 'PETITIONER GAMMA', 'respondent': 'RESPONDENT GAMMA',
            'last_listed': {'list_date': '2026-11-18', 'court_no': '3', 'item_no': '59'}}
        ],
        'exact_case_known': false,
      });
  b.on('GET', '/notifications/preferences', (_) => {
        'cause_list_publication': true, 'favourite_advocates': true, 'case_updates': true, 'court_board': true,
        'enrichment': true, 'announcements': true});
  return b;
}

class TestDeps {
  TestDeps(this.backend, this.tokens, this.cache, this.prefs);
  final FakeBackend backend;
  final MemoryTokenStore tokens;
  final MemoryCacheStore cache;
  final AppPreferences prefs;

  List<Override> get overrides => [
        tokenStoreProvider.overrideWithValue(tokens),
        cacheStoreProvider.overrideWithValue(cache),
        preferencesProvider.overrideWithValue(prefs),
        apiClientProvider.overrideWith((ref) {
          final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'))..httpClientAdapter = backend;
          return ApiClient(tokens: tokens, dio: dio, onSessionExpired: ref.watch(sessionExpiredHookProvider).fire);
        }),
      ];
}

Future<TestDeps> makeDeps({FakeBackend? backend, bool signedIn = false}) async {
  SharedPreferences.setMockInitialValues({'language_code': 'en'});
  final prefs = AppPreferences(await SharedPreferences.getInstance());
  final tokens = MemoryTokenStore();
  if (signedIn) tokens.tokens = const StoredTokens(accessToken: 'acc', refreshToken: 'ref-token-ref-token-ref');
  return TestDeps(backend ?? standardBackend(), tokens, MemoryCacheStore(), prefs);
}
