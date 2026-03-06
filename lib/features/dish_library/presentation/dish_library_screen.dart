import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../domain/dish_model.dart';
import 'dish_providers.dart';

class DishLibraryScreen extends ConsumerWidget {
  const DishLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            ? _EmptyState(onAdd: () => context.push(AppRoutes.dishForm))
            : ListView.separated(
                itemCount: dishes.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) => _DishTile(dish: dishes[i]),
              ),
      ),
    );
  }
}

// ============================================================================
// Empty state
// ============================================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

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
