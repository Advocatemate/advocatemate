import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routing/app_router.dart';
import '../../shared/personal_repository.dart';

/// Overridden in main() with the result of Firebase initialisation.
final firebaseReadyProvider = Provider<bool>((ref) => false);

/// FCM device registration + notification-tap navigation.
/// A no-op when Firebase is not configured (no google-services files).
class PushService {
  PushService(this._ref);
  final Ref _ref;
  bool _started = false;

  Future<void> onSignedIn(GoRouter router) async {
    if (!_ref.read(firebaseReadyProvider) || _started) return;
    _started = true;
    try {
      final fm = FirebaseMessaging.instance;
      final settings = await fm.requestPermission(alert: true, badge: true, sound: true);
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;
      final token = await fm.getToken();
      if (token != null) await _register(token);
      fm.onTokenRefresh.listen(_register);

      void openFrom(RemoteMessage m) {
        final loc = deepLinkToLocation(m.data['deep_link'] as String?);
        if (loc != null) router.push(loc);
      }

      final initial = await fm.getInitialMessage();
      if (initial != null) openFrom(initial);
      FirebaseMessaging.onMessageOpenedApp.listen(openFrom);
    } catch (e) {
      debugPrint('Push setup skipped: $e');
    }
  }

  Future<void> _register(String token) => _ref
      .read(personalRepositoryProvider)
      .registerDevice(token: token, platform: Platform.isIOS ? 'ios' : 'android', locale: Platform.localeName.split('_').first);
}

final pushServiceProvider = Provider<PushService>(PushService.new);
