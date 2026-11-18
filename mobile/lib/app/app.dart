import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../features/authentication/session_controller.dart';
import '../features/notifications/push_service.dart';
import '../features/settings/app_settings.dart';
import '../l10n/gen/app_localizations.dart';
import '../routing/app_router.dart';
import '../theme/app_theme.dart';

class AdvocateMateApp extends ConsumerWidget {
  const AdvocateMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(appSettingsProvider);
    ref.listen(sessionProvider, (prev, next) {
      if (next is SessionSignedIn && prev is! SessionSignedIn) {
        ref.read(pushServiceProvider).onSignedIn(router);
      }
      if (next is SessionSignedOut && next.reason == 'expired') {
        final ctx = router.routerDelegate.navigatorKey.currentContext;
        if (ctx != null) {
          ScaffoldMessenger.maybeOf(ctx)?.showSnackBar(SnackBar(content: Text(AppLocalizations.of(ctx).sessionExpired)));
        }
      }
    });
    return MaterialApp.router(
      title: 'AdvocateMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      // material_ui's bundle includes Material, Widgets and Cupertino delegates for every
      // supported locale (incl. Telugu), avoiding the deprecated flutter_localizations ones.
      localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
      routerConfig: router,
      builder: (context, child) {
        // Respect the user's accessibility text size, within a readable range.
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(textScaler: mq.textScaler.clamp(minScaleFactor: 1.0, maxScaleFactor: 1.6)),
          child: child!,
        );
      },
    );
  }
}
