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
    final t = Theme.of(context);
    final tk = context.tokens;
    final me = ref.watch(currentMeProvider);
    if (me == null) return const Scaffold(body: SizedBox.shrink());
    final verified = me.identityVerification == 'registry_verified';
    final name = me.displayName ?? me.advocateName ?? '';
    return Scaffold(
      appBar: AppBar(title: Text(l.profile)),
      body: ListView(
        padding: AppLayout.page(context, top: AppSpacing.sm, bottom: AppSpacing.xxl),
        children: [
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                AvatarInitials(name: name, size: 72),
                const SizedBox(height: AppSpacing.md),
                Text(me.advocateName ?? name, textAlign: TextAlign.center, style: t.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  '${l.advocateCode}: ${me.advocateCode ?? '-'}',
                  style: t.textTheme.bodySmall?.copyWith(color: tk.goldText),
                ),
                const SizedBox(height: AppSpacing.md),
                StatusChip(
                  verified ? l.identityRegistryVerified : l.notYetAvailable,
                  color: verified ? AppColors.success : AppColors.warning,
                  icon: verified ? AppIcons.verified : AppIcons.clock,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            title: l.profile,
            icon: AppIcons.profile,
            child: Column(
              children: [
                // Source-owned fields: read only.
                LabelValue(l.advocateName, me.advocateName ?? '-'),
                LabelValue(l.advocateCode, me.advocateCode ?? '-'),
                LabelValue(l.googleAccount, me.googleEmail ?? '-'),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      SizedBox(width: 132, child: Text(l.identityStatus, style: t.textTheme.bodySmall)),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: StatusChip(
                          verified ? l.identityVerified : l.notYetAvailable,
                          color: verified ? AppColors.success : AppColors.warning,
                          icon: verified ? AppIcons.verified : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            title: l.settings,
            icon: AppIcons.settings,
            child: Column(
              children: [
                TextField(
                  controller: _displayName,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                    prefixIcon: Icon(AppIcons.advocate, size: 18),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(AppIcons.email, size: 18)),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(onPressed: _save, busy: _saving, label: l.save),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          MenuGroup(
            children: [
              MenuRow(
                key: const Key('switchGoogleAccount'),
                icon: AppIcons.switchAccount,
                label: l.switchGoogleAccount,
                trailing: const SizedBox.shrink(),
                onTap: () => ref.read(sessionProvider.notifier).useDifferentAccount(),
              ),
              MenuRow(
                icon: AppIcons.logout,
                label: l.logout,
                destructive: true,
                trailing: const SizedBox.shrink(),
                onTap: () => ref.read(sessionProvider.notifier).logout(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
