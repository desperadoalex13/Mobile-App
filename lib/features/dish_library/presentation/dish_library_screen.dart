import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../data/csv_dish_parser.dart';
import '../data/dish_repository.dart';
import '../data/dish_seeder.dart';
import '../domain/dish_model.dart';
import 'dish_providers.dart';

class DishLibraryScreen extends ConsumerStatefulWidget {
  const DishLibraryScreen({super.key});

  @override
  ConsumerState<DishLibraryScreen> createState() => _DishLibraryScreenState();
}

class _DishLibraryScreenState extends ConsumerState<DishLibraryScreen> {
  bool _importing = false;
  String _activeFilter = '';

  Future<void> _saveDishes(
      List<Dish> dishes, String successMessage) async {
    setState(() => _importing = true);
    try {
      final repo = ref.read(dishRepositoryProvider);
      for (final dish in dishes) {
        await repo.saveDish(dish);
      }
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(successMessage)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.importFailed),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _importFromCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );
    if (result == null || result.files.isEmpty || !mounted) return;

    final bytes = result.files.single.bytes;
    if (bytes == null) return;

    final dishes = CsvDishParser.parse(utf8.decode(bytes, allowMalformed: true));

    if (!mounted) return;
    final l10n = context.l10n;
    if (dishes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noDishesInFile)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.importCsvDialogTitle),
        content: Text(l10n.importCsvDialogContent(dishes.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.importFromCsvButton),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _saveDishes(dishes, context.l10n.csvImportSuccess(dishes.length));
  }

  Future<void> _confirmImport() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.importStarterDialogTitle),
        content: Text(l10n.importStarterDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.importStarterButton),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _saveDishes(
        DishSeeder.starterDishes, context.l10n.starterImportSuccess);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dishesAsync = ref.watch(dishesProvider);

    ref.listen(dishMutationProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.operationFailed),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'import-csv',
            tooltip: l10n.importCsvTooltip,
            onPressed: _importing ? null : _importFromCsv,
            child: const Icon(Icons.upload_file_outlined),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'add-dish',
            tooltip: l10n.addDishTooltip,
            onPressed: () => context.push(AppRoutes.dishForm),
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: dishesAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(
          message: l10n.loadDishesError,
          onRetry: () => ref.invalidate(dishesProvider),
        ),
        data: (dishes) {
          if (dishes.isEmpty) {
            return _EmptyState(
              onAdd: () => context.push(AppRoutes.dishForm),
              onImport: _importing ? null : _confirmImport,
              onImportCsv: _importing ? null : _importFromCsv,
            );
          }
          final filtered = _activeFilter.isEmpty
              ? dishes
              : dishes
                  .where((d) => d.labels.contains(_activeFilter))
                  .toList();
          return Stack(
            children: [
              Column(
                children: [
                  _LabelFilterBar(
                    active: _activeFilter,
                    onChanged: (label) =>
                        setState(() => _activeFilter = label),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(
                              l10n.noFilteredDishes(_activeFilter),
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, i) =>
                                _DishTile(dish: filtered[i]),
                          ),
                  ),
                ],
              ),
              if (_importing)
                Positioned(
                  top: 8,
                  right: 16,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Text(l10n.importingIndicator),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
// Label filter bar
// ============================================================================

class _LabelFilterBar extends StatelessWidget {
  const _LabelFilterBar({required this.active, required this.onChanged});

  final String active;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: Text(l10n.all),
            selected: active.isEmpty,
            onSelected: (_) => onChanged(''),
          ),
          ...Dish.availableLabels.map((label) {
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: FilterChip(
                label: Text(context.localizeLabel(label)),
                selected: active == label,
                onSelected: (_) => onChanged(active == label ? '' : label),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================================
// Empty state
// ============================================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd, this.onImport, this.onImportCsv});

  final VoidCallback onAdd;
  final VoidCallback? onImport;
  final VoidCallback? onImportCsv;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noDishesTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noDishesDescription,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(l10n.addDishButton),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.download_outlined),
              label: Text(l10n.importStarterButton),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onImportCsv,
              icon: const Icon(Icons.upload_file_outlined),
              label: Text(l10n.importFromCsvButton),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Dish tile in the list
// ============================================================================

class _DishTile extends ConsumerWidget {
  const _DishTile({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final calorieLabel = '${dish.totalCalories.round()} ${l10n.kcal}';
    final labelText = dish.labels.isEmpty
        ? ''
        : '  ·  ${dish.labels.map(context.localizeLabel).join(', ')}';

    return ListTile(
      title: Text(dish.name),
      subtitle: Text('$calorieLabel$labelText'),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            context.push(AppRoutes.dishForm, extra: dish);
          } else if (value == 'delete') {
            _confirmDelete(context, ref);
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
          PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
        ],
      ),
      onTap: () => context.push(AppRoutes.dishDetail, extra: dish),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteDishTitle),
        content: Text(l10n.deleteDishContent(dish.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(dishMutationProvider.notifier).deleteDish(dish.id);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
