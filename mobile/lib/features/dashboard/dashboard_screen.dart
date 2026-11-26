import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/formatters.dart';
import '../../core/loaded.dart';
import '../../shared/court_repository.dart';
import '../../shared/models/models.dart';
import '../../shared/personal_repository.dart';
import '../../shared/widgets/widgets.dart';
import '../../theme/app_theme.dart';
import '../authentication/session_controller.dart';
import '../my_cause_list/my_cause_list_screen.dart';
import '../../shared/widgets/brand_art.dart';

final publicationStatusProvider = FutureProvider.autoDispose<Loaded<PublicationStatus>>(
  (ref) => ref.watch(courtRepositoryProvider).publicationStatus(),
);

final unreadCountProvider = FutureProvider.autoDispose<int>(
  (ref) async => (await ref.watch(personalRepositoryProvider).notifications(unreadOnly: true)).unreadCount,
);

const _soft = Color(0xFFC9D2E0);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentMeProvider);
    final today = DateTime.now();
    final code = me?.advocateCode;
    final myList = code == null ? null : ref.watch(advocateCauseListProvider((code: code, date: Fmt.isoDate(today))));
    final unread = ref.watch(unreadCountProvider).value ?? 0;
    final g = AppLayout.gutter(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(publicationStatusProvider);
            ref.invalidate(unreadCountProvider);
            if (code != null) ref.invalidate(advocateCauseListProvider((code: code, date: Fmt.isoDate(today))));
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _Hero(name: me?.displayName ?? me?.advocateName ?? '', code: code, unread: unread, today: today),
              Padding(
                padding: EdgeInsets.fromLTRB(g, AppSpacing.md, g, AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeSlideIn(child: _MyListCard(value: myList)),
                    const SizedBox(height: AppSpacing.lg),
                    const FadeSlideIn(order: 1, child: _PublicationCard()),
                    const SizedBox(height: AppSpacing.xl),
                    const FadeSlideIn(order: 2, child: _QuickAccess()),
                    const SizedBox(height: AppSpacing.lg + 4),
                    const FadeSlideIn(order: 3, child: _JusticeBanner()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navy header: brand, notifications, avatar, welcome, advocate code and date over a courthouse.
class _Hero extends StatelessWidget {
  const _Hero({required this.name, required this.code, required this.unread, required this.today});
  final String name;
  final String? code;
  final int unread;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context);
    final tk = context.tokens;
    final g = AppLayout.gutter(context);
    final appName = l.appName;
    final split = appName.endsWith('Mate') ? appName.length - 4 : appName.length;
    return CustomPaint(
      painter: HeroBackgroundPainter(top: tk.heroTop, bottom: tk.heroBottom, curve: 44),
      child: Stack(
        children: [
          Positioned.fill(
            child: HeroPhoto(top: tk.heroTop, bottom: tk.heroBottom, curve: 44),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(g, AppSpacing.md, g, 64),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const BrandMark(size: 52, shadow: false),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: appName.substring(0, split)),
                                  TextSpan(
                                    text: appName.substring(split),
                                    style: const TextStyle(color: AppColors.gold),
                                  ),
                                ],
                              ),
                              style: t.textTheme.headlineSmall?.copyWith(color: Colors.white, letterSpacing: .2),
                            ),
                            Text(l.courtShortName, style: t.textTheme.bodyMedium?.copyWith(color: _soft)),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: l.notifications,
                        onPressed: () => context.push('/notifications'),
                        icon: Badge(
                          isLabelVisible: unread > 0,
                          label: Text('$unread'),
                          child: const Icon(AppIcons.notifications, color: Colors.white, size: 28),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Semantics(
                        button: true,
                        label: l.profile,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => context.push('/profile'),
                          child: AvatarInitials(name: name, size: 76, onDark: true),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.welcome(name),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: t.textTheme.headlineSmall?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: .10),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.gold, width: 1.2),
                              ),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(text: '${l.advocateCode} : '),
                                    TextSpan(
                                      text: code ?? '-',
                                      style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                style: t.textTheme.titleSmall?.copyWith(
                                  color: AppColors.goldSoft,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                const Icon(AppIcons.calendar, size: 16, color: _soft),
                                const SizedBox(width: 8),
                                Text(
                                  Fmt.displayDate(today, locale: context.localeName),
                                  style: t.textTheme.bodyMedium?.copyWith(color: _soft),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dark "My Cause List · Today" card: total, court chips, Continue.
class _MyListCard extends StatelessWidget {
  const _MyListCard({required this.value});
  final AsyncValue<Loaded<AdvocateCauseList>>? value;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context);
    final note = t.textTheme.bodySmall?.copyWith(color: _soft);
    final v = value;
    final Widget body;
    if (v == null) {
      body = Text(l.notYetAvailable, style: t.textTheme.bodyMedium?.copyWith(color: _soft));
    } else {
      body = switch (v) {
        AsyncData(:final value) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.casesCount(value.data.totalCases),
              style: t.textTheme.headlineMedium?.copyWith(color: Colors.white, fontSize: 40, letterSpacing: -0.5),
            ),
            if (value.data.courts.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [for (final c in value.data.courts) _CourtPill('${l.court(c.courtNo)} · ${c.cases.length}')],
              ),
            ],
            if (!value.data.dateOfferedBySource)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(l.dateNotOffered, style: note),
              ),
            if (!value.isCurrent)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(l.offlineBanner, style: note?.copyWith(color: const Color(0xFFF0C27A))),
              ),
          ],
        ),
        AsyncError() => Text(l.errorGeneric, style: t.textTheme.bodyMedium?.copyWith(color: _soft)),
        _ => const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: LinearProgressIndicator(color: AppColors.gold, backgroundColor: Color(0x22FFFFFF)),
        ),
      };
    }
    final br = BorderRadius.circular(22);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: br,
        border: Border.all(color: context.tokens.featureBorder),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [context.tokens.featureTop, context.tokens.featureBottom],
        ),
        boxShadow: const [BoxShadow(color: Color(0x330B1930), blurRadius: 18, offset: Offset(0, 8))],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: br,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.go('/my-list'),
          child: Stack(
            children: [
              Positioned(
                right: 18,
                top: 70,
                child: ExcludeSemantics(
                  child: Opacity(opacity: .10, child: Image.asset('assets/images/logo.png', width: 104, height: 104)),
                ),
              ),
              const Positioned(
                right: 0,
                bottom: 0,
                width: 150,
                height: 70,
                child: CustomPaint(painter: GoldSwooshPainter()),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg + 4, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const BrandMark(size: 32, shadow: false),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Semantics(
                            header: true,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${l.myCauseList} · ${l.today}',
                                maxLines: 1,
                                style: t.textTheme.titleMedium?.copyWith(color: Colors.white, fontSize: 17),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        OutlinedButton(
                          onPressed: () => context.go('/my-list'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 38),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            side: const BorderSide(color: AppColors.gold),
                            shape: const StadiumBorder(),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(l.continueAction),
                              const SizedBox(width: 6),
                              const Icon(AppIcons.arrowRight, size: 16, color: AppColors.gold),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    body,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourtPill extends StatelessWidget {
  const _CourtPill(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(AppIcons.court, size: 15, color: Colors.white),
          const SizedBox(width: 7),
          Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}

/// Publication date with one stat tile per status (Uploaded, On Leave, …).
class _PublicationCard extends ConsumerWidget {
  const _PublicationCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = Theme.of(context);
    final tk = context.tokens;
    final status = ref.watch(publicationStatusProvider);
    final listDate = status.value?.data.listDate;
    final entries = status.value?.data.summary.entries.toList() ?? const <MapEntry<String, int>>[];

    final header = Row(
      children: [
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: tk.goldSoft, shape: BoxShape.circle),
          child: Icon(AppIcons.publicationDate, color: tk.goldText, size: 24),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(l.publicationStatus, style: t.textTheme.titleSmall?.copyWith(fontSize: 15)),
              ),
              const SizedBox(height: 2),
              switch (status) {
                AsyncError() => Text(l.notYetAvailable, style: t.textTheme.bodySmall),
                _ when listDate != null => FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(Fmt.displayDate(listDate, locale: context.localeName), style: t.textTheme.bodyMedium),
                ),
                _ => const Padding(padding: EdgeInsets.only(top: 6, right: 24), child: LinearProgressIndicator()),
              },
              if (status.value case final v? when !v.isCurrent)
                Text(l.staleBanner, style: t.textTheme.bodySmall?.copyWith(color: tk.warning)),
            ],
          ),
        ),
      ],
    );

    final tiles = [
      for (final e in entries)
        Expanded(
          child: _StatTile(status: e.key, count: e.value),
        ),
    ];
    final sideBySide = entries.isNotEmpty && entries.length <= 2;
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: sideBySide
          ? IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(child: header),
                  VerticalDivider(width: 20, color: tk.cardBorder),
                  // Fixed-width tiles leave the title and date as much room as possible.
                  for (final (i, e) in entries.indexed) ...[
                    if (i > 0) const SizedBox(width: 8),
                    SizedBox(
                      width: 70,
                      child: _StatTile(status: e.key, count: e.value),
                    ),
                  ],
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                if (entries.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      for (final (i, tile) in tiles.indexed) ...[if (i > 0) const SizedBox(width: 8), tile],
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.status, required this.count});
  final String status;
  final int count;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final tk = context.tokens;
    final light = t.brightness == Brightness.light;
    final key = status.toUpperCase();
    final (IconData icon, Color fg, Color bg) = key == 'UPLOADED'
        ? (AppIcons.uploaded, tk.success, light ? const Color(0xFFE3F4EA) : tk.success.withValues(alpha: .16))
        : key.contains('LEAVE')
        ? (AppIcons.onLeave, t.colorScheme.primary, light ? const Color(0xFFE9EEF6) : tk.subtleFill)
        : (key.contains('PROCESS') ? AppIcons.inProcess : AppIcons.info, tk.textSecondary, tk.subtleFill);
    final label = status
        .toLowerCase()
        .split(RegExp(r'[\s_]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
    return Container(
      key: Key('pubStat-$status'),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: light ? AppColors.navy : fg),
          const SizedBox(height: 2),
          Text(
            count.toString().padLeft(2, '0'),
            style: t.textTheme.titleLarge?.copyWith(
              color: light ? AppColors.navy : t.colorScheme.onSurface,
              height: 1.2,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.textTheme.labelMedium?.copyWith(color: light ? AppColors.navy : t.colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}

/// "Quick Access" heading with View All, then four cause-list tiles.
class _QuickAccess extends StatelessWidget {
  const _QuickAccess();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context);
    final wide = MediaQuery.sizeOf(context).width > 600;
    final textScale = (MediaQuery.textScalerOf(context).scale(14) / 14).clamp(1.0, 1.6);
    final tiles = [
      _QuickTile(AppIcons.daily, l.dailyCauseList, () => context.push('/cause-list/daily')),
      _QuickTile(AppIcons.weekly, l.weeklyCauseList, () => context.push('/cause-list/weekly')),
      _QuickTile(AppIcons.supplementary, l.supplementaryCauseList, () => context.push('/cause-list/supplementary')),
      _QuickTile(AppIcons.liveBoard, l.liveDisplayBoard, () => context.push('/live')),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const _GridMark(),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Semantics(header: true, child: Text(l.quickAccess, style: t.textTheme.titleLarge)),
            ),
            TextButton(
              onPressed: () => context.go('/more'),
              style: TextButton.styleFrom(foregroundColor: context.tokens.goldText),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text(l.viewAll), const SizedBox(width: 6), const Icon(AppIcons.arrowRight, size: 18)],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: wide ? 4 : 2,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: (wide ? 2.0 : 2.15) / textScale,
          children: tiles,
        ),
      ],
    );
  }
}

/// Four small gold squares (the "Quick Access" mark).
class _GridMark extends StatelessWidget {
  const _GridMark();

  @override
  Widget build(BuildContext context) {
    Widget sq(Color c) => Container(
      width: 13,
      height: 13,
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4)),
    );
    const a = Color(0xFFE0A63A), b = Color(0xFFEBC27C);
    return ExcludeSemantics(
      child: SizedBox(
        width: 30,
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [sq(a), sq(b)]),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [sq(a), sq(a)]),
          ],
        ),
      ),
    );
  }
}

/// Splits a tile label over two lines: before "Cause List" when present, otherwise at the last space.
String _twoLines(String label) {
  final i = label.endsWith(' Cause List') ? label.length - ' Cause List'.length : label.lastIndexOf(' ');
  return i <= 0 ? label : '${label.substring(0, i)}\n${label.substring(i + 1)}';
}

class _QuickTile extends StatelessWidget {
  const _QuickTile(this.icon, this.label, this.onTap);
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final tk = context.tokens;
    return AppCard(
      onTap: onTap,
      radius: 18,
      padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: tk.goldSoft, shape: BoxShape.circle),
            child: Icon(icon, size: 21, color: tk.goldText),
          ),
          const SizedBox(width: 8),
          Expanded(
            // Two lines as in the design ("Daily / Cause List"); a word too long for the tile scales
            // down a little instead of being cut off.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                _twoLines(label),
                maxLines: 2,
                style: t.textTheme.titleSmall?.copyWith(fontSize: 14, height: 1.25),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: tk.subtleFill, shape: BoxShape.circle),
            child: Icon(AppIcons.arrowRight, size: 16, color: t.colorScheme.primary),
          ),
        ],
      ),
    );
  }
}

/// "Justice for All" brand banner.
class _JusticeBanner extends StatelessWidget {
  const _JusticeBanner();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context);
    return Container(
      height: 96,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.tokens.featureBorder),
        gradient: LinearGradient(
          colors: Theme.of(context).brightness == Brightness.light
              ? const [AppColors.navyDeep, AppColors.navy, AppColors.navyLight]
              : [context.tokens.featureBottom, context.tokens.featureTop],
        ),
      ),
      child: Stack(
        children: [
          // Gold-toned courthouse photo fading in from the right.
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 170,
            child: ExcludeSemantics(
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (r) => const LinearGradient(
                  colors: [Colors.transparent, Color(0xCCFFFFFF), Colors.white],
                  stops: [0, .45, 1],
                ).createShader(r),
                child: Image.asset('assets/images/court_banner.jpg', fit: BoxFit.cover, alignment: Alignment.topCenter),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg + 4),
            child: Row(
              children: [
                const BrandMark(size: 56, shadow: false),
                Container(
                  width: 1,
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  color: AppColors.gold.withValues(alpha: .6),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.justiceForAll, style: t.textTheme.titleMedium?.copyWith(color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(
                        l.justiceForAllSubtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: t.textTheme.bodySmall?.copyWith(color: _soft),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 90),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
