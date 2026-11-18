import 'package:advocatemate/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('light and dark themes use the bundled fonts, not the device font', () {
    for (final theme in [AppTheme.light(), AppTheme.dark()]) {
      final body = theme.textTheme.bodyMedium!;
      final title = theme.textTheme.titleLarge!;
      expect(body.fontFamily, AppFonts.primary);
      expect(title.fontFamily, AppFonts.primary);
      expect(body.fontFamilyFallback, contains('NotoSansTelugu'));
      expect(theme.appBarTheme.titleTextStyle?.fontFamily, AppFonts.primary);
    }
  });
}
