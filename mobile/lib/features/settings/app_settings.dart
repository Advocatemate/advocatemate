import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/providers.dart';

class AppSettings {
  const AppSettings({required this.themeMode, required this.locale, required this.liveAutoRefresh});
  final ThemeMode themeMode;
  final Locale? locale;
  final bool liveAutoRefresh;

  AppSettings copyWith({ThemeMode? themeMode, Locale? locale, bool? liveAutoRefresh}) => AppSettings(
        themeMode: themeMode ?? this.themeMode,
        locale: locale ?? this.locale,
        liveAutoRefresh: liveAutoRefresh ?? this.liveAutoRefresh,
      );
}

class AppSettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final p = ref.watch(preferencesProvider);
    return AppSettings(
      themeMode: p.themeMode,
      locale: p.languageCode == null ? null : Locale(p.languageCode!),
      liveAutoRefresh: p.liveAutoRefresh,
    );
  }

  Future<void> setThemeMode(ThemeMode m) async {
    await ref.read(preferencesProvider).setThemeMode(m);
    state = state.copyWith(themeMode: m);
  }

  Future<void> setLanguage(String code) async {
    await ref.read(preferencesProvider).setLanguageCode(code);
    state = state.copyWith(locale: Locale(code));
  }

  Future<void> setLiveAutoRefresh(bool v) async {
    await ref.read(preferencesProvider).setLiveAutoRefresh(v);
    state = state.copyWith(liveAutoRefresh: v);
  }
}

final appSettingsProvider = NotifierProvider<AppSettingsController, AppSettings>(AppSettingsController.new);

const supportedLanguages = {'en': 'English', 'te': 'తెలుగు'};
