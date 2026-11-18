import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app/app.dart';
import 'config/env.dart';
import 'core/providers.dart';
import 'features/notifications/push_service.dart';
import 'storage/preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseReady = await _initFirebase();
  final prefs = await AppPreferences.load();

  runApp(ProviderScope(
    overrides: [
      preferencesProvider.overrideWithValue(prefs),
      firebaseReadyProvider.overrideWithValue(firebaseReady),
    ],
    child: const AdvocateMateApp(),
  ));
}

/// Firebase (FCM + Crashlytics) is optional: it needs google-services.json /
/// GoogleService-Info.plist, which are not committed. Without them the app
/// runs normally and push notifications are simply unavailable.
Future<bool> _initFirebase() async {
  if (!Env.firebaseEnabled) return false;
  try {
    await Firebase.initializeApp();
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    return true;
  } catch (e) {
    debugPrint('Firebase not configured: $e');
    return false;
  }
}
