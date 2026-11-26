import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

/// Premium legal-tech palette: navy, restrained gold, cool light greys.
///
/// Gold (#C49A45) is an accent only — it is too light for text on white, so gold-toned text uses
/// [goldDeep]. Secondary text uses [textSecondary] (AA contrast); the brief's #7A8493 is kept as
/// [textTertiary] for hints, inactive icons and large captions.
abstract final class AppColors {
  static const navy = Color(0xFF14243D);
  static const navyDeep = Color(0xFF0B1930);
  static const navyLight = Color(0xFF2B3E5E);
  static const gold = Color(0xFFC49A45);
  static const goldDeep = Color(0xFF8C6A2A);
  static const goldSoft = Color(0xFFF3E9D2);
  static const background = Color(0xFFF5F7FA);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF202B3C);
  static const textSecondary = Color(0xFF5D6676);
  static const textTertiary = Color(0xFF7A8493);
  static const outline = Color(0xFFDCE1E8);
  static const divider = Color(0xFFE8ECF1);
  static const success = Color(0xFF1E7D4F);
  static const warning = Color(0xFF9A5B00);
  static const danger = Color(0xFFB3261E);

  /// Older names kept so existing call sites read the same.
  static const charcoal = textPrimary;
  static const muted = textSecondary;

  // Dark mode: warm charcoal surfaces with gold accents (not blue), navy kept for the hero only.
  static const darkBackground = Color(0xFF0E1013);
  static const darkSurface = Color(0xFF181B20);
  static const darkSurfaceHigh = Color(0xFF22262D);
  static const darkText = Color(0xFFEDEEF0);
  static const darkTextSecondary = Color(0xFFA9ADB5);
  static const darkOutline = Color(0xFF2B2F37);
  static const goldLight = Color(0xFFE2C27F);
}

/// Font families declared in pubspec.yaml (bundled, not taken from the device).
/// Inter covers Latin; Noto Sans fills any other Latin-script glyph and Noto Sans Telugu covers Telugu.
abstract final class AppFonts {
  static const primary = 'Inter';
  static const fallback = ['NotoSans', 'NotoSansTelugu'];
}

abstract final class AppSpacing {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  /// Horizontal page gutter.
  static const page = 20.0;

  /// Card corner radius.
  static const radius = 16.0;
  static const radiusSm = 12.0;
  static const radiusLg = 24.0;
}

abstract final class AppShadows {
  static List<BoxShadow> card(Brightness b) => b == Brightness.light
      ? const [
          BoxShadow(color: Color(0x0F0B1930), blurRadius: 16, offset: Offset(0, 4)),
          BoxShadow(color: Color(0x080B1930), blurRadius: 2, offset: Offset(0, 1)),
        ]
      : const [BoxShadow(color: Color(0x40000000), blurRadius: 12, offset: Offset(0, 4))];
}

/// Colours that Material's [ColorScheme] has no slot for. Read with `context.tokens`.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.gold,
    required this.goldText,
    required this.goldSoft,
    required this.onGoldSoft,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.textSecondary,
    required this.textTertiary,
    required this.cardBorder,
    required this.heroTop,
    required this.heroBottom,
    required this.subtleFill,
    required this.featureTop,
    required this.featureBottom,
    required this.featureBorder,
  });

  final Color gold;
  final Color goldText;
  final Color goldSoft;
  final Color onGoldSoft;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;
  final Color textSecondary;
  final Color textTertiary;
  final Color cardBorder;
  final Color heroTop;
  final Color heroBottom;

  /// Tinted fill for icon badges, item-number blocks and skeletons.
  final Color subtleFill;

  /// Gradient and edge of the dark "feature" cards (My Cause List, banners).
  final Color featureTop;
  final Color featureBottom;
  final Color featureBorder;

  static const light = AppTokens(
    gold: AppColors.gold,
    goldText: AppColors.goldDeep,
    goldSoft: AppColors.goldSoft,
    onGoldSoft: Color(0xFF5A4317),
    success: AppColors.success,
    warning: AppColors.warning,
    danger: AppColors.danger,
    info: AppColors.navyLight,
    textSecondary: AppColors.textSecondary,
    textTertiary: AppColors.textTertiary,
    cardBorder: AppColors.divider,
    heroTop: AppColors.navy,
    heroBottom: AppColors.navyDeep,
    subtleFill: Color(0xFFEEF1F6),
    featureTop: AppColors.navy,
    featureBottom: AppColors.navyDeep,
    featureBorder: Color(0x00000000),
  );

  static const dark = AppTokens(
    gold: AppColors.gold,
    goldText: AppColors.goldLight,
    goldSoft: Color(0xFF2E2719),
    onGoldSoft: Color(0xFFEBD3A0),
    success: Color(0xFF5FCB94),
    warning: Color(0xFFF0AE52),
    danger: Color(0xFFF2B8B5),
    info: Color(0xFFB9C3D3),
    textSecondary: AppColors.darkTextSecondary,
    textTertiary: Color(0xFF7F848D),
    cardBorder: AppColors.darkOutline,
    heroTop: Color(0xFF142035),
    heroBottom: Color(0xFF0C1220),
    subtleFill: AppColors.darkSurfaceHigh,
    featureTop: Color(0xFF242832),
    featureBottom: Color(0xFF15171C),
    featureBorder: Color(0x40C49A45),
  );

  @override
  AppTokens copyWith() => this;

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppTokens(
      gold: c(gold, other.gold),
      goldText: c(goldText, other.goldText),
      goldSoft: c(goldSoft, other.goldSoft),
      onGoldSoft: c(onGoldSoft, other.onGoldSoft),
      success: c(success, other.success),
      warning: c(warning, other.warning),
      danger: c(danger, other.danger),
      info: c(info, other.info),
      textSecondary: c(textSecondary, other.textSecondary),
      textTertiary: c(textTertiary, other.textTertiary),
      cardBorder: c(cardBorder, other.cardBorder),
      heroTop: c(heroTop, other.heroTop),
      heroBottom: c(heroBottom, other.heroBottom),
      subtleFill: c(subtleFill, other.subtleFill),
      featureTop: c(featureTop, other.featureTop),
      featureBottom: c(featureBottom, other.featureBottom),
      featureBorder: c(featureBorder, other.featureBorder),
    );
  }
}

extension AppTokensX on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>() ?? AppTokens.light;
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(
    brightness: Brightness.light,
    tokens: AppTokens.light,
    scheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.navy,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE5EAF2),
      onPrimaryContainer: AppColors.navy,
      secondary: AppColors.gold,
      onSecondary: AppColors.navyDeep,
      secondaryContainer: AppColors.goldSoft,
      onSecondaryContainer: Color(0xFF5A4317),
      error: AppColors.danger,
      onError: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Color(0xFFF9FAFC),
      surfaceContainer: Color(0xFFF2F4F7),
      surfaceContainerHigh: Color(0xFFECEFF3),
      surfaceContainerHighest: Color(0xFFE6EAF0),
      outline: AppColors.outline,
      outlineVariant: AppColors.divider,
      shadow: AppColors.navyDeep,
      surfaceTint: Colors.transparent,
    ),
    background: AppColors.background,
  );

  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    tokens: AppTokens.dark,
    scheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.goldLight,
      onPrimary: Color(0xFF1C1609),
      primaryContainer: Color(0xFF2E2719),
      onPrimaryContainer: Color(0xFFF3E3BF),
      secondary: AppColors.gold,
      onSecondary: AppColors.navyDeep,
      secondaryContainer: Color(0xFF2E2719),
      onSecondaryContainer: Color(0xFFEBD3A0),
      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
      onSurfaceVariant: AppColors.darkTextSecondary,
      surfaceContainerLowest: Color(0xFF121418),
      surfaceContainerLow: Color(0xFF15181C),
      surfaceContainer: Color(0xFF1C1F25),
      surfaceContainerHigh: AppColors.darkSurfaceHigh,
      surfaceContainerHighest: Color(0xFF2A2E36),
      outline: Color(0xFF3A3F48),
      outlineVariant: AppColors.darkOutline,
      shadow: Colors.black,
      surfaceTint: Colors.transparent,
    ),
    background: AppColors.darkBackground,
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color background,
    required AppTokens tokens,
  }) {
    final light = brightness == Brightness.light;
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      // Bundled fonts: ignore device/OEM system font overrides; Telugu glyphs fall back to Noto Sans Telugu.
      fontFamily: AppFonts.primary,
      fontFamilyFallback: AppFonts.fallback,
    );
    final t = base.textTheme.apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
    final text = t.copyWith(
      headlineMedium: t.headlineMedium?.copyWith(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.4),
      headlineSmall: t.headlineSmall?.copyWith(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.3),
      titleLarge: t.titleLarge?.copyWith(fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: -0.2),
      titleMedium: t.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.1),
      titleSmall: t.titleSmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0),
      bodyLarge: t.bodyLarge?.copyWith(fontSize: 15.5, height: 1.45, letterSpacing: 0),
      bodyMedium: t.bodyMedium?.copyWith(fontSize: 14, height: 1.42, letterSpacing: 0),
      bodySmall: t.bodySmall?.copyWith(fontSize: 12.5, height: 1.38, color: tokens.textSecondary, letterSpacing: 0),
      labelLarge: t.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0),
      labelMedium: t.labelMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      labelSmall: t.labelSmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.6),
    );
    final radius = BorderRadius.circular(AppSpacing.radiusSm);
    OutlineInputBorder inputBorder(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c, width: w),
    );
    final buttonText = text.labelLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w600);

    return base.copyWith(
      scaffoldBackgroundColor: background,
      extensions: [tokens],
      textTheme: text,
      iconTheme: IconThemeData(color: scheme.onSurface, size: 22),
      // Back / close buttons use Lucide too, so no Material glyph appears anywhere.
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (_) => const Icon(LucideIcons.arrowLeft),
        closeButtonIconBuilder: (_) => const Icon(LucideIcons.x),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: AppSpacing.page,
        iconTheme: IconThemeData(color: light ? AppColors.navy : scheme.onSurface, size: 22),
        actionsIconTheme: IconThemeData(color: light ? AppColors.navy : scheme.onSurface, size: 22),
        systemOverlayStyle: light ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
        titleTextStyle: text.titleLarge?.copyWith(color: light ? AppColors.navy : scheme.onSurface, fontSize: 18.5),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          side: BorderSide(color: tokens.cardBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: text.bodyMedium?.copyWith(color: tokens.textTertiary),
        labelStyle: text.bodyMedium?.copyWith(color: tokens.textSecondary),
        floatingLabelStyle: text.bodyMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w600),
        prefixIconColor: tokens.textSecondary,
        suffixIconColor: tokens.textSecondary,
        border: inputBorder(scheme.outline),
        enabledBorder: inputBorder(scheme.outline),
        focusedBorder: inputBorder(scheme.primary, 1.5),
        errorBorder: inputBorder(scheme.error),
        focusedErrorBorder: inputBorder(scheme.error, 1.5),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.primary.withValues(alpha: .35),
          disabledForegroundColor: scheme.onPrimary.withValues(alpha: .9),
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          // A button textStyle replaces the inherited style entirely, so derive it from the
          // text theme to keep the bundled font (a bare TextStyle falls back to the device font).
          textStyle: text.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(64, 48),
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: buttonText?.copyWith(fontSize: 14),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: scheme.primary,
          backgroundColor: scheme.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: buttonText,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: radius)),
      ),
      chipTheme: ChipThemeData(
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? scheme.primary : scheme.surface,
        ),
        side: WidgetStateBorderSide.resolveWith(
          (s) =>
              s.contains(WidgetState.selected) ? BorderSide(color: scheme.primary) : BorderSide(color: scheme.outline),
        ),
        // Chips resolve only the label *colour* by state, so the style itself stays a plain TextStyle
        // (keeps the bundled font) with a state-dependent colour.
        labelStyle: text.labelLarge!.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: WidgetStateColor.resolveWith(
            (s) => s.contains(WidgetState.selected) ? scheme.onPrimary : scheme.onSurface,
          ),
        ),
        iconTheme: IconThemeData(color: scheme.primary, size: 16),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          visualDensity: VisualDensity.standard,
          minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? scheme.primary : scheme.surface,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? scheme.onPrimary : tokens.textSecondary,
          ),
          iconColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? scheme.onPrimary : tokens.textSecondary,
          ),
          side: WidgetStatePropertyAll(BorderSide(color: scheme.outline)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: radius)),
          textStyle: WidgetStatePropertyAll(text.labelLarge?.copyWith(fontSize: 13.5)),
          iconSize: const WidgetStatePropertyAll(18),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        indicatorColor: tokens.goldSoft,
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            size: 22,
            color: s.contains(WidgetState.selected) ? (light ? AppColors.navy : scheme.primary) : tokens.textTertiary,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => text.labelMedium?.copyWith(
            fontSize: 11.5,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: s.contains(WidgetState.selected) ? (light ? AppColors.navy : scheme.primary) : tokens.textSecondary,
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: light ? AppColors.navy : scheme.primary,
        unselectedLabelColor: tokens.textSecondary,
        indicatorColor: tokens.gold,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: scheme.outlineVariant,
        labelStyle: text.titleSmall,
        unselectedLabelStyle: text.titleSmall?.copyWith(fontWeight: FontWeight.w500),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: tokens.textSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        minLeadingWidth: 24,
        titleTextStyle: text.bodyLarge?.copyWith(fontWeight: FontWeight.w500, fontSize: 15),
        subtitleTextStyle: text.bodySmall,
      ),
      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.transparent : scheme.outline,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: text.titleLarge,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: radius),
        textStyle: text.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: light ? AppColors.navyDeep : AppColors.darkSurfaceHigh,
        contentTextStyle: text.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        highlightElevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        extendedTextStyle: buttonText,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: light ? AppColors.navy : scheme.primary,
        linearTrackColor: tokens.subtleFill,
        circularTrackColor: Colors.transparent,
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: tokens.danger,
        textColor: light ? Colors.white : AppColors.navyDeep,
        textStyle: text.labelSmall?.copyWith(fontSize: 10, letterSpacing: 0),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1, thickness: 1),
    );
  }
}
