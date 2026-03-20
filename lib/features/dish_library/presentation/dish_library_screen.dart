import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_indicator.dart';
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

  Future<void> _confirmImport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import starter dishes?'),
        content: const Text(
          '7 breakfast dishes will be added to your library. '
          'Existing dishes with the same ID will be overwritten.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _importing = true);
    try {
      final repo = ref.read(dishRepositoryProvider);
      for (final dish in DishSeeder.starterDishes) {
        await repo.saveDish(dish);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('7 dishes imported successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Import failed. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dishesAsync = ref.watch(dishesProvider);

    ref.listen(dishMutationProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Operation failed. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'add-dish',
        tooltip: 'Add dish',
        onPressed: () => context.push(AppRoutes.dishForm),
        child: const Icon(Icons.add),
      ),
      body: dishesAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(
          message: 'Could not load dishes.',
          onRetry: () => ref.invalidate(dishesProvider),
        ),
        data: (dishes) => dishes.isEmpty
            ? _EmptyState(
                onAdd: () => context.push(AppRoutes.dishForm),
                onImport: _importing ? null : _confirmImport,
              )
            : Stack(
                children: [
                  ListView.separated(
                    itemCount: dishes.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) => _DishTile(dish: dishes[i]),
                  ),
                  if (_importing)
                    const Positioned(
                      top: 8,
                      right: 16,
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text('Importing…'),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

// ============================================================================
// Empty state
// ============================================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd, this.onImport});

  final VoidCallback onAdd;
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
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
              'No dishes yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Build your personal recipe library.\nTap the button below to add your first dish.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Dish'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.download_outlined),
              label: const Text('Import starter dishes'),
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
    final servingLabel =
        '${dish.servings} serving${dish.servings == 1 ? '' : 's'}';
    final calorieLabel = '${dish.totalCalories.round()} kcal';

    return ListTile(
      title: Text(dish.name),
      subtitle: Text('$servingLabel · $calorieLabel'),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            context.push(AppRoutes.dishForm, extra: dish);
          } else if (value == 'delete') {
            _confirmDelete(context, ref);
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
      onTap: () => context.push(AppRoutes.dishDetail, extra: dish),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete dish?'),
        content: Text(
          'Delete "${dish.name}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(dishMutationProvider.notifier).deleteDish(dish.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
