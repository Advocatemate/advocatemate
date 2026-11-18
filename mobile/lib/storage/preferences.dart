import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Non-sensitive UI preferences only (theme, language, auto-refresh).
class AppPreferences {
  AppPreferences(this._prefs);
  final SharedPreferences _prefs;

  static Future<AppPreferences> load() async => AppPreferences(await SharedPreferences.getInstance());

  ThemeMode get themeMode => ThemeMode.values.firstWhere(
        (m) => m.name == _prefs.getString('theme_mode'),
        orElse: () => ThemeMode.system,
      );
  Future<void> setThemeMode(ThemeMode m) => _prefs.setString('theme_mode', m.name);

  String? get languageCode => _prefs.getString('language_code');
  Future<void> setLanguageCode(String code) => _prefs.setString('language_code', code);

  bool get liveAutoRefresh => _prefs.getBool('live_auto_refresh') ?? true;
  Future<void> setLiveAutoRefresh(bool v) => _prefs.setBool('live_auto_refresh', v);

  String? get lastAdvocateCode => _prefs.getString('last_advocate_code');
  Future<void> setLastAdvocateCode(String code) => _prefs.setString('last_advocate_code', code);
}
