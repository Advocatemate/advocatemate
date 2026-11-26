import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:material_ui/material_ui.dart';

import '../../shared/widgets/widgets.dart';
import '../../theme/app_theme.dart';

/// Shared frame for the sign-in steps: navy hero with the brand, then a white card that overlaps it.
class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.card, this.footer, this.compactHero = false});
  final Widget card;
  final Widget? footer;
  final bool compactHero;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context);
    final tk = context.tokens;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [tk.heroTop, tk.heroBottom],
                  ),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppSpacing.radiusLg + 8)),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(AppSpacing.xl, compactHero ? 28 : 44, AppSpacing.xl, 72),
                    child: Column(
                      children: [
                        BrandMark(size: compactHero ? 60 : 76),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          l.appName,
                          textAlign: TextAlign.center,
                          style: t.textTheme.headlineSmall?.copyWith(color: Colors.white, letterSpacing: .2),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l.appTagline,
                          textAlign: TextAlign.center,
                          style: t.textTheme.bodyMedium?.copyWith(color: const Color(0xFFC9D2E0)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -44),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FadeSlideIn(
                            child: AppCard(padding: const EdgeInsets.all(AppSpacing.xl), child: card),
                          ),
                          if (footer != null) ...[const SizedBox(height: AppSpacing.lg), footer!],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline error under an auth card.
class AuthError extends StatelessWidget {
  const AuthError({super.key, required this.message, required this.textKey});
  final String message;
  final Key textKey;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.tokens.danger;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: c.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: c.withValues(alpha: .25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(AppIcons.error, size: AppIcons.sizeSm, color: c),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                key: textKey,
                style: t.textTheme.bodySmall?.copyWith(color: c, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
