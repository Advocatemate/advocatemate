import 'package:advocatemate/app/app.dart';
import 'package:advocatemate/routing/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' show Size;

import 'fake_backend.dart';

/// Pumps the real app (router, theme, l10n) on top of the fake backend.
Future<ProviderContainer> pumpApp(WidgetTester tester, TestDeps deps, {String? goTo}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.6;
  addTearDown(tester.view.reset);
  final container = ProviderContainer(overrides: deps.overrides, retry: (_, _) => null);
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const AdvocateMateApp()));
  await tester.pumpAndSettle();
  if (goTo != null) {
    container.read(routerProvider).go(goTo);
    await tester.pumpAndSettle();
  }
  return container;
}

GoRouter routerOf(ProviderContainer c) => c.read(routerProvider);
