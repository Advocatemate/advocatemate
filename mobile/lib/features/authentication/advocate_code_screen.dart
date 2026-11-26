import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/widgets/widgets.dart';
import '../../theme/app_theme.dart';
import 'auth_layout.dart';
import 'auth_messages.dart';
import 'session_controller.dart';

/// Step 2 of sign-in: link the (server-verified) Google account to an advocate code.
/// The backend checks the code against the advocate registry automatically - no approval step.
class AdvocateCodeScreen extends ConsumerStatefulWidget {
  const AdvocateCodeScreen({super.key});

  @override
  ConsumerState<AdvocateCodeScreen> createState() => _AdvocateCodeScreenState();
}

class _AdvocateCodeScreenState extends ConsumerState<AdvocateCodeScreen> {
  final _code = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _code.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).linkAdvocate(code);
    } catch (e) {
      if (mounted) setState(() => _error = authErrorMessage(context, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context);
    final tk = context.tokens;
    final s = ref.watch(sessionProvider);
    final email = s is SessionNeedsAdvocateCode ? s.googleEmail : '';
    return AuthLayout(
      compactHero: true,
      card: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.stepOf(2, 2).toUpperCase(),
            style: t.textTheme.labelSmall?.copyWith(color: tk.goldText, letterSpacing: 1.2),
          ),
          const SizedBox(height: 6),
          Text(l.advocateCodeTitle, style: t.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
            decoration: BoxDecoration(color: tk.goldSoft, borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
            child: Row(
              children: [
                Icon(AppIcons.email, size: AppIcons.sizeSm, color: tk.onGoldSoft),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.signedInAsGoogle(email),
                    key: const Key('googleEmailText'),
                    style: t.textTheme.bodySmall?.copyWith(color: tk.onGoldSoft, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            key: const Key('advocateCodeField'),
            controller: _code,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)],
            style: t.textTheme.titleMedium?.copyWith(letterSpacing: 1.5),
            decoration: InputDecoration(
              labelText: l.advocateCode,
              hintText: l.advocateCodeHint,
              prefixIcon: const Icon(AppIcons.advocateCode, size: AppIcons.size),
            ),
            onSubmitted: (_) => _verify(),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            key: const Key('verifyAdvocateButton'),
            onPressed: _verify,
            busy: _busy,
            label: l.verifyAndContinue,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: _busy ? null : () => ref.read(sessionProvider.notifier).useDifferentAccount(),
            icon: const Icon(AppIcons.switchAccount, size: AppIcons.sizeSm),
            label: Text(l.useDifferentAccount),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            AuthError(message: _error!, textKey: const Key('linkError')),
          ],
        ],
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(AppIcons.shield, size: 16, color: tk.textTertiary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              l.googleSignInNote,
              textAlign: TextAlign.center,
              style: t.textTheme.bodySmall?.copyWith(color: tk.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}
