import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/widgets/widgets.dart';
import '../../theme/app_theme.dart';
import 'auth_messages.dart';
import 'google_auth_service.dart';
import 'session_controller.dart';
import 'splash_screen.dart';

/// Step 1 of sign-in: choose a Google account. The backend verifies the Google ID token.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _busy = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final s = ref.read(sessionProvider);
    if (_error == null && s is SessionSignedOut) {
      final l = context.l10n;
      _error = switch (s.reason) {
        'not_eligible' => l.accessEndedNotEligible,
        'link_expired' => l.errLinkExpired,
        'expired' => l.sessionExpired,
        _ => null,
      };
    }
  }

  Future<void> _signIn() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).signInWithGoogle();
    } catch (e) {
      final cancelled = e is GoogleSignInError && e.failure == GoogleSignInFailure.cancelled;
      if (mounted && !cancelled) setState(() => _error = authErrorMessage(context, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Center(child: BrandMark(size: 72)),
                const SizedBox(height: AppSpacing.lg),
                Text(l.appName, textAlign: TextAlign.center, style: t.textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(l.appTagline,
                    textAlign: TextAlign.center,
                    style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurface.withValues(alpha: .65))),
                const SizedBox(height: AppSpacing.xxl),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Text(l.loginTitle, style: t.textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.sm),
                      Text(l.googleSignInSubtitle, style: t.textTheme.bodyMedium),
                      const SizedBox(height: AppSpacing.xl),
                      FilledButton.icon(
                        key: const Key('googleSignInButton'),
                        onPressed: _busy ? null : _signIn,
                        icon: _busy
                            ? const SizedBox(
                                width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                            : const Icon(Icons.account_circle_outlined),
                        label: Text(l.signInWithGoogle),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(children: [
                        const Icon(Icons.verified_user_outlined, size: 18, color: AppColors.gold),
                        const SizedBox(width: 8),
                        Expanded(child: Text(l.googleSignInNote, style: t.textTheme.bodySmall)),
                      ]),
                    ]),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Semantics(
                    liveRegion: true,
                    child: Text(_error!,
                        key: const Key('loginError'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: t.colorScheme.error)),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                Text(l.dataNotice, textAlign: TextAlign.center, style: t.textTheme.bodySmall),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
