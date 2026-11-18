import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderException;
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/formatters.dart';
import '../../core/loaded.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../theme/app_theme.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String get localeName => Localizations.localeOf(this).languageCode;
}

// ------------------------------------------------------------------ containers
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, this.title, required this.child, this.trailing, this.padding});
  final String? title;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(children: [
                Container(width: 3, height: 18, color: AppColors.gold),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Semantics(header: true, child: Text(title!, style: t.textTheme.titleMedium))),
                ?trailing,
              ]),
            ),
          child,
        ]),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: MergeSemantics(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 140,
              child: Text(label, style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurface.withValues(alpha: .65)))),
          Expanded(child: SelectableText(value, style: t.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500))),
        ]),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.label, {super.key, this.color, this.icon});
  final String label;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: c.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 14, color: c), const SizedBox(width: 4)],
        Text(label, style: TextStyle(color: c, fontSize: 12.5, fontWeight: FontWeight.w600)),
      ]),
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
    final l = context.l10n;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (itemNo != null)
              Container(
                constraints: const BoxConstraints(minWidth: 48),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                margin: const EdgeInsets.only(right: AppSpacing.md),
                decoration: BoxDecoration(
                  color: t.colorScheme.primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Semantics(
                  label: l.itemNo(itemNo!),
                  excludeSemantics: true,
                  child: Column(children: [
                    Text('ITEM', style: t.textTheme.labelSmall?.copyWith(color: AppColors.gold, letterSpacing: 1)),
                    Text(itemNo!, style: t.textTheme.titleMedium?.copyWith(color: t.colorScheme.primary)),
                  ]),
                ),
              ),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(caseNumber, style: t.textTheme.titleMedium)),
                  ?trailing,
                ]),
                if (courtNo != null)
                  Text(l.court(courtNo!), style: t.textTheme.bodySmall?.copyWith(color: AppColors.gold)),
                if (petitioner != null) ...[
                  const SizedBox(height: 6),
                  Text(petitioner!, style: t.textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
                if (respondent != null)
                  Text('${l.versus} ${respondent!}',
                      style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurface.withValues(alpha: .75)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: t.textTheme.bodySmall),
                ],
                if (advocates.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(advocates.join(' · '),
                      style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurface.withValues(alpha: .6)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
                if (badges.isNotEmpty) ...[const SizedBox(height: 8), Wrap(spacing: 6, runSpacing: 6, children: badges)],
              ]),
            ),
          ]),
        ),
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
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Semantics(
      label: 'Loading',
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: widget.count,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, _) => FadeTransition(
          opacity: Tween(begin: .45, end: 1.0).animate(_c),
          child: Container(
              height: widget.height,
              decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(AppSpacing.radius))),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, this.icon = Icons.inbox_outlined, this.action});
  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 56, color: t.colorScheme.primary.withValues(alpha: .35)),
          const SizedBox(height: AppSpacing.lg),
          Text(message, textAlign: TextAlign.center, style: t.textTheme.bodyLarge),
          if (action != null) ...[const SizedBox(height: AppSpacing.lg), action!],
        ]),
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
    final message = e is ApiException ? (e.isNetwork ? l.errorNetwork : e.message) : l.errorGeneric;
    return EmptyState(
      icon: e is ApiException && e.isNetwork ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
      message: message,
      action: onRetry == null ? null : OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: Text(l.retry)),
    );
  }
}

/// Renders an [AsyncValue] with skeleton / error / data states.
class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({super.key, required this.value, required this.builder, this.onRetry, this.skeletonCount = 6});
  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;
  final int skeletonCount;

  @override
  Widget build(BuildContext context) {
    return switch (value) {
      AsyncData(:final value) => builder(value),
      AsyncError(:final error) => ErrorState(error: error, onRetry: onRetry),
      _ => value.hasValue ? builder(value.requireValue) : SkeletonList(count: skeletonCount),
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
        child: Container(
          width: double.infinity,
          color: AppColors.warning.withValues(alpha: .14),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 10),
          child: Row(children: [
            const Icon(Icons.history_toggle_off, color: AppColors.warning, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${loaded.fromCache ? l.offlineBanner : l.staleBanner}'
                '${when != null ? '\n${l.lastUpdated(Fmt.timestamp(when, locale: context.localeName))}' : ''}',
                style: t.textTheme.bodySmall?.copyWith(color: AppColors.warning, fontWeight: FontWeight.w600),
              ),
            ),
          ]),
        ),
      );
    }
    if (loaded.fetchedAt == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
      child: Text(l.lastUpdated(Fmt.timestamp(loaded.fetchedAt, locale: context.localeName)),
          style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurface.withValues(alpha: .6))),
    );
  }
}

/// Horizontal chips for source-offered dates plus a calendar picker.
class DateSelector extends StatelessWidget {
  const DateSelector({super.key, required this.selected, required this.onChanged, this.offered = const []});
  final DateTime selected;
  final ValueChanged<DateTime> onChanged;
  final List<String> offered;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final dates = offered.map(DateTime.tryParse).whereType<DateTime>().toList();
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 6),
        children: [
          ActionChip(
            avatar: const Icon(Icons.calendar_month, size: 18),
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
              padding: const EdgeInsets.only(left: 6),
              child: ChoiceChip(
                label: Text(Fmt.shortDate(d, locale: context.localeName)),
                selected: DateUtils.isSameDay(d, selected),
                onSelected: (_) => onChanged(d),
              ),
            ),
        ],
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.controller, required this.onChanged, this.hint});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: hint ?? context.l10n.searchHint,
        suffixIcon: ValueListenableBuilder(
          valueListenable: controller,
          builder: (_, v, _) => v.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  }),
        ),
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
  final msg = e is ApiException ? (e.isNetwork ? context.l10n.errorNetwork : e.message) : context.l10n.errorGeneric;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

/// Helper so screens can use `ref.refresh` in pull-to-refresh.
Future<void> refreshProvider(WidgetRef ref, dynamic provider) async {
  ref.invalidate(provider);
  try {
    await ref.read(provider.future);
  } catch (_) {}
}
