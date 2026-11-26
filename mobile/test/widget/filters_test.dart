import 'dart:ui' show Tristate;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../support/fake_backend.dart';
import '../support/pump_app.dart';

bool _chipSelected(WidgetTester tester, Finder chip) => tester.widget<ChoiceChip>(chip).selected;

void main() {
  testWidgets('Live Court Display: All is the default, a court filters, All resets', (tester) async {
    final deps = await makeDeps(signedIn: true);
    await pumpApp(tester, deps, goTo: '/live');
    final all = find.byKey(const Key('filterAll'));
    expect(find.descendant(of: all, matching: find.text('All')), findsOneWidget);
    expect(find.text('Filters'), findsNothing);
    expect(_chipSelected(tester, all), isTrue);
    expect(find.text('Court 1'), findsOneWidget);
    expect(find.text('Court 21'), findsOneWidget);

    final court21 = find.widgetWithText(ChoiceChip, '21');
    await tester.tap(court21);
    await tester.pumpAndSettle();
    expect(_chipSelected(tester, court21), isTrue);
    expect(_chipSelected(tester, all), isFalse);
    expect(find.text('Court 1'), findsNothing);
    expect(find.text('Court 21'), findsOneWidget);

    await tester.tap(all);
    await tester.pumpAndSettle();
    expect(_chipSelected(tester, all), isTrue);
    expect(find.text('Court 1'), findsOneWidget);
    expect(find.text('Court 21'), findsOneWidget);
  });

  testWidgets('Court-wise listing: All is the default stage, a stage filters, All resets', (tester) async {
    final deps = await makeDeps(signedIn: true);
    await pumpApp(tester, deps, goTo: '/court/D/3?date=2026-11-18');
    final all = find.byKey(const Key('filterAll'));
    expect(find.descendant(of: all, matching: find.text('All')), findsOneWidget);
    expect(_chipSelected(tester, all), isTrue);
    expect(find.text('WP/11111/2026'), findsOneWidget); // ADMISSION
    expect(find.text('WP/333/2017'), findsOneWidget); // REVENUE

    final revenue = find.widgetWithText(ChoiceChip, 'REVENUE');
    await tester.tap(revenue);
    await tester.pumpAndSettle();
    expect(_chipSelected(tester, revenue), isTrue);
    expect(find.text('WP/11111/2026'), findsNothing);
    expect(find.text('WP/333/2017'), findsOneWidget);

    await tester.tap(all);
    await tester.pumpAndSettle();
    expect(_chipSelected(tester, all), isTrue);
    expect(find.text('WP/11111/2026'), findsOneWidget);
    expect(find.text('WP/333/2017'), findsOneWidget);
  });

  testWidgets('My Cause List: All pill is the default, a court pill filters, All resets', (tester) async {
    final deps = await makeDeps(signedIn: true);
    await pumpApp(tester, deps, goTo: '/my-list');
    final all = find.byKey(const Key('filterAll'));
    expect(find.descendant(of: all, matching: find.text('All')), findsOneWidget);
    bool selected(Finder f) => tester.getSemantics(f).flagsCollection.isSelected == Tristate.isTrue;
    expect(selected(all), isTrue);
    expect(find.text('WP(PIL)/22/2025'), findsOneWidget); // Court 1
    expect(find.text('WP/11111/2026'), findsOneWidget); // Court 3

    await tester.tap(find.text('Court 3 · 2'));
    await tester.pumpAndSettle();
    expect(selected(all), isFalse);
    expect(find.text('WP(PIL)/22/2025'), findsNothing);
    expect(find.text('WP/11111/2026'), findsOneWidget);

    await tester.tap(all);
    await tester.pumpAndSettle();
    expect(selected(all), isTrue);
    expect(find.text('WP(PIL)/22/2025'), findsOneWidget);
    expect(find.text('WP/11111/2026'), findsOneWidget);
  });
}
