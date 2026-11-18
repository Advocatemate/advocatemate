import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/errors.dart';
import '../core/providers.dart';
import '../network/api_client.dart';
import '../storage/cache_store.dart';
import 'models/models.dart';

/// Favourites (stored in PostgreSQL per user), devices and notifications.
class PersonalRepository {
  PersonalRepository(this._api, this._cache);
  final ApiClient _api;
  final CacheStore _cache;

  Future<List<T>> _list<T>(String key, String path, T Function(Map<String, dynamic>) parse) async {
    try {
      final json = await _api.get(path) as List;
      await _cache.write(key, json);
      return [for (final j in json) parse(j as Map<String, dynamic>)];
    } on ApiException catch (e) {
      final c = e.allowsCachedFallback ? await _cache.read(key) : null;
      if (c == null) rethrow;
      return [for (final j in c.json as List) parse(j as Map<String, dynamic>)];
    }
  }

  Future<List<FavouriteAdvocate>> favouriteAdvocates() =>
      _list('fav_adv', '/favourites/advocates', FavouriteAdvocate.fromJson);

  Future<FavouriteAdvocate> addFavouriteAdvocate(String code, {String? label}) async => FavouriteAdvocate.fromJson(
      await _api.post('/favourites/advocates', data: {'advocate_code': code, 'label': ?label}));

  Future<void> removeFavouriteAdvocate(String id) => _api.delete('/favourites/advocates/$id');

  Future<List<FavouriteCase>> favouriteCases() => _list('fav_case', '/favourites/cases', FavouriteCase.fromJson);

  Future<FavouriteCase> addFavouriteCase({String? caseId, String? caseNumber}) async => FavouriteCase.fromJson(
      await _api.post('/favourites/cases', data: {'case_id': ?caseId, 'case_number': ?caseNumber}));

  Future<void> removeFavouriteCase(String id) => _api.delete('/favourites/cases/$id');

  Future<NotificationPage> notifications({bool unreadOnly = false}) async =>
      NotificationPage.fromJson(await _api.get('/notifications', query: {if (unreadOnly) 'unread_only': 'true'}));

  Future<void> markRead({List<String> ids = const [], bool all = false}) =>
      _api.post('/notifications/read', data: {'ids': ids, 'all': all});

  Future<NotificationPrefs> prefs() async => NotificationPrefs.fromJson(await _api.get('/notifications/preferences'));

  Future<NotificationPrefs> savePrefs(NotificationPrefs p) async =>
      NotificationPrefs.fromJson(await _api.put('/notifications/preferences', data: p.toJson()));

  Future<String> registerDevice({required String token, required String platform, String? locale}) async {
    final json = await _api.post('/devices', data: {'token': token, 'platform': platform, 'locale': locale});
    return (json as Map)['id'] as String;
  }

  Future<void> unregisterDevice(String id) => _api.delete('/devices/$id');
}

final personalRepositoryProvider = Provider<PersonalRepository>(
    (ref) => PersonalRepository(ref.watch(apiClientProvider), ref.watch(cacheStoreProvider)));
