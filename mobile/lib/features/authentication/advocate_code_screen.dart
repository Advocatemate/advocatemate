import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/widgets/widgets.dart';
import '../../theme/app_theme.dart';
import 'auth_messages.dart';
import 'session_controller.dart';
import 'splash_screen.dart';

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
    final s = ref.watch(sessionProvider);
    final email = s is SessionNeedsAdvocateCode ? s.googleEmail : '';
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Center(child: BrandMark(size: 64)),
                const SizedBox(height: AppSpacing.xl),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Text(l.advocateCodeTitle, style: t.textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(color: AppColors.goldSoft, borderRadius: BorderRadius.circular(12)),
                        child: Row(children: [
                          const Icon(Icons.account_circle_outlined, color: AppColors.navy),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(l.signedInAsGoogle(email),
                                key: const Key('googleEmailText'), style: const TextStyle(color: AppColors.navy)),
                          ),
                        ]),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextField(
                        key: const Key('advocateCodeField'),
                        controller: _code,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)],
                        decoration: InputDecoration(labelText: l.advocateCode, hintText: l.advocateCodeHint),
                        onSubmitted: (_) => _verify(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton(
                        key: const Key('verifyAdvocateButton'),
                        onPressed: _busy ? null : _verify,
                        child: _busy
                            ? const SizedBox(
                                width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                            : Text(l.verifyAndContinue),
                      ),
                      TextButton(
                        onPressed: _busy ? null : () => ref.read(sessionProvider.notifier).useDifferentAccount(),
                        child: Text(l.useDifferentAccount),
                      ),
                    ]),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Semantics(
                    liveRegion: true,
                    child: Text(_error!,
                        key: const Key('linkError'), textAlign: TextAlign.center, style: TextStyle(color: t.colorScheme.error)),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                Text(l.googleSignInNote, textAlign: TextAlign.center, style: t.textTheme.bodySmall),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
