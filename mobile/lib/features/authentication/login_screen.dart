import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/providers.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';
import '../../theme/app_theme.dart';
import 'auth_repository.dart';
import 'session_controller.dart';
import 'splash_screen.dart';

enum _Step { code, confirm, mobile, otp }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _code = TextEditingController();
  final _mobile = TextEditingController();
  final _otp = TextEditingController();
  _Step _step = _Step.code;
  bool _busy = false;
  String? _error;
  RegisterInfo? _info;
  OtpSent? _sent;

  @override
  void initState() {
    super.initState();
    try {
      _code.text = ref.read(preferencesProvider).lastAdvocateCode ?? '';
    } catch (_) {}
  }

  @override
  void dispose() {
    _code.dispose();
    _mobile.dispose();
    _otp.dispose();
    super.dispose();
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.isNetwork ? context.l10n.errorNetwork : e.message);
    } catch (_) {
      if (mounted) setState(() => _error = context.l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _lookup() => _run(() async {
        final code = _code.text.trim();
        final info = await _repo.register(code);
        try {
          await ref.read(preferencesProvider).setLastAdvocateCode(code);
        } catch (_) {}
        setState(() {
          _info = info;
          _step = _Step.confirm;
        });
      });

  Future<void> _sendOtp() => _run(() async {
        final sent = await _repo.sendOtp(_info!.advocateCode, _mobile.text.trim());
        setState(() {
          _sent = sent;
          _step = _Step.otp;
        });
      });

  Future<void> _verify() => _run(() async {
        await _repo.verifyOtp(_info!.advocateCode, _mobile.text.trim(), _otp.text.trim(), deviceLabel: 'mobile app');
        await ref.read(sessionProvider.notifier).completeLogin();
      });

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
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: KeyedSubtree(key: ValueKey(_step), child: _stepBody(context)),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Semantics(
                    liveRegion: true,
                    child: Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: t.colorScheme.error)),
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

  Widget _primary(String label, VoidCallback? onPressed) => FilledButton(
        onPressed: _busy ? null : onPressed,
        child: _busy
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
            : Text(label),
      );

  Widget _stepBody(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context);
    switch (_step) {
      case _Step.code:
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(l.loginTitle, style: t.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(l.loginSubtitle, style: t.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            key: const Key('advocateCodeField'),
            controller: _code,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)],
            decoration: InputDecoration(labelText: l.advocateCode, hintText: l.advocateCodeHint),
            onSubmitted: (_) => _lookup(),
          ),
          const SizedBox(height: AppSpacing.lg),
          _primary(l.continueAction, () => _code.text.trim().isEmpty ? null : _lookup()),
        ]);
      case _Step.confirm:
        final info = _info!;
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(l.isThisYou, style: t.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(color: AppColors.goldSoft, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(info.advocateName,
                  key: const Key('advocateNameText'),
                  style: t.textTheme.titleMedium?.copyWith(color: AppColors.navy)),
              Text('${l.advocateCode}: ${info.advocateCode}', style: const TextStyle(color: AppColors.navy)),
              const SizedBox(height: 4),
              Text(l.source(info.source), style: t.textTheme.bodySmall?.copyWith(color: AppColors.muted)),
            ]),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l.identityNote, style: t.textTheme.bodySmall),
          if (info.registeredMobileHint != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(l.registeredMobileHint(info.registeredMobileHint!), style: t.textTheme.bodySmall),
          ],
          if (!info.otpAvailable) ...[
            const SizedBox(height: AppSpacing.md),
            Text(l.otpUnavailable, style: TextStyle(color: t.colorScheme.error)),
          ],
          const SizedBox(height: AppSpacing.lg),
          _primary(l.identityConfirm, info.otpAvailable ? () => setState(() => _step = _Step.mobile) : null),
          TextButton(onPressed: () => setState(() => _step = _Step.code), child: Text(l.identityDeny)),
        ]);
      case _Step.mobile:
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(l.mobileNumber, style: t.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            key: const Key('mobileField'),
            controller: _mobile,
            keyboardType: TextInputType.phone,
            autofillHints: const [AutofillHints.telephoneNumber],
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')), LengthLimitingTextInputFormatter(14)],
            decoration: InputDecoration(labelText: l.mobileNumber, hintText: l.mobileHint, prefixText: '+91 '),
          ),
          const SizedBox(height: AppSpacing.lg),
          _primary(l.sendOtp, _sendOtp),
          TextButton(onPressed: () => setState(() => _step = _Step.confirm), child: Text(l.cancel)),
        ]);
      case _Step.otp:
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(l.enterOtp(_sent?.sentTo ?? ''), style: t.textTheme.titleMedium),
          if (_sent?.devOtp != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(l.devOtpNotice(_sent!.devOtp!), style: const TextStyle(color: AppColors.warning)),
          ],
          const SizedBox(height: AppSpacing.lg),
          TextField(
            key: const Key('otpField'),
            controller: _otp,
            keyboardType: TextInputType.number,
            autofillHints: const [AutofillHints.oneTimeCode],
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, letterSpacing: 8),
            decoration: const InputDecoration(hintText: '••••••'),
            onSubmitted: (_) => _verify(),
          ),
          const SizedBox(height: AppSpacing.lg),
          _primary(l.verifyOtp, _verify),
          TextButton(onPressed: _busy ? null : _sendOtp, child: Text(l.sendOtp)),
        ]);
    }
  }
}
