import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../support/fake_backend.dart';
import '../support/pump_app.dart';

Map<String, Object?> _other(String? date, {bool offered = true}) => {
      'advocate_code': '67890',
      'advocate_name': 'ADVOCATE TWO',
      'list_date': date,
      'date_offered_by_source': offered,
      'available_dates': ['2026-11-19', '2026-11-18'],
      'total_cases': offered ? 1 : 0,
      'fetched_at': '2026-11-19T08:00:00Z',
      'stale': false,
      'courts': offered
          ? [
              {
                'court_no': '7',
                'cases': [
                  {'item_no': '12', 'court_no': '7', 'list_type': 'Daily', 'raw_case': 'WP/777/2026',
                    'case_number': 'WP/777/2026', 'case_id': 'c7', 'petitioner': 'PETITIONER SEVEN',
                    'respondent': 'RESPONDENT SEVEN'},
                ]
              }
            ]
          : <Object>[],
    };

Future<void> _openAdvocateView(WidgetTester tester) async {
  await tester.tap(find.text('Advocate code'));
  await tester.pumpAndSettle();
}

Future<void> _lookUp(WidgetTester tester, String code) async {
  await tester.enterText(find.byKey(const Key('advocateLookupField')), code);
  await tester.tap(find.byKey(const Key('advocateLookupButton')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('daily list opens court-wise and switches to advocate code-wise', (tester) async {
    final deps = await makeDeps(signedIn: true);
    await pumpApp(tester, deps, goTo: '/cause-list/daily');
    expect(find.byKey(const Key('dailyViewSwitch')), findsOneWidget);
    expect(find.text('COURT NO. 3'), findsOneWidget); // court-wise by default, unchanged
    await _openAdvocateView(tester);
    expect(find.byKey(const Key('advocateLookupField')), findsOneWidget);
    expect(find.text("Enter any advocate's code to see their cases in the cause list."), findsOneWidget);
    expect(find.text('COURT NO. 3'), findsNothing);
    await tester.tap(find.text('Court-wise'));
    await tester.pumpAndSettle();
    expect(find.text('COURT NO. 3'), findsOneWidget);
  });

  testWidgets("another advocate's cases by code, latest offered date, recent and save", (tester) async {
    final deps = await makeDeps(signedIn: true);
    deps.backend.on('GET', '/cause-list/advocate/67890',
        (r) => _other(r.queryParameters['date'], offered: r.queryParameters['date'] == '2026-11-19'));
    final c = await pumpApp(tester, deps, goTo: '/cause-list/daily');
    await _openAdvocateView(tester);
    await _lookUp(tester, '67890');

    expect(find.byKey(const Key('advocateLookupTitle')), findsOneWidget);
    expect(find.text('ADVOCATE TWO'), findsOneWidget);
    // today is not offered by the source yet, so the latest offered date is shown
    expect(deps.backend.paths().any((p) => p.contains('/cause-list/advocate/67890?date=2026-11-19')), isTrue);
    expect(find.text('WP/777/2026'), findsOneWidget);
    expect(find.byKey(const Key('recentAdvocate-67890')), findsOneWidget);
    expect(deps.prefs.recentAdvocateCodes, ['67890']);

    await tester.tap(find.byKey(const Key('favouriteAdvocateToggle')));
    await tester.pumpAndSettle();
    expect(deps.backend.paths().any((p) => p == 'POST /favourites/advocates' || p.endsWith('/favourites/advocates')), isTrue);
    expect(find.byIcon(Icons.star), findsOneWidget);

    await tester.tap(find.text('WP/777/2026'));
    await tester.pumpAndSettle();
    expect(routerOf(c).state.uri.path, '/cases/c7');
  });

  testWidgets('unknown code shows a clear message', (tester) async {
    final deps = await makeDeps(signedIn: true);
    deps.backend.on('GET', '/cause-list/advocate/99999', (_) => apiError(404, 'advocate_not_found',
        'No advocate was found for this advocate code. Check the code and try again.'));
    await pumpApp(tester, deps, goTo: '/cause-list/daily');
    await _openAdvocateView(tester);
    await _lookUp(tester, '99999');
    expect(find.text('No advocate was found for this code. Check the code and try again.'), findsOneWidget);
  });

  testWidgets('too many lookups shows its own message', (tester) async {
    final deps = await makeDeps(signedIn: true);
    deps.backend.on('GET', '/cause-list/advocate/55555',
        (_) => apiError(429, 'advocate_lookup_limited', 'Too many advocate lookups.'));
    await pumpApp(tester, deps, goTo: '/cause-list/daily');
    await _openAdvocateView(tester);
    await _lookUp(tester, '55555');
    expect(find.text('Too many advocate lookups. Please wait a few minutes and try again.'), findsOneWidget);
  });

  testWidgets('empty code is not looked up', (tester) async {
    final deps = await makeDeps(signedIn: true);
    await pumpApp(tester, deps, goTo: '/cause-list/daily');
    await _openAdvocateView(tester);
    await _lookUp(tester, '');
    expect(find.text('Enter digits only (up to 8).'), findsOneWidget);
    // (the dashboard loads the signed-in advocate's own list, 12345, in the background)
    expect(deps.backend.paths().where((p) => p.contains('/cause-list/advocate/') && !p.contains('/12345')), isEmpty);
  });

  testWidgets('link with view=advocate and a code opens straight to that advocate', (tester) async {
    final deps = await makeDeps(signedIn: true);
    deps.backend.on('GET', '/cause-list/advocate/67890', (r) => _other(r.queryParameters['date']));
    await pumpApp(tester, deps, goTo: '/cause-list/daily?view=advocate&code=67890');
    expect(find.text('ADVOCATE TWO'), findsOneWidget);
    expect(find.text('WP/777/2026'), findsOneWidget);
  });
}
