import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../storage/cache_store.dart';
import '../storage/preferences.dart';
import '../storage/token_store.dart';

/// Overridden in tests (and in main for real platform implementations).
final tokenStoreProvider = Provider<TokenStore>((ref) => SecureTokenStore());
final cacheStoreProvider = Provider<CacheStore>((ref) => FileCacheStore());
final preferencesProvider = Provider<AppPreferences>((ref) => throw UnimplementedError('override in main'));

/// Called by the API client when refresh fails; the session layer subscribes.
final sessionExpiredHookProvider = Provider<SessionExpiredHook>((ref) => SessionExpiredHook());

class SessionExpiredHook {
  void Function()? listener;
  void fire() => listener?.call();
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final hook = ref.watch(sessionExpiredHookProvider);
  return ApiClient(tokens: ref.watch(tokenStoreProvider), onSessionExpired: hook.fire);
});
