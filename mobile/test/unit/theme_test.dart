import 'package:advocatemate/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

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

  // Button themes replace (not merge) the inherited text style, so check what is actually rendered.
  for (final (name, theme) in [('light', AppTheme.light()), ('dark', AppTheme.dark())]) {
    testWidgets('all button types render with the bundled font ($name theme)', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Column(children: [
            FilledButton(onPressed: () {}, child: const Text('filled')),
            TextButton(onPressed: () {}, child: const Text('text')),
            OutlinedButton(onPressed: () {}, child: const Text('outlined')),
            ElevatedButton(onPressed: () {}, child: const Text('elevated')),
            ActionChip(label: const Text('chip'), onPressed: () {}),
          ]),
        ),
      ));
      for (final label in ['filled', 'text', 'outlined', 'elevated', 'chip']) {
        final rich = tester.widget<RichText>(find.descendant(of: find.text(label), matching: find.byType(RichText)));
        expect(rich.text.style?.fontFamily, AppFonts.primary, reason: '$label button font');
        expect(rich.text.style?.fontFamilyFallback, contains('NotoSansTelugu'), reason: '$label button fallback');
      }
      final filled = tester.widget<RichText>(find.descendant(of: find.text('filled'), matching: find.byType(RichText)));
      expect(filled.text.style?.fontSize, 16);
      expect(filled.text.style?.fontWeight, FontWeight.w600);
    });
  }
}
