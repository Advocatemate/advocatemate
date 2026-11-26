import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderException;
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/formatters.dart';
import '../../core/loaded.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../theme/app_theme.dart';
import 'app_icons.dart';
import 'ui_kit.dart';

export 'app_icons.dart';
export 'ui_kit.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String get localeName => Localizations.localeOf(this).languageCode;
}

// ------------------------------------------------------------------ containers
/// Titled card: a short gold accent bar marks the section heading.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, this.title, required this.child, this.trailing, this.padding, this.icon});
  final String? title;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return AppCard(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  if (icon != null) ...[
                    IconBadge(icon!, size: 32, iconSize: 17),
                    const SizedBox(width: AppSpacing.md),
                  ] else ...[
                    Container(
                      width: 3,
                      height: 16,
                      decoration: BoxDecoration(color: context.tokens.gold, borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Semantics(header: true, child: Text(title!, style: t.textTheme.titleMedium)),
                  ),
                  ?trailing,
                ],
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class LabelValue extends StatelessWidget {
  const LabelValue(this.label, this.value, {super.key});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: MergeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 132, child: Text(label, style: t.textTheme.bodySmall)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SelectableText(value, style: t.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Status badge: tinted pill with optional icon. Brand status colours are swapped for their
/// dark-mode equivalents automatically.
class StatusChip extends StatelessWidget {
  const StatusChip(this.label, {super.key, this.color, this.icon});
  final String label;
  final Color? color;
  final IconData? icon;

  static Color resolve(BuildContext context, Color? c) {
    final tk = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    if (c == null || c == AppColors.navy) return scheme.primary;
    if (c == AppColors.success) return tk.success;
    if (c == AppColors.warning) return tk.warning;
    if (c == AppColors.danger) return tk.danger;
    if (c == AppColors.muted) return tk.textSecondary;
    if (c == AppColors.navyLight) return tk.info;
    if (c == AppColors.gold) return tk.goldText;
    return c;
  }

  @override
  Widget build(BuildContext context) {
    final c = resolve(context, color);
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: t.brightness == Brightness.light ? .10 : .18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 13, color: c), const SizedBox(width: 5)],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: t.textTheme.labelMedium?.copyWith(color: c, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ case card
class CaseCard extends StatelessWidget {
  const CaseCard({
    super.key,
    required this.caseNumber,
    this.itemNo,
    this.courtNo,
    this.petitioner,
    this.respondent,
    this.subtitle,
    this.advocates = const [],
    this.badges = const [],
    this.onTap,
    this.trailing,
  });

  final String caseNumber;
  final String? itemNo;
  final String? courtNo;
  final String? petitioner;
  final String? respondent;
  final String? subtitle;
  final List<String> advocates;
  final List<Widget> badges;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final tk = context.tokens;
    final l = context.l10n;
    final secondary = t.textTheme.bodyMedium?.copyWith(color: tk.textSecondary);
    return AppCard(
      onTap: onTap,
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (itemNo != null)
            Container(
              constraints: const BoxConstraints(minWidth: 52),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              margin: const EdgeInsets.only(right: AppSpacing.md),
              decoration: BoxDecoration(color: tk.goldSoft, borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
              child: Semantics(
                label: l.itemNo(itemNo!),
                excludeSemantics: true,
                child: Column(
                  children: [
                    Text(
                      'ITEM',
                      style: t.textTheme.labelSmall?.copyWith(color: tk.goldText, fontSize: 9.5, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      itemNo!,
                      style: t.textTheme.titleMedium?.copyWith(
                        color: t.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        caseNumber,
                        style: t.textTheme.titleMedium?.copyWith(
                          color: t.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    ?trailing,
                  ],
                ),
                if (courtNo != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        Icon(AppIcons.court, size: 13, color: tk.goldText),
                        const SizedBox(width: 5),
                        Text(l.court(courtNo!), style: t.textTheme.labelMedium?.copyWith(color: tk.goldText)),
                      ],
                    ),
                  ),
                if (petitioner != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    petitioner!,
                    style: t.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (respondent != null)
                  Text('${l.versus} ${respondent!}', style: secondary, maxLines: 2, overflow: TextOverflow.ellipsis),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(subtitle!, style: t.textTheme.bodySmall),
                ],
                if (advocates.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Icon(AppIcons.advocates, size: 13, color: tk.textTertiary),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          advocates.join(' · '),
                          style: t.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (badges.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(spacing: 6, runSpacing: 6, children: badges),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ states
class SkeletonList extends StatefulWidget {
  const SkeletonList({super.key, this.count = 6, this.height = 92});
  final int count;
  final double height;

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final fill = context.tokens.subtleFill;
    Widget bar(double w, double h) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(6)),
    );
    return Semantics(
      label: 'Loading',
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: AppLayout.page(context, top: AppSpacing.lg, bottom: AppSpacing.lg),
        itemCount: widget.count,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, _) => FadeTransition(
          opacity: Tween(begin: .5, end: 1.0).animate(_c),
          child: Container(
            height: widget.height,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: t.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
              border: Border.all(color: context.tokens.cardBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: LayoutBuilder(
                    builder: (_, c) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        bar(c.maxWidth * .55, 12),
                        const SizedBox(height: 10),
                        bar(c.maxWidth * .9, 10),
                        if (widget.height >= 80) ...[const SizedBox(height: 8), bar(c.maxWidth * .7, 10)],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, this.icon = AppIcons.empty, this.action, this.title});
  final String message;
  final IconData icon;
  final Widget? action;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final tk = context.tokens;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(color: tk.subtleFill, shape: BoxShape.circle),
                child: Icon(icon, size: 32, color: t.colorScheme.primary.withValues(alpha: .75)),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (title != null) ...[
                Text(title!, textAlign: TextAlign.center, style: t.textTheme.titleMedium),
                const SizedBox(height: 6),
              ],
              Text(
                message,
                textAlign: TextAlign.center,
                style: t.textTheme.bodyMedium?.copyWith(color: tk.textSecondary),
              ),
              if (action != null) ...[const SizedBox(height: AppSpacing.lg), action!],
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.error, this.onRetry});
  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final e = unwrapError(error);
    final message = apiErrorText(context, e);
    return EmptyState(
      icon: e is ApiException && e.isNetwork ? AppIcons.offline : AppIcons.error,
      message: message,
      action: onRetry == null
          ? null
          : OutlinedButton.icon(onPressed: onRetry, icon: const Icon(AppIcons.refresh, size: 18), label: Text(l.retry)),
    );
  }
}

/// Renders an [AsyncValue] with skeleton / error / data states; data fades in on first show.
class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({super.key, required this.value, required this.builder, this.onRetry, this.skeletonCount = 6});
  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;
  final int skeletonCount;

  @override
  Widget build(BuildContext context) {
    return switch (value) {
      AsyncData(:final value) => FadeSlideIn(offset: 6, child: builder(value)),
      AsyncError(:final error) => ErrorState(error: error, onRetry: onRetry),
      _ =>
        value.hasValue
            ? FadeSlideIn(offset: 6, child: builder(value.requireValue))
            : SkeletonList(count: skeletonCount),
    };
  }
}

/// Offline / stale / last-updated banner shown above every data list.
class FreshnessBanner extends StatelessWidget {
  const FreshnessBanner(this.loaded, {super.key});
  final Loaded<Object?> loaded;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context);
    if (loaded.fromCache || loaded.serverStale) {
      final when = loaded.savedAt ?? loaded.fetchedAt;
      return Semantics(
        liveRegion: true,
        child: InfoBanner(
          color: context.tokens.warning,
          icon: AppIcons.history,
          text:
              '${loaded.fromCache ? l.offlineBanner : l.staleBanner}'
              '${when != null ? '\n${l.lastUpdated(Fmt.timestamp(when, locale: context.localeName))}' : ''}',
        ),
      );
    }
    if (loaded.fetchedAt == null) return const SizedBox.shrink();
    return Padding(
      padding: AppLayout.page(context, top: AppSpacing.sm),
      child: Row(
        children: [
          Icon(AppIcons.clock, size: 13, color: context.tokens.textTertiary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              l.lastUpdated(Fmt.timestamp(loaded.fetchedAt, locale: context.localeName)),
              style: t.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal chips for source-offered dates plus a calendar picker. [onDark] restyles the chips for a
/// navy header (translucent white, selected date in gold).
class DateSelector extends StatelessWidget {
  const DateSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.offered = const [],
    this.onDark = false,
  });
  final DateTime selected;
  final ValueChanged<DateTime> onChanged;
  final List<String> offered;
  final bool onDark;

  @override
  Widget build(BuildContext context) => _strip(context);

  /// Explicit chip colours for the navy header (null on light backgrounds: the chip theme applies).
  ({Color bg, Color fg, BorderSide side})? _dark(bool selected) => !onDark
      ? null
      : selected
      ? (bg: AppColors.gold, fg: AppColors.navyDeep, side: const BorderSide(color: AppColors.gold))
      : (bg: const Color(0xFF26385A), fg: Colors.white, side: BorderSide(color: Colors.white.withValues(alpha: .22)));

  Widget _strip(BuildContext context) {
    final l = context.l10n;
    final dates = offered.map(DateTime.tryParse).whereType<DateTime>().toList();
    final g = AppLayout.gutter(context);
    return SizedBox(
      height: 54,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(g, 8, g, 6),
        children: [
          ActionChip(
            avatar: Icon(AppIcons.calendar, size: 16, color: onDark ? AppColors.gold : null),
            color: onDark ? WidgetStatePropertyAll(_dark(false)!.bg) : null,
            side: _dark(false)?.side,
            labelStyle: onDark
                ? Theme.of(context).chipTheme.labelStyle?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)
                : null,
            label: Text(Fmt.shortDate(selected, locale: context.localeName)),
            tooltip: l.selectDate,
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selected,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 60)),
                helpText: l.selectDate,
              );
              if (picked != null) onChanged(picked);
            },
          ),
          for (final d in dates)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Builder(
                builder: (context) {
                  final on = DateUtils.isSameDay(d, selected);
                  final dark = _dark(on);
                  return ChoiceChip(
                    label: Text(Fmt.shortDate(d, locale: context.localeName)),
                    selected: on,
                    color: dark == null ? null : WidgetStatePropertyAll(dark.bg),
                    side: dark?.side,
                    labelStyle: dark == null
                        ? null
                        : Theme.of(context).chipTheme.labelStyle?.copyWith(color: dark.fg, fontWeight: FontWeight.w600),
                    onSelected: (_) => onChanged(d),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Rounded search field with a clear button.
class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.controller, required this.onChanged, this.hint, this.onSubmitted});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        prefixIcon: const Icon(AppIcons.search, size: AppIcons.size),
        hintText: hint ?? context.l10n.searchHint,
        suffixIcon: ValueListenableBuilder(
          valueListenable: controller,
          builder: (_, v, _) => v.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                  icon: const Icon(AppIcons.clear, size: AppIcons.size),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  }),
        ),
      ),
    );
  }
}

/// Horizontal row of filter chips (court / stage / date filters).
class ChipStrip extends StatelessWidget {
  const ChipStrip({super.key, required this.children, this.padding});
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: padding ?? const EdgeInsets.only(top: 8),
        children: [
          for (final (i, c) in children.indexed)
            Padding(
              padding: EdgeInsets.only(right: i == children.length - 1 ? 0 : 8),
              child: c,
            ),
        ],
      ),
    );
  }
}

/// Riverpod 3 wraps errors from dependent providers in [ProviderException].
Object unwrapError(Object e) {
  var x = e;
  while (x is ProviderException) {
    x = x.exception;
  }
  return x;
}

void showError(BuildContext context, Object error) {
  final e = unwrapError(error);
  final msg = apiErrorText(context, e);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

/// Helper so screens can use `ref.refresh` in pull-to-refresh.
Future<void> refreshProvider(WidgetRef ref, dynamic provider) async {
  ref.invalidate(provider);
  try {
    await ref.read(provider.future);
  } catch (_) {}
}


/// User-facing text for an error: localised for known codes, otherwise the server's message.
String apiErrorText(BuildContext context, Object e) {
  final l = context.l10n;
  if (e is! ApiException) return l.errorGeneric;
  if (e.isNetwork) return l.errorNetwork;
  return switch (e.code) {
    'advocate_not_found' => l.errAdvocateNotFound,
    'advocate_lookup_limited' => l.errTooManyLookups,
    'invalid_advocate_code' => l.advocateLookupInvalid,
    _ => e.message,
  };
}
