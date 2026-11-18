/// Build-time configuration via --dart-define (see docs/ANDROID_RELEASE.md).
///
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000 --dart-define=APP_ENV=development
class Env {
  const Env._();

  static const appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'development');

  /// Backend origin. Android emulator reaches the host machine at 10.0.2.2.
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000');

  /// Firebase is only initialised when the platform config files are present
  /// and this flag is set (they are not committed to the repository).
  static const firebaseEnabled = bool.fromEnvironment('FIREBASE_ENABLED', defaultValue: false);

  static bool get isProduction => appEnv == 'production';

  static String get apiPrefix => '$apiBaseUrl/api/v1';
}
