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
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const BrandMark(size: 84),
          const SizedBox(height: AppSpacing.xl),
          Text(context.l10n.appName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, letterSpacing: .5)),
          const SizedBox(height: AppSpacing.sm),
          Text(context.l10n.appTagline, style: const TextStyle(color: Color(0xFFCAD3E2))),
          const SizedBox(height: AppSpacing.xxl),
          const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.gold)),
        ]),
      ),
    );
  }
}

/// Scales-of-justice mark in a gold ring (drawn, no external asset).
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
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.gold, width: 2),
          color: AppColors.navyLight,
        ),
        child: Icon(Icons.balance_rounded, color: AppColors.gold, size: size * .52),
      ),
    );
  }
}
