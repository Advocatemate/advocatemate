import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/widgets/widgets.dart';
import '../../theme/app_theme.dart';
import 'auth_layout.dart';
import 'auth_messages.dart';
import 'google_auth_service.dart';
import 'session_controller.dart';

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
    final tk = context.tokens;
    return AuthLayout(
      card: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.loginTitle, style: t.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(l.googleSignInSubtitle, style: t.textTheme.bodyMedium?.copyWith(color: tk.textSecondary)),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            key: const Key('googleSignInButton'),
            onPressed: _signIn,
            busy: _busy,
            icon: AppIcons.signIn,
            label: l.signInWithGoogle,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(AppIcons.shield, size: AppIcons.sizeSm, color: tk.goldText),
              const SizedBox(width: 10),
              Expanded(child: Text(l.googleSignInNote, style: t.textTheme.bodySmall)),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.lg),
            AuthError(message: _error!, textKey: const Key('loginError')),
          ],
        ],
      ),
      footer: Text(
        l.dataNotice,
        textAlign: TextAlign.center,
        style: t.textTheme.bodySmall?.copyWith(color: tk.textTertiary),
      ),
    );
  }
}
