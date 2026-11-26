import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/widgets/widgets.dart';
import '../../theme/app_theme.dart';
import 'session_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(sessionProvider.notifier).bootstrap());
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final tk = context.tokens;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [tk.heroTop, tk.heroBottom],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                const FadeSlideIn(child: BrandMark(size: 92)),
                const SizedBox(height: AppSpacing.xl),
                FadeSlideIn(
                  order: 1,
                  child: Text(
                    context.l10n.appName,
                    style: t.textTheme.headlineMedium?.copyWith(color: Colors.white, letterSpacing: .2),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                FadeSlideIn(
                  order: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: Text(
                      context.l10n.appTagline,
                      textAlign: TextAlign.center,
                      style: t.textTheme.bodyMedium?.copyWith(color: const Color(0xFFC9D2E0)),
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                SizedBox(
                  width: 112,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      color: AppColors.gold,
                      backgroundColor: Colors.white.withValues(alpha: .12),
                    ),
                  ),
                ),
                const SizedBox(height: 56),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
