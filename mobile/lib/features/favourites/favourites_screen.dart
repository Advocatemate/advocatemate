import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/models/models.dart';
import '../../shared/personal_repository.dart';
import '../../shared/widgets/widgets.dart';
import '../../theme/app_theme.dart';
import '../my_cause_list/my_cause_list_screen.dart';

final favouriteAdvocatesProvider =
    FutureProvider.autoDispose<List<FavouriteAdvocate>>((ref) => ref.watch(personalRepositoryProvider).favouriteAdvocates());
final favouriteCasesProvider =
    FutureProvider.autoDispose<List<FavouriteCase>>((ref) => ref.watch(personalRepositoryProvider).favouriteCases());

class FavouritesScreen extends ConsumerWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.navFavourites),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0xFFB7C2D6),
            indicatorColor: AppColors.gold,
            tabs: [Tab(text: l.favouriteCases), Tab(text: l.favouriteAdvocates)],
          ),
        ),
        body: const TabBarView(children: [_CasesTab(), _AdvocatesTab()]),
      ),
    );
  }
}

class _CasesTab extends ConsumerWidget {
  const _CasesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return AsyncBody<List<FavouriteCase>>(
      value: ref.watch(favouriteCasesProvider),
      onRetry: () => ref.invalidate(favouriteCasesProvider),
      builder: (items) => RefreshIndicator(
        onRefresh: () => refreshProvider(ref, favouriteCasesProvider),
        child: items.isEmpty
            ? ListView(children: [EmptyState(message: l.emptyFavourites, icon: Icons.bookmark_border)])
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final f = items[i];
                  return Dismissible(
                    key: ValueKey(f.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: AppColors.danger,
                        child: const Icon(Icons.delete_outline, color: Colors.white)),
                    onDismissed: (_) async {
                      try {
                        await ref.read(personalRepositoryProvider).removeFavouriteCase(f.id);
                      } catch (e) {
                        if (context.mounted) showError(context, e);
                      }
                      ref.invalidate(favouriteCasesProvider);
                    },
                    child: CaseCard(
                      caseNumber: f.caseNumber,
                      petitioner: f.petitioner,
                      respondent: f.respondent,
                      subtitle: f.note,
                      onTap: () => openCase(context, caseId: f.caseId),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _AdvocatesTab extends ConsumerWidget {
  const _AdvocatesTab();

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final c = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.addAdvocate),
        content: TextField(
          controller: c,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)],
          decoration: InputDecoration(labelText: l.advocateCode),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: Text(l.save)),
        ],
      ),
    );
    if (code == null || code.isEmpty) return;
    try {
      await ref.read(personalRepositoryProvider).addFavouriteAdvocate(code);
      ref.invalidate(favouriteAdvocatesProvider);
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, ref),
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(l.addAdvocate),
      ),
      body: AsyncBody<List<FavouriteAdvocate>>(
        value: ref.watch(favouriteAdvocatesProvider),
        onRetry: () => ref.invalidate(favouriteAdvocatesProvider),
        builder: (items) => RefreshIndicator(
          onRefresh: () => refreshProvider(ref, favouriteAdvocatesProvider),
          child: items.isEmpty
              ? ListView(children: [EmptyState(message: l.emptyFavourites, icon: Icons.people_outline)])
              : ListView(padding: const EdgeInsets.all(AppSpacing.lg), children: [
                  for (final f in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Card(
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                          title: Text(f.advocateName ?? f.advocateCode),
                          subtitle: Text('${l.advocateCode}: ${f.advocateCode}'),
                          onTap: () => context.push('/advocate/${f.advocateCode}'),
                          trailing: IconButton(
                            tooltip: l.removeFavourite,
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              try {
                                await ref.read(personalRepositoryProvider).removeFavouriteAdvocate(f.id);
                              } catch (e) {
                                if (context.mounted) showError(context, e);
                              }
                              ref.invalidate(favouriteAdvocatesProvider);
                            },
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 80),
                ]),
        ),
      ),
    );
  }
}

/// Bookmark toggle used on the case-details app bar.
class FavouriteCaseButton extends ConsumerWidget {
  const FavouriteCaseButton({super.key, required this.caseId});
  final String caseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final favs = ref.watch(favouriteCasesProvider).value ?? const [];
    FavouriteCase? existing;
    for (final f in favs) {
      if (f.caseId == caseId) existing = f;
    }
    return IconButton(
      tooltip: existing == null ? l.addFavourite : l.removeFavourite,
      icon: Icon(existing == null ? Icons.bookmark_border : Icons.bookmark, color: AppColors.gold),
      onPressed: () async {
        final repo = ref.read(personalRepositoryProvider);
        try {
          if (existing != null) {
            await repo.removeFavouriteCase(existing.id);
          } else {
            await repo.addFavouriteCase(caseId: caseId);
          }
        } catch (e) {
          if (context.mounted) showError(context, e);
        }
        ref.invalidate(favouriteCasesProvider);
      },
    );
  }
}
