import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/providers.dart';
import '../../shared/models/models.dart';
import '../../shared/personal_repository.dart';
import '../../shared/widgets/widgets.dart';
import '../../theme/app_theme.dart';
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

    Widget prefRow(IconData icon, String label, bool value, ValueChanged<bool> onChanged) => MenuRow(
      icon: icon,
      label: label,
      trailing: Switch(value: value, onChanged: onChanged),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        padding: AppLayout.page(context, top: AppSpacing.sm, bottom: AppSpacing.xxl),
        children: [
          SectionHeader(l.sectionAppearance),
          AppCard(
            padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MenuRow(
                  icon: AppIcons.language,
                  label: l.language,
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: s.locale?.languageCode ?? Localizations.localeOf(context).languageCode,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      icon: const Icon(AppIcons.chevronRight, size: 16),
                      onChanged: (code) async {
                        if (code == null) return;
                        await ref.read(appSettingsProvider.notifier).setLanguage(code);
                        try {
                          final me = await ref.read(authRepositoryProvider).updateMe(language: code);
                          ref.read(sessionProvider.notifier).update(me);
                        } catch (_) {}
                      },
                      items: [
                        for (final e in supportedLanguages.entries)
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                      ],
                    ),
                  ),
                ),
                const Divider(indent: 64, height: 1),
                MenuRow(icon: AppIcons.theme, label: l.theme),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    expandedInsets: EdgeInsets.zero,
                    segments: [
                      ButtonSegment(value: ThemeMode.system, label: Text(l.themeSystem)),
                      ButtonSegment(value: ThemeMode.light, label: Text(l.themeLight)),
                      ButtonSegment(value: ThemeMode.dark, label: Text(l.themeDark)),
                    ],
                    selected: {s.themeMode},
                    onSelectionChanged: (v) => ref.read(appSettingsProvider.notifier).setThemeMode(v.first),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(l.notificationPreferences),
          prefs.when(
            data: (p) => MenuGroup(
              children: [
                prefRow(
                  AppIcons.publication,
                  l.prefPublication,
                  p.causeListPublication,
                  (v) => setPref(p.copyWith(causeListPublication: v)),
                ),
                prefRow(
                  AppIcons.advocates,
                  l.prefFavouriteAdvocates,
                  p.favouriteAdvocates,
                  (v) => setPref(p.copyWith(favouriteAdvocates: v)),
                ),
                prefRow(
                  AppIcons.caseUpdate,
                  l.prefCaseUpdates,
                  p.caseUpdates,
                  (v) => setPref(p.copyWith(caseUpdates: v)),
                ),
                prefRow(AppIcons.liveBoard, l.prefCourtBoard, p.courtBoard, (v) => setPref(p.copyWith(courtBoard: v))),
                prefRow(AppIcons.factCheck, l.prefEnrichment, p.enrichment, (v) => setPref(p.copyWith(enrichment: v))),
                prefRow(
                  AppIcons.notifications,
                  l.prefAnnouncements,
                  p.announcements,
                  (v) => setPref(p.copyWith(announcements: v)),
                ),
              ],
            ),
            error: (e, _) => MenuGroup(
              children: [MenuRow(icon: AppIcons.info, label: l.notYetAvailable)],
            ),
            loading: () => const Padding(padding: EdgeInsets.all(AppSpacing.lg), child: LinearProgressIndicator()),
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(l.sectionData),
          MenuGroup(
            children: [
              MenuRow(
                icon: AppIcons.clearData,
                label: l.clearCache,
                trailing: const SizedBox.shrink(),
                onTap: () async {
                  await ref.read(cacheStoreProvider).clear();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.cacheCleared)));
                  }
                },
              ),
              MenuRow(icon: AppIcons.info, label: l.about, subtitle: l.dataNotice),
            ],
          ),
        ],
      ),
    );
  }
}
