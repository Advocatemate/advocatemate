import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/providers.dart';
import '../../shared/personal_repository.dart';
import '../../shared/widgets/widgets.dart';
import '../../theme/app_theme.dart';
import '../favourites/favourites_screen.dart';
import '../my_cause_list/my_cause_list_screen.dart';

final _advocateCodeRe = RegExp(r'^\d{1,8}$');

/// Advocate code-wise view of the Daily cause list: any advocate's cases by code.
/// Data comes from the High Court's Lexika service (no CAPTCHA), the same source as My Cause List.
class AdvocateLookupPanel extends ConsumerStatefulWidget {
  const AdvocateLookupPanel({super.key, this.initialCode});
  final String? initialCode;

  @override
  ConsumerState<AdvocateLookupPanel> createState() => _AdvocateLookupPanelState();
}

class _AdvocateLookupPanelState extends ConsumerState<AdvocateLookupPanel> {
  final _field = TextEditingController();
  String? _code;
  String? _error;
  List<String> _recent = const [];

  @override
  void initState() {
    super.initState();
    _recent = ref.read(preferencesProvider).recentAdvocateCodes;
    final initial = widget.initialCode;
    if (initial != null && _advocateCodeRe.hasMatch(initial)) {
      _field.text = initial;
      _code = initial;
    }
  }

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  Future<void> _submit(String raw) async {
    final code = raw.trim();
    if (!_advocateCodeRe.hasMatch(code)) {
      setState(() => _error = context.l10n.advocateLookupInvalid);
      return;
    }
    FocusScope.of(context).unfocus();
    _field.text = code;
    setState(() {
      _code = code;
      _error = null;
    });
    final prefs = ref.read(preferencesProvider);
    await prefs.addRecentAdvocateCode(code);
    if (mounted) setState(() => _recent = prefs.recentAdvocateCodes);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context);
    final muted = t.textTheme.bodySmall;
    final g = AppLayout.gutter(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: AppLayout.page(context, top: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  key: const Key('advocateLookupField'),
                  controller: _field,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.search,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)],
                  decoration: InputDecoration(
                    hintText: l.advocateLookupHint,
                    prefixIcon: const Icon(AppIcons.advocateCode, size: AppIcons.size),
                    errorText: _error,
                  ),
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  onSubmitted: _submit,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: FilledButton(
                  key: const Key('advocateLookupButton'),
                  // The app theme makes filled buttons full-width; inside this row it needs its own size.
                  style: FilledButton.styleFrom(minimumSize: const Size(88, 52)),
                  onPressed: () => _submit(_field.text),
                  child: Text(l.advocateLookupView),
                ),
              ),
            ],
          ),
        ),
        if (_recent.isNotEmpty)
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.fromLTRB(g, 6, g, 0),
              children: [
                Icon(AppIcons.history, size: 14, color: context.tokens.textTertiary),
                const SizedBox(width: 6),
                Center(child: Text('${l.advocateLookupRecent}:', style: muted)),
                const SizedBox(width: 8),
                for (final c in _recent)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(key: Key('recentAdvocate-$c'), label: Text(c), onPressed: () => _submit(c)),
                  ),
              ],
            ),
          ),
        if (_code == null)
          Expanded(
            child: ListView(
              children: [
                EmptyState(message: l.advocateLookupIntro, icon: AppIcons.advocateSearch),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: g + AppSpacing.sm),
                  child: Text(l.advocateLookupSource, textAlign: TextAlign.center, style: muted),
                ),
              ],
            ),
          )
        else ...[
          Padding(
            padding: EdgeInsets.fromLTRB(g, AppSpacing.md, g - AppSpacing.sm, 0),
            child: Row(
              children: [
                const IconBadge(AppIcons.advocate, size: 32, iconSize: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${l.advocateCode} $_code',
                    key: const Key('advocateLookupTitle'),
                    style: t.textTheme.titleSmall?.copyWith(color: t.colorScheme.primary),
                  ),
                ),
                _FavouriteToggle(code: _code!),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: g),
            child: Text(l.advocateLookupSource, style: muted?.copyWith(color: context.tokens.textTertiary)),
          ),
          Expanded(
            child: MyCauseListScreen(key: ValueKey(_code), advocateCode: _code, embedded: true),
          ),
        ],
      ],
    );
  }
}

/// Save / remove the looked-up advocate as a favourite (favourites drive listing alerts).
class _FavouriteToggle extends ConsumerWidget {
  const _FavouriteToggle({required this.code});
  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final favs = ref.watch(favouriteAdvocatesProvider).value ?? const [];
    final existing = favs.where((f) => f.advocateCode == code).firstOrNull;
    return IconButton(
      key: const Key('favouriteAdvocateToggle'),
      tooltip: existing == null ? l.addFavourite : l.removeFavourite,
      icon: Icon(
        existing == null ? AppIcons.save : AppIcons.savedOn,
        color: existing == null ? Theme.of(context).colorScheme.primary : context.tokens.goldText,
      ),
      onPressed: () async {
        final repo = ref.read(personalRepositoryProvider);
        try {
          if (existing == null) {
            await repo.addFavouriteAdvocate(code);
          } else {
            await repo.removeFavouriteAdvocate(existing.id);
          }
          ref.invalidate(favouriteAdvocatesProvider);
        } catch (e) {
          if (context.mounted) showError(context, e);
        }
      },
    );
  }
}
