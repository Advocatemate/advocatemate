import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../theme/app_theme.dart';
import 'app_icons.dart';

/// Page layout helpers: a 20 px gutter on phones, content centred at [maxContentWidth] on tablets.
abstract final class AppLayout {
  static const maxContentWidth = 760.0;

  static double gutter(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return math.max(AppSpacing.page, (w - maxContentWidth) / 2);
  }

  static EdgeInsets page(BuildContext context, {double top = 0, double bottom = 0}) {
    final g = gutter(context);
    return EdgeInsets.fromLTRB(g, top, g, bottom);
  }
}

/// Rounded white surface with a hairline border and a soft shadow; optional tap ripple.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color,
    this.borderColor,
    this.radius = AppSpacing.radius,
    this.shadow = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final double radius;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final br = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? t.colorScheme.surface,
        borderRadius: br,
        border: Border.all(color: borderColor ?? context.tokens.cardBorder),
        boxShadow: shadow ? AppShadows.card(t.brightness) : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: br,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: br,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Icon inside a tinted rounded square — tiles, list rows, headers.
class IconBadge extends StatelessWidget {
  const IconBadge(
    this.icon, {
    super.key,
    this.size = 40,
    this.iconSize,
    this.color,
    this.background,
    this.circle = false,
  });
  final IconData icon;
  final double size;
  final double? iconSize;
  final Color? color;
  final Color? background;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? context.tokens.subtleFill,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(size * .3),
      ),
      child: Icon(icon, size: iconSize ?? size * .5, color: color ?? t.colorScheme.primary),
    );
  }
}

/// List heading with an optional trailing action (e.g. "Clear history").
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.padding});
  final String title;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Semantics(header: true, child: Text(title, style: t.textTheme.titleMedium)),
          ),
          ?action,
        ],
      ),
    );
  }
}

/// Full-width primary action with a built-in busy spinner.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, this.onPressed, this.icon, this.busy = false});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final on = Theme.of(context).colorScheme.onPrimary;
    return FilledButton(
      onPressed: busy ? null : onPressed,
      child: busy
          ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: on))
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon, size: AppIcons.size), const SizedBox(width: 10)],
                Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
              ],
            ),
    );
  }
}

/// Rounded inline notice (offline, stale data, PDF check, enrichment state).
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.text,
    required this.color,
    this.icon,
    this.leading,
    this.action,
    this.margin,
    this.bold = true,
  });

  final String text;
  final Color color;
  final IconData? icon;

  /// Replaces [icon] (e.g. a small spinner).
  final Widget? leading;
  final Widget? action;
  final EdgeInsetsGeometry? margin;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: margin ?? AppLayout.page(context, top: AppSpacing.sm),
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 10, AppSpacing.sm, 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: t.brightness == Brightness.light ? .09 : .16),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: color.withValues(alpha: .22)),
      ),
      child: Row(
        children: [
          leading ?? Icon(icon ?? AppIcons.info, color: color, size: AppIcons.sizeSm),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: t.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

/// Circle with up to two initials; gold ring for the signed-in advocate.
class AvatarInitials extends StatelessWidget {
  const AvatarInitials({super.key, required this.name, this.size = 44, this.onDark = false});
  final String name;
  final double size;
  final bool onDark;

  static String initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty && RegExp(r'[A-Za-zఀ-౿]').hasMatch(p[0]));
    final letters = parts.map((p) => p[0].toUpperCase()).toList();
    if (letters.isEmpty) return '';
    return letters.length == 1 ? letters.first : '${letters.first}${letters.last}';
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final initials = initialsOf(name);
    final bg = onDark ? const Color(0xFF1B2E50) : context.tokens.goldSoft;
    final fg = onDark ? Colors.white : context.tokens.onGoldSoft;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.gold.withValues(alpha: onDark ? .95 : .55),
            width: onDark ? 2.5 : 1.5,
          ),
        ),
        child: initials.isEmpty
            ? Icon(AppIcons.advocate, size: size * .48, color: fg)
            : Text(
                initials,
                style: t.textTheme.titleMedium?.copyWith(color: fg, fontSize: size * .36, letterSpacing: .5),
              ),
      ),
    );
  }
}

/// One-shot fade + rise on first build; [order] staggers siblings. Skipped when the OS asks for
/// reduced motion.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.child, this.order = 0, this.offset = 12});
  final Widget child;
  final int order;
  final double offset;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return child;
    const step = 60;
    final delay = math.min(order, 6) * step;
    final total = 320 + delay;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(delay / total, 1, curve: Curves.easeOutCubic),
      child: child,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * offset), child: child),
      ),
    );
  }
}

/// Card holding [MenuRow]s separated by inset dividers (settings, More, shortcuts).
class MenuGroup extends StatelessWidget {
  const MenuGroup({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        children: [
          for (final (i, c) in children.indexed) ...[if (i > 0) const Divider(indent: 64, height: 1), c],
        ],
      ),
    );
  }
}

/// Menu row: icon badge, label, optional subtitle and trailing widget (chevron by default).
class MenuRow extends StatelessWidget {
  const MenuRow({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final tk = context.tokens;
    final color = destructive ? tk.danger : t.colorScheme.primary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md + 2, vertical: 7),
        child: Row(
          children: [
            IconBadge(
              icon,
              size: 36,
              iconSize: 18,
              color: color,
              background: destructive ? tk.danger.withValues(alpha: .08) : null,
            ),
            const SizedBox(width: AppSpacing.md + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: t.textTheme.bodyLarge?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: destructive ? tk.danger : null,
                    ),
                  ),
                  if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle!, style: t.textTheme.bodySmall)],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            trailing ??
                (onTap == null
                    ? const SizedBox.shrink()
                    : Icon(AppIcons.chevronRight, size: 18, color: tk.textTertiary)),
          ],
        ),
      ),
    );
  }
}

/// Small centred spinner.
class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.size = 22, this.color});
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(strokeWidth: 2.4, color: color),
    ),
  );
}

/// AdvocateMate mark: gold scales of justice on a navy tile (drawn, no external asset).
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 64});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'AdvocateMate',
      image: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * .28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.navyLight, AppColors.navyDeep],
          ),
          border: Border.all(color: AppColors.gold.withValues(alpha: .75), width: 1.5),
          boxShadow: const [BoxShadow(color: Color(0x330B1930), blurRadius: 18, offset: Offset(0, 8))],
        ),
        child: Icon(AppIcons.judge, color: AppColors.gold, size: size * .5),
      ),
    );
  }
}
