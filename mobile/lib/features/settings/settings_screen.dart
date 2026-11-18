import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/providers.dart';
import '../../shared/models/models.dart';
import '../../shared/personal_repository.dart';
import '../../shared/widgets/widgets.dart';
import '../authentication/auth_repository.dart';
import '../authentication/session_controller.dart';
import 'app_settings.dart';

final notificationPrefsProvider =
    FutureProvider.autoDispose<NotificationPrefs>((ref) => ref.watch(personalRepositoryProvider).prefs());

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(appSettingsProvider);
    final prefs = ref.watch(notificationPrefsProvider);

    Future<void> setPref(NotificationPrefs p) async {
      try {
        await ref.read(personalRepositoryProvider).savePrefs(p);
        ref.invalidate(notificationPrefsProvider);
      } catch (e) {
        if (context.mounted) showError(context, e);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(children: [
        ListTile(
          leading: const Icon(Icons.translate),
          title: Text(l.language),
          trailing: DropdownButton<String>(
            value: s.locale?.languageCode ?? Localizations.localeOf(context).languageCode,
            onChanged: (code) async {
              if (code == null) return;
              await ref.read(appSettingsProvider.notifier).setLanguage(code);
              try {
                final me = await ref.read(authRepositoryProvider).updateMe(language: code);
                ref.read(sessionProvider.notifier).update(me);
              } catch (_) {}
            },
            items: [for (final e in supportedLanguages.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.dark_mode_outlined),
          title: Text(l.theme),
          trailing: SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: ThemeMode.system, label: Text(l.themeSystem)),
              ButtonSegment(value: ThemeMode.light, label: Text(l.themeLight)),
              ButtonSegment(value: ThemeMode.dark, label: Text(l.themeDark)),
            ],
            selected: {s.themeMode},
            onSelectionChanged: (v) => ref.read(appSettingsProvider.notifier).setThemeMode(v.first),
          ),
        ),
        const Divider(),
        ListTile(title: Text(l.notificationPreferences, style: Theme.of(context).textTheme.titleSmall)),
        prefs.when(
          data: (p) => Column(children: [
            SwitchListTile(
                title: Text(l.prefPublication),
                value: p.causeListPublication,
                onChanged: (v) => setPref(p.copyWith(causeListPublication: v))),
            SwitchListTile(
                title: Text(l.prefFavouriteAdvocates),
                value: p.favouriteAdvocates,
                onChanged: (v) => setPref(p.copyWith(favouriteAdvocates: v))),
            SwitchListTile(
                title: Text(l.prefCaseUpdates), value: p.caseUpdates, onChanged: (v) => setPref(p.copyWith(caseUpdates: v))),
            SwitchListTile(
                title: Text(l.prefCourtBoard), value: p.courtBoard, onChanged: (v) => setPref(p.copyWith(courtBoard: v))),
            SwitchListTile(
                title: Text(l.prefEnrichment), value: p.enrichment, onChanged: (v) => setPref(p.copyWith(enrichment: v))),
            SwitchListTile(
                title: Text(l.prefAnnouncements),
                value: p.announcements,
                onChanged: (v) => setPref(p.copyWith(announcements: v))),
          ]),
          error: (e, _) => ListTile(title: Text(l.notYetAvailable)),
          loading: () => const LinearProgressIndicator(),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.cleaning_services_outlined),
          title: Text(l.clearCache),
          onTap: () async {
            await ref.read(cacheStoreProvider).clear();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.cacheCleared)));
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(l.about),
          subtitle: Text(l.dataNotice),
        ),
      ]),
    );
  }
}
