import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../network/api_client.dart';
import '../../shared/models/models.dart';
import '../../storage/cache_store.dart';
import '../../storage/token_store.dart';
import 'google_auth_service.dart';

/// Outcome of a sign-in step: either signed in, or Google verified but an advocate code is needed.
class GoogleStepResult {
  const GoogleStepResult.signedIn() : linkToken = null, googleEmail = null, linkExpiresIn = null;
  const GoogleStepResult.needsAdvocateCode(this.linkToken, this.googleEmail, this.linkExpiresIn);

  final String? linkToken;
  final String? googleEmail;
  final int? linkExpiresIn;

  bool get isSignedIn => linkToken == null;
}

class AuthRepository {
  AuthRepository(this._api, this._tokens, this._cache, this._google);
  final ApiClient _api;
  final TokenStore _tokens;
  final CacheStore _cache;
  final GoogleAuthService _google;

  Future<GoogleStepResult> _handle(dynamic json) async {
    final r = GoogleSignInResult.fromJson(json as Map<String, dynamic>);
    if (r.status == 'signed_in' && r.accessToken != null && r.refreshToken != null) {
      await _tokens.write(StoredTokens(accessToken: r.accessToken!, refreshToken: r.refreshToken!));
      return const GoogleStepResult.signedIn();
    }
    return GoogleStepResult.needsAdvocateCode(r.linkToken!, r.googleEmail ?? '', r.linkExpiresIn);
  }

  /// Step 1: pick a Google account on the device, then let the backend verify the ID token.
  Future<GoogleStepResult> signInWithGoogle({String? deviceLabel}) async {
    final idToken = await _google.signIn();
    return _handle(await _api.post('/auth/google', data: {'id_token': idToken, 'device_label': deviceLabel}));
  }

  /// Step 2: link the backend-verified Google account to an advocate code (automatic registry check).
  Future<GoogleStepResult> linkAdvocate(String linkToken, String advocateCode, {String? deviceLabel}) async =>
      _handle(await _api.post('/auth/google/link',
          data: {'link_token': linkToken, 'advocate_code': advocateCode, 'device_label': deviceLabel}));

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

  /// Ends this device's session and forgets the Google account choice. The server-side
  /// Google <-> advocate link is permanent and is not removed.
  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {
      // Local sign-out must always succeed even when offline.
    }
    await forget();
  }

  Future<void> forget() async {
    await _tokens.clear();
    await _cache.clear();
    await _google.signOut();
  }

  Future<void> forgetGoogleChoice() => _google.signOut();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.watch(apiClientProvider),
    ref.watch(tokenStoreProvider), ref.watch(cacheStoreProvider), ref.watch(googleAuthServiceProvider)));
