import 'package:advocatemate/features/authentication/session_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../support/fake_backend.dart';
import '../support/pump_app.dart';

void main() {
  testWidgets('login: code -> confirm identity -> mobile -> OTP -> dashboard', (tester) async {
    final deps = await makeDeps();
    final c = await pumpApp(tester, deps);
    expect(find.text('Sign in'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('advocateCodeField')), '12345');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('advocateNameText')), findsOneWidget);
    expect(find.text('ADVOCATE ONE'), findsOneWidget);

    await tester.tap(find.text('Yes, this is me'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('mobileField')), '9876543210');
    await tester.tap(find.text('Send OTP'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Development build: OTP is 123456'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('otpField')), '000000');
    await tester.tap(find.text('Verify & sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Incorrect OTP'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('otpField')), '123456');
    await tester.tap(find.text('Verify & sign in'));
    await tester.pumpAndSettle();
    expect(c.read(sessionProvider), isA<SessionSignedIn>());
    expect(find.text('Welcome, ADVOCATE ONE'), findsOneWidget);
    expect(deps.tokens.tokens?.accessToken, 'acc');
  });

  testWidgets('dashboard shows my list summary, publication status and unread badge', (tester) async {
    final deps = await makeDeps(signedIn: true);
    await pumpApp(tester, deps);
    expect(find.text('Welcome, ADVOCATE ONE'), findsOneWidget);
    expect(find.text('3 cases'), findsOneWidget);
    expect(find.text('UPLOADED · 2'), findsOneWidget);
    expect(find.text('Court 3 · 2'), findsOneWidget);
    expect(find.text('1'), findsWidgets); // unread badge
  });

  testWidgets('my cause list groups by court and filters by search', (tester) async {
    final deps = await makeDeps(signedIn: true);
    await pumpApp(tester, deps, goTo: '/my-list');
    expect(find.text('My Cause List'), findsWidgets);
    expect(find.text('WP/11111/2026'), findsOneWidget);
    expect(find.text('CMA/506/2012'), findsOneWidget);
    expect(find.textContaining('IA/1/2026 – Condone Delay Petition'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'alpha');
    await tester.pumpAndSettle();
    expect(find.text('WP/11111/2026'), findsOneWidget);
    expect(find.text('CMA/506/2012'), findsNothing);
  });

  for (final (route, type, title) in [
    ('/cause-list/daily', 'D', 'Daily Cause List'),
    ('/cause-list/weekly', 'W', 'Weekly Cause List'),
    ('/cause-list/supplementary', 'S', 'Supplementary Cause List'),
  ]) {
    testWidgets('$title uses list type $type only', (tester) async {
      final deps = await makeDeps(signedIn: true);
      await pumpApp(tester, deps, goTo: route);
      expect(find.text(title), findsOneWidget);
      expect(find.text('COURT NO. 3'), findsOneWidget);
      final listCalls = deps.backend.paths().where((p) => p.contains('/cause-list/courts') || p.contains('/cause-list/dates'));
      expect(listCalls, isNotEmpty);
      expect(listCalls.every((p) => p.contains('list_type=$type')), isTrue);
    });
  }

  testWidgets('court-wise listing keeps source order and opens case details', (tester) async {
    final deps = await makeDeps(signedIn: true);
    final c = await pumpApp(tester, deps, goTo: '/court/D/3?date=2026-11-18');
    expect(find.text('THE HONOURABLE SMT JUSTICE SAMPLE JUDGE'), findsOneWidget);
    final y1 = tester.getTopLeft(find.text('WP/11111/2026')).dy;
    final y2 = tester.getTopLeft(find.text('WP/333/2017')).dy;
    final y3 = tester.getTopLeft(find.text('WP/444/2018')).dy;
    expect(y1 < y2 && y2 < y3, isTrue);
    await tester.enterText(find.byType(TextField).first, 'delta');
    await tester.pumpAndSettle();
    expect(find.text('WP/11111/2026'), findsNothing);
    expect(find.text('WP/444/2018'), findsOneWidget);
    await tester.tap(find.text('WP/444/2018'));
    await tester.pumpAndSettle();
    expect(routerOf(c).state.uri.path, '/cases/c5');
  });

  testWidgets('case details: pending enrichment does not block, then completes via polling', (tester) async {
    final deps = await makeDeps(signedIn: true);
    final c = await pumpApp(tester, deps);
    routerOf(c).go('/cases/c1');
    // Spinner animates while pending, so pump fixed frames instead of settling.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('WP/11111/2026'), findsWidgets);
    expect(find.byKey(const Key('enrichment-pending')), findsOneWidget);
    expect(find.text('Not yet available'), findsOneWidget); // parties not invented while pending
    await tester.pump(const Duration(seconds: 2)); // first poll after 2 s backoff
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('enrichment-completed')), findsOneWidget);
    expect(find.text('The District Collector.,'), findsOneWidget);
    expect(find.text('ADVOCATE ONE'), findsOneWidget);
    expect(find.text('Official order PDFs are not available yet.'), findsOneWidget);
  });

  testWidgets('live board current vs stale', (tester) async {
    final deps = await makeDeps(signedIn: true);
    await pumpApp(tester, deps, goTo: '/live');
    expect(find.text('Live'), findsOneWidget);
    expect(find.text('D-52'), findsOneWidget);
    expect(find.byKey(const Key('liveStaleBanner')), findsNothing);

    deps.backend.on('GET', '/live-courts', (_) => {
          'fetched_at': '2026-11-18T05:00:00Z', 'age_seconds': 4000, 'stale': true, 'is_current': false,
          'courts': [{'court_no': '1', 'state': 'in_progress', 'current_item': 'D-52', 'pending_serials': []}],
          'note': 'This display data is out of date. It is NOT the current court position.'});
    await tester.tap(find.byTooltip('Refresh'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('liveStaleBanner')), findsOneWidget);
    expect(find.text('Not current'), findsOneWidget);
  });

  testWidgets('offline shows saved data with the required notice', (tester) async {
    final deps = await makeDeps(signedIn: true);
    final c = await pumpApp(tester, deps, goTo: '/court/D/3?date=2026-11-18');
    expect(find.text('WP/11111/2026'), findsOneWidget);
    routerOf(c).go('/');
    await tester.pumpAndSettle();
    deps.backend.offline = true;
    routerOf(c).go('/court/D/3?date=2026-11-18');
    await tester.pumpAndSettle();
    expect(find.textContaining('Showing saved information. This data may not be current.'), findsOneWidget);
    expect(find.text('WP/11111/2026'), findsOneWidget);
  });

  testWidgets('favourites: saved cases listed, advocate can be added', (tester) async {
    final deps = await makeDeps(signedIn: true);
    await pumpApp(tester, deps, goTo: '/saved');
    expect(find.text('WP/11111/2026'), findsOneWidget);
    await tester.tap(find.text('Favourite Advocates'));
    await tester.pumpAndSettle();
    expect(find.text('Nothing saved yet.'), findsOneWidget);
    await tester.tap(find.text('Add advocate'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '67890');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('ADVOCATE TWO'), findsOneWidget);
  });

  testWidgets('notification tap marks read and deep-links to the case', (tester) async {
    final deps = await makeDeps(signedIn: true);
    final c = await pumpApp(tester, deps, goTo: '/notifications');
    expect(find.text('Case details updated'), findsOneWidget);
    await tester.tap(find.text('Case details updated'));
    await tester.pumpAndSettle();
    expect(deps.backend.paths().any((p) => p.startsWith('POST /api/v1/notifications/read')), isTrue);
    expect(routerOf(c).state.uri.path, '/cases/c1');
  });

  testWidgets('search returns results and navigates', (tester) async {
    final deps = await makeDeps(signedIn: true);
    final c = await pumpApp(tester, deps, goTo: '/search');
    await tester.enterText(find.byKey(const Key('searchField')), 'gamma');
    await tester.tap(find.widgetWithText(FilledButton, 'Search Cases'));
    await tester.pumpAndSettle();
    expect(find.text('WP/333/2017'), findsOneWidget);
    await tester.tap(find.text('WP/333/2017'));
    await tester.pumpAndSettle();
    expect(routerOf(c).state.uri.path, '/cases/c4');
  });

  testWidgets('bottom navigation switches sections', (tester) async {
    final deps = await makeDeps(signedIn: true);
    final c = await pumpApp(tester, deps);
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(routerOf(c).state.uri.path, '/search');
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.text('Log out'), findsOneWidget);
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
    expect(deps.tokens.tokens, isNull);
  });

  testWidgets('expired session returns to sign-in', (tester) async {
    final deps = await makeDeps(signedIn: true);
    deps.backend.on('GET', '/auth/me', (_) => apiError(401, 'session_revoked', 'revoked'));
    deps.backend.on('POST', '/auth/refresh', (_) => apiError(401, 'refresh_reused', 'reused'));
    await pumpApp(tester, deps);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('generated PDF is labelled as not official', (tester) async {
    final deps = await makeDeps(signedIn: true);
    final c = await pumpApp(tester, deps);
    routerOf(c).go('/pdf?kind=summary&case=c1');
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    // The label is shown before/independently of the download completing.
    expect(find.byKey(const Key('generatedNotice')), findsOneWidget);
    expect(find.textContaining('NOT an official court document'), findsOneWidget);
  });

  testWidgets('Telugu localisation renders', (tester) async {
    final deps = await makeDeps(signedIn: true);
    await deps.prefs.setLanguageCode('te');
    await pumpApp(tester, deps);
    expect(find.text('హోమ్'), findsOneWidget);
    expect(find.textContaining('స్వాగతం'), findsOneWidget);
  });
}
