import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../network/api_client.dart';
import '../../shared/models/models.dart';
import '../../storage/cache_store.dart';
import '../../storage/token_store.dart';

class AuthRepository {
  AuthRepository(this._api, this._tokens, this._cache);
  final ApiClient _api;
  final TokenStore _tokens;
  final CacheStore _cache;

  Future<RegisterInfo> register(String code) async =>
      RegisterInfo.fromJson(await _api.post('/auth/register', data: {'advocate_code': code}));

  Future<OtpSent> sendOtp(String code, String mobile) async => OtpSent.fromJson(await _api.post('/auth/send-otp',
      data: {'advocate_code': code, 'mobile': mobile, 'identity_confirmed': true}));

  Future<void> verifyOtp(String code, String mobile, String otp, {String? deviceLabel}) async {
    final t = AuthTokens.fromJson(await _api.post('/auth/verify-otp',
        data: {'advocate_code': code, 'mobile': mobile, 'otp': otp, 'device_label': deviceLabel}));
    await _tokens.write(StoredTokens(accessToken: t.accessToken, refreshToken: t.refreshToken));
  }

  Future<bool> hasTokens() async => (await _tokens.read()) != null;

  Future<Me> me() async {
    final json = await _api.get('/auth/me');
    await _cache.write('me', json);
    return Me.fromJson(json as Map<String, dynamic>);
  }

  Future<Me?> cachedMe() async {
    final c = await _cache.read('me');
    return c == null ? null : Me.fromJson(c.json as Map<String, dynamic>);
  }

  Future<Me> updateMe({String? displayName, String? email, String? language}) async {
    final body = <String, dynamic>{};
    if (displayName != null) body['display_name'] = displayName;
    if (email != null) body['email'] = email.isEmpty ? null : email;
    if (language != null) body['preferred_language'] = language;
    final json = await _api.patch('/auth/me', data: body);
    await _cache.write('me', json);
    return Me.fromJson(json as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {
      // Local sign-out must always succeed even when offline.
    }
    await _tokens.clear();
    await _cache.clear();
  }

  Future<void> forget() async {
    await _tokens.clear();
    await _cache.clear();
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
    (ref) => AuthRepository(ref.watch(apiClientProvider), ref.watch(tokenStoreProvider), ref.watch(cacheStoreProvider)));
