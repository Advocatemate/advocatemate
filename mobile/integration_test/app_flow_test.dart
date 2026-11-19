// End-to-end flows on a real device/emulator/simulator:
//   flutter test integration_test -d <device>
// Uses the in-memory fake backend so runs are deterministic and never touch APHC.
import 'dart:typed_data';

import 'package:advocatemate/features/authentication/session_controller.dart';
import 'package:advocatemate/shared/widgets/widgets.dart' show ErrorState;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';

import '../test/support/fake_backend.dart';
import '../test/support/pump_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('authentication to dashboard (Google -> advocate code -> registry check)', (tester) async {
    final deps = await makeDeps();
    final c = await pumpApp(tester, deps);
    await tester.tap(find.byKey(const Key('googleSignInButton')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('advocateCodeField')), '12345');
    await tester.tap(find.byKey(const Key('verifyAdvocateButton')));
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

  testWidgets('PDF retrieval: download completes and a damaged PDF shows an error with retry', (tester) async {
    final deps = await makeDeps(signedIn: true);
    deps.backend.on('GET', '/cause-list/weekly.pdf', (_) => FakeResponse(200,
        Uint8List.fromList('%PDF-1.4\n%%EOF'.codeUnits), headers: {'content-type': ['application/pdf'],
        'x-document-official': ['true']}));
    final c = await pumpApp(tester, deps);
    routerOf(c).go('/pdf?kind=weekly');
    bool requested() => deps.backend.paths().any((p) => p.contains('/cause-list/weekly.pdf'));
    // On a device pump(duration) does not wait in real time; the download involves real
    // platform I/O (temp directory, file write), so wait in real time instead.
    await pumpUntil(tester, requested);
    expect(requested(), isTrue);
    // The served bytes are a deliberately damaged PDF: the app must show its error state
    // (with Retry), not crash or spin forever.
    await pumpUntil(tester, () => find.byType(ErrorState).evaluate().isNotEmpty);
    expect(find.byType(ErrorState), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byKey(const Key('generatedNotice')), findsNothing); // official PDF is not labelled generated
  });
}

/// Pumps frames with real delays until [condition] holds or [timeout] passes.
Future<void> pumpUntil(WidgetTester tester, bool Function() condition,
    {Duration timeout = const Duration(seconds: 10)}) async {
  final end = DateTime.now().add(timeout);
  while (!condition() && DateTime.now().isBefore(end)) {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await tester.pump();
  }
}
