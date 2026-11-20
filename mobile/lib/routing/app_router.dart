import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../features/advocate_profile/profile_screen.dart';
import '../features/authentication/advocate_code_screen.dart';
import '../features/authentication/login_screen.dart';
import '../features/authentication/session_controller.dart';
import '../features/authentication/splash_screen.dart';
import '../features/case_details/case_details_screen.dart';
import '../features/case_search/search_screen.dart';
import '../features/court_wise_cases/court_wise_screen.dart';
import '../features/daily_cause_list/daily_cause_list_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/dashboard/home_shell.dart';
import '../features/dashboard/more_screen.dart';
import '../features/favourites/favourites_screen.dart';
import '../features/live_courts/live_courts_screen.dart';
import '../features/my_cause_list/my_cause_list_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/pdf_viewer/pdf_viewer_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/passed_over_list/passed_over_screen.dart';
import '../features/supplementary_cause_list/supplementary_cause_list_screen.dart';
import '../features/weekly_cause_list/weekly_cause_list_screen.dart';

/// Maps `advocatemate://...` notification deep links to in-app locations.
String? deepLinkToLocation(String? link) {
  if (link == null || link.isEmpty) return null;
  final uri = Uri.tryParse(link);
  if (uri == null || uri.scheme != 'advocatemate') return null;
  final segs = [uri.host, ...uri.pathSegments].where((s) => s.isNotEmpty).toList();
  final q = uri.query.isEmpty ? '' : '?${uri.query}';
  if (segs.length == 2 && segs[0] == 'cases') return '/cases/${segs[1]}';
  if (segs.length == 3 && segs[0] == 'cause-list' && segs[1] == 'advocate') return '/advocate/${segs[2]}$q';
  if (segs.length == 2 && segs[0] == 'cause-list' && ['daily', 'weekly', 'supplementary'].contains(segs[1])) {
    return '/cause-list/${segs[1]}$q';
  }
  if (segs.length == 1 && segs[0] == 'notifications') return '/notifications';
  if (segs.length == 1 && segs[0] == 'live') return '/live';
  return null;
}

class _SessionListenable extends ChangeNotifier {
  void ping() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = _SessionListenable();
  ref.listen(sessionProvider, (_, _) => listenable.ping());
  ref.onDispose(listenable.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: listenable,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final loc = state.matchedLocation;
      if (session is SessionUnknown) return loc == '/splash' ? null : '/splash';
      if (session is SessionSignedOut) return loc == '/login' ? null : '/login';
      if (session is SessionNeedsAdvocateCode) return loc == '/link-advocate' ? null : '/link-advocate';
      if (loc == '/login' || loc == '/splash' || loc == '/link-advocate') return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/link-advocate', builder: (_, _) => const AdvocateCodeScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/', builder: (_, _) => const DashboardScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/my-list', builder: (_, _) => const MyCauseListScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/search', builder: (_, _) => const SearchScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/saved', builder: (_, _) => const FavouritesScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/more', builder: (_, _) => const MoreScreen())]),
        ],
      ),
      GoRoute(
          path: '/cause-list/daily',
          builder: (_, s) => DailyCauseListScreen(initialDate: DateTime.tryParse(s.uri.queryParameters['date'] ?? ''))),
      GoRoute(
          path: '/cause-list/weekly',
          builder: (_, s) => WeeklyCauseListScreen(initialDate: DateTime.tryParse(s.uri.queryParameters['date'] ?? ''))),
      GoRoute(
          path: '/cause-list/supplementary',
          builder: (_, s) =>
              SupplementaryCauseListScreen(initialDate: DateTime.tryParse(s.uri.queryParameters['date'] ?? ''))),
      GoRoute(
          path: '/cause-list/passed-over',
          builder: (_, s) => PassedOverScreen(initialDate: DateTime.tryParse(s.uri.queryParameters['date'] ?? ''))),
      GoRoute(
        path: '/court/:type/:court',
        builder: (_, s) => CourtWiseScreen(
          listType: s.pathParameters['type']!,
          courtNo: s.pathParameters['court']!,
          isoDate: s.uri.queryParameters['date']!,
        ),
      ),
      GoRoute(path: '/cases/:id', builder: (_, s) => CaseDetailsScreen(caseId: s.pathParameters['id'])),
      GoRoute(path: '/case', builder: (_, s) => CaseDetailsScreen(caseNumber: s.uri.queryParameters['number'])),
      GoRoute(
        path: '/advocate/:code',
        builder: (_, s) => MyCauseListScreen(
          advocateCode: s.pathParameters['code'],
          initialDate: DateTime.tryParse(s.uri.queryParameters['date'] ?? ''),
        ),
      ),
      GoRoute(path: '/pdf', builder: (_, s) => PdfViewerScreen(request: PdfRequest.fromQuery(s.uri.queryParameters))),
      GoRoute(path: '/live', builder: (_, _) => const LiveCourtsScreen()),
      GoRoute(path: '/notifications', builder: (_, _) => const NotificationsScreen()),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
    ],
  );
});
