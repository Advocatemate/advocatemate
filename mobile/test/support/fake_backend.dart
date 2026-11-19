import 'dart:convert';
import 'dart:typed_data';

import 'package:advocatemate/core/providers.dart';
import 'package:advocatemate/features/authentication/google_auth_service.dart';
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
  // ---- Google sign-in + automatic registry verification (mirrors backend services/google_auth.py)
  // Fake Google ID tokens look like "google-token:<sub>:<email>"; the real backend verifies them with Google.
  final registry = <String, ({String name, String? email, String status})>{
    '12345': (name: 'ADVOCATE ONE', email: 'adv.one@example.com', status: 'active'),
    '67890': (name: 'ADVOCATE TWO', email: 'adv.two@example.com', status: 'active'),
    '11111': (name: 'INACTIVE ADVOCATE', email: 'inactive.adv@example.com', status: 'inactive'),
    '22222': (name: 'NO EMAIL ADVOCATE', email: null, status: 'active'),
  };
  final linkedSubToCode = <String, String>{};
  String? currentCode;
  Map<String, Object?> signedIn(String code) {
    currentCode = code;
    return {'status': 'signed_in', 'access_token': 'acc-$code', 'refresh_token': 'ref-token-ref-token-$code',
      'expires_in': 900, 'session_id': 's-$code', 'token_type': 'bearer'};
  }

  b.on('POST', '/auth/google', (r) {
    final parts = ((r.data as Map)['id_token'] as String).split(':');
    if (parts.length != 3 || parts[0] != 'google-token') return apiError(401, 'google_token_invalid', 'bad token');
    final sub = parts[1], email = parts[2];
    final code = linkedSubToCode[sub];
    if (code != null) {
      if (registry[code]?.status != 'active') return apiError(403, 'advocate_not_eligible', 'not active');
      return signedIn(code); // Scenario B
    }
    return {'status': 'advocate_code_required', 'link_token': 'link:$sub:$email', 'link_expires_in': 600,
      'google_email': email};
  });
  b.on('POST', '/auth/google/link', (r) {
    final data = r.data as Map;
    final parts = (data['link_token'] as String).split(':');
    final sub = parts[1], email = parts[2];
    final code = data['advocate_code'] as String;
    final entry = registry[code];
    if (entry == null) return apiError(404, 'invalid_advocate_code', 'Invalid Advocate Code.');
    if (linkedSubToCode.containsKey(sub) && linkedSubToCode[sub] != code) {
      return apiError(409, 'google_account_linked_elsewhere', 'linked elsewhere');
    }
    if (entry.status != 'active') return apiError(403, 'advocate_not_eligible', 'not active');
    if (entry.email == null) return apiError(403, 'registry_email_missing', 'no email');
    if (entry.email != email) return apiError(403, 'email_mismatch', 'mismatch');
    if (linkedSubToCode.entries.any((e) => e.value == code && e.key != sub)) {
      return apiError(409, 'advocate_already_linked', 'already linked');
    }
    linkedSubToCode[sub] = code;
    return signedIn(code);
  });
  b.on('GET', '/auth/me', (_) {
    final code = currentCode ?? '12345';
    final entry = registry[code]!;
    return {
      'user_id': 'u-$code',
      'role': 'advocate',
      'preferred_language': 'en',
      'advocate_code': code,
      'advocate_name': entry.name,
      'google_email': entry.email,
      'identity_verification': 'registry_verified',
      'verification_method': 'registry_email_match',
      'created_at': '2026-11-18T10:00:00Z',
    };
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

/// Stands in for the device's Google account picker.
class FakeGoogleAuthService implements GoogleAuthService {
  String sub = 'google-sub-1';
  String email = 'adv.one@example.com';
  GoogleSignInFailure? failWith;
  int signOutCalls = 0;

  @override
  Future<String> signIn() async {
    if (failWith != null) throw GoogleSignInError(failWith!);
    return 'google-token:$sub:$email';
  }

  @override
  Future<void> signOut() async => signOutCalls++;
}

class TestDeps {
  TestDeps(this.backend, this.tokens, this.cache, this.prefs);
  final FakeBackend backend;
  final FakeGoogleAuthService google = FakeGoogleAuthService();
  final MemoryTokenStore tokens;
  final MemoryCacheStore cache;
  final AppPreferences prefs;

  List<Override> get overrides => [
        tokenStoreProvider.overrideWithValue(tokens),
        googleAuthServiceProvider.overrideWithValue(google),
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
