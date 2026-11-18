import 'package:material_ui/material_ui.dart';

/// Brand palette: deep navy, white, very light grey, subtle gold, charcoal text.
abstract final class AppColors {
  static const navy = Color(0xFF0B1F3A);
  static const navyLight = Color(0xFF1C3560);
  static const gold = Color(0xFFB8964E);
  static const goldSoft = Color(0xFFF3EBDA);
  static const background = Color(0xFFF5F6F8);
  static const surface = Colors.white;
  static const charcoal = Color(0xFF22262E);
  static const muted = Color(0xFF5F6673);
  static const divider = Color(0xFFE3E6EB);
  static const success = Color(0xFF1E7D4F);
  static const warning = Color(0xFFB26A00);
  static const danger = Color(0xFFB3261E);

  // Dark mode
  static const darkBackground = Color(0xFF0A111C);
  static const darkSurface = Color(0xFF131C2B);
  static const darkText = Color(0xFFE6E9EF);
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const radius = 14.0;
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(
        brightness: Brightness.light,
        scheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.navy,
          onPrimary: Colors.white,
          secondary: AppColors.gold,
          onSecondary: AppColors.navy,
          error: AppColors.danger,
          onError: Colors.white,
          surface: AppColors.surface,
          onSurface: AppColors.charcoal,
          surfaceContainerHighest: Color(0xFFECEFF3),
          outline: AppColors.divider,
        ),
        background: AppColors.background,
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        scheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFF9DB7E3),
          onPrimary: AppColors.navy,
          secondary: AppColors.gold,
          onSecondary: AppColors.navy,
          error: Color(0xFFF2B8B5),
          onError: Color(0xFF601410),
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkText,
          surfaceContainerHighest: Color(0xFF1D2738),
          outline: Color(0xFF2C3850),
        ),
        background: AppColors.darkBackground,
      );

  static ThemeData _build({required Brightness brightness, required ColorScheme scheme, required Color background}) {
    final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: brightness);
    final text = base.textTheme.apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
    return base.copyWith(
      scaffoldBackgroundColor: background,
      textTheme: text.copyWith(
        headlineSmall: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.2),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        bodyMedium: text.bodyMedium?.copyWith(height: 1.35),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: brightness == Brightness.light ? AppColors.navy : AppColors.darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(color: Colors.white, fontSize: 19),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          side: BorderSide(color: scheme.outline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: scheme.outline)),
        enabledBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: scheme.outline)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: scheme.primary, width: 1.6)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: scheme.outline),
      ),
      dividerTheme: DividerThemeData(color: scheme.outline, space: 1),
    );
  }
}
