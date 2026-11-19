import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/widgets/widgets.dart';
import '../../theme/app_theme.dart';
import '../authentication/auth_repository.dart';
import '../authentication/session_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final _displayName = TextEditingController(text: ref.read(currentMeProvider)?.displayName ?? '');
  late final _email = TextEditingController(text: ref.read(currentMeProvider)?.email ?? '');
  bool _saving = false;

  @override
  void dispose() {
    _displayName.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final me = await ref.read(authRepositoryProvider).updateMe(displayName: _displayName.text.trim(), email: _email.text.trim());
      ref.read(sessionProvider.notifier).update(me);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final me = ref.watch(currentMeProvider);
    if (me == null) return const Scaffold(body: SizedBox.shrink());
    final verified = me.identityVerification == 'registry_verified';
    return Scaffold(
      appBar: AppBar(title: Text(l.profile)),
      body: ListView(padding: const EdgeInsets.all(AppSpacing.lg), children: [
        SectionCard(
          title: l.profile,
          child: Column(children: [
            // Source-owned fields: read only.
            LabelValue(l.advocateName, me.advocateName ?? '-'),
            LabelValue(l.advocateCode, me.advocateCode ?? '-'),
            LabelValue(l.googleAccount, me.googleEmail ?? '-'),
            Row(children: [
              SizedBox(width: 140, child: Text(l.identityStatus, style: Theme.of(context).textTheme.bodySmall)),
              Flexible(
                child: StatusChip(verified ? l.identityRegistryVerified : l.notYetAvailable,
                    color: verified ? AppColors.success : AppColors.warning,
                    icon: verified ? Icons.verified_outlined : null),
              ),
            ]),
          ]),
        ),
        const SizedBox(height: AppSpacing.lg),
        SectionCard(
          title: l.settings,
          child: Column(children: [
            TextField(controller: _displayName, decoration: const InputDecoration(labelText: 'Display name')),
            const SizedBox(height: AppSpacing.md),
            TextField(
                controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(onPressed: _saving ? null : _save, child: Text(l.save)),
          ]),
        ),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton.icon(
          key: const Key('switchGoogleAccount'),
          onPressed: () => ref.read(sessionProvider.notifier).useDifferentAccount(),
          icon: const Icon(Icons.switch_account_outlined),
          label: Text(l.switchGoogleAccount),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: () => ref.read(sessionProvider.notifier).logout(),
          icon: const Icon(Icons.logout),
          label: Text(l.logout),
        ),
      ]),
    );
  }
}
