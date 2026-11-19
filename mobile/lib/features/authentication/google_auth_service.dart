import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../config/env.dart';

/// Why Google sign-in did not produce a token (shown to the user, never sent to the backend).
enum GoogleSignInFailure { cancelled, notConfigured, unavailable, failed }

class GoogleSignInError implements Exception {
  const GoogleSignInError(this.failure, [this.detail]);
  final GoogleSignInFailure failure;
  final String? detail;

  @override
  String toString() => 'GoogleSignInError($failure, $detail)';
}

/// Step 1 on the device: let the user pick a Google account and return its ID token.
/// The token is only ever verified by the backend; the app never trusts its contents.
abstract class GoogleAuthService {
  Future<String> signIn();
  Future<void> signOut();
}

class PluginGoogleAuthService implements GoogleAuthService {
  bool _initialised = false;

  Future<void> _init() async {
    if (_initialised) return;
    if (Env.googleServerClientId.isEmpty) {
      throw const GoogleSignInError(GoogleSignInFailure.notConfigured, 'GOOGLE_SERVER_CLIENT_ID not set');
    }
    await GoogleSignIn.instance.initialize(
      serverClientId: Env.googleServerClientId,
      clientId: Platform.isIOS && Env.googleIosClientId.isNotEmpty ? Env.googleIosClientId : null,
    );
    _initialised = true;
  }

  @override
  Future<String> signIn() async {
    await _init();
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw const GoogleSignInError(GoogleSignInFailure.unavailable);
    }
    try {
      final account = await GoogleSignIn.instance.authenticate();
      final token = account.authentication.idToken;
      if (token == null || token.isEmpty) throw const GoogleSignInError(GoogleSignInFailure.failed, 'no ID token');
      return token;
    } on GoogleSignInException catch (e) {
      switch (e.code) {
        case GoogleSignInExceptionCode.canceled:
        case GoogleSignInExceptionCode.interrupted:
          throw const GoogleSignInError(GoogleSignInFailure.cancelled);
        case GoogleSignInExceptionCode.clientConfigurationError:
        case GoogleSignInExceptionCode.providerConfigurationError:
          throw GoogleSignInError(GoogleSignInFailure.notConfigured, e.description);
        case GoogleSignInExceptionCode.uiUnavailable:
          throw GoogleSignInError(GoogleSignInFailure.unavailable, e.description);
        default:
          throw GoogleSignInError(GoogleSignInFailure.failed, e.description);
      }
    }
  }

  /// Forget the device's Google account choice so the next sign-in shows the account picker.
  /// The permanent Google <-> advocate link on the server is NOT touched.
  @override
  Future<void> signOut() async {
    if (!_initialised) {
      try {
        await _init();
      } catch (_) {
        return;
      }
    }
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }
}

final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) => PluginGoogleAuthService());
