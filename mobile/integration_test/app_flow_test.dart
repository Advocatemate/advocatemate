// End-to-end flows on a real device/emulator/simulator:
//   flutter test integration_test -d <device>
// Uses the in-memory fake backend so runs are deterministic and never touch APHC.
import 'dart:typed_data';

import 'package:advocatemate/features/authentication/session_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';

import '../test/support/fake_backend.dart';
import '../test/support/pump_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('authentication to dashboard', (tester) async {
    final deps = await makeDeps();
    final c = await pumpApp(tester, deps);
    await tester.enterText(find.byKey(const Key('advocateCodeField')), '12345');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes, this is me'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('mobileField')), '9876543210');
    await tester.tap(find.text('Send OTP'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('otpField')), '123456');
    await tester.tap(find.text('Verify & sign in'));
    await tester.pumpAndSettle();
    expect(c.read(sessionProvider), isA<SessionSignedIn>());
    expect(find.text('Welcome, ADVOCATE ONE'), findsOneWidget);
  });

  testWidgets('advocate cause list -> case details -> enrichment completion', (tester) async {
    final deps = await makeDeps(signedIn: true);
    final c = await pumpApp(tester, deps, goTo: '/my-list');
    expect(find.text('WP/11111/2026'), findsOneWidget);
    await tester.tap(find.text('WP/11111/2026'));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(routerOf(c).state.uri.path, '/cases/c1');
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('enrichment-completed')), findsOneWidget);
  });

  testWidgets('notification navigation', (tester) async {
    final deps = await makeDeps(signedIn: true);
    final c = await pumpApp(tester, deps, goTo: '/notifications');
    await tester.tap(find.text('Case details updated'));
    await tester.pumpAndSettle();
    expect(routerOf(c).state.uri.path, '/cases/c1');
  });

  testWidgets('PDF retrieval shows download then viewer or error', (tester) async {
    final deps = await makeDeps(signedIn: true);
    deps.backend.on('GET', '/cause-list/weekly.pdf', (_) => FakeResponse(200,
        Uint8List.fromList('%PDF-1.4\n%%EOF'.codeUnits), headers: {'content-type': ['application/pdf'],
        'x-document-official': ['true']}));
    final c = await pumpApp(tester, deps);
    routerOf(c).go('/pdf?kind=weekly');
    await tester.pump(const Duration(seconds: 2));
    expect(deps.backend.paths().any((p) => p.contains('/cause-list/weekly.pdf')), isTrue);
    expect(find.byKey(const Key('generatedNotice')), findsNothing); // official PDF is not labelled generated
  });
}
