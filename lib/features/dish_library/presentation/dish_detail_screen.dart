import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../domain/dish_model.dart';

class DishDetailScreen extends StatelessWidget {
  const DishDetailScreen({super.key, required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasIngredients = dish.ingredients.isNotEmpty;
    final hasInstructions = dish.instructions.isNotEmpty;
    final servingLabel =
        '${dish.servings} serving${dish.servings == 1 ? '' : 's'}';

    return Scaffold(
      appBar: AppBar(
        title: Text(dish.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => context.push(AppRoutes.dishForm, extra: dish),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info row ────────────────────────────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(label: Text(servingLabel)),
                if (hasIngredients)
                  Chip(
                    label: Text('${dish.totalCalories.round()} kcal'),
                  ),
                ...dish.labels.map(
                  (l) => Chip(
                    label: Text(l),
                    backgroundColor: colorScheme.primaryContainer,
                    labelStyle:
                        TextStyle(color: colorScheme.onPrimaryContainer),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Nutrition card ───────────────────────────────────────────────
            if (hasIngredients) ...[
              _NutritionCard(dish: dish),
              const SizedBox(height: 24),
            ],

            // ── Ingredients ──────────────────────────────────────────────────
            const _DetailSection(title: 'Ingredients'),
            const SizedBox(height: 8),
            if (!hasIngredients)
              Text(
                'No ingredients listed.',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              )
            else
              ...dish.ingredients.map(
                (ing) => Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    dense: true,
                    title: Text(ing.name),
                    trailing: Text(
                      '${_fmtNum(ing.amountPerServing)} ${ing.unit}  ·  '
                      '${ing.caloriesPerServing.round()} kcal',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ),

            // ── Instructions ─────────────────────────────────────────────────
            if (hasInstructions) ...[
              const SizedBox(height: 24),
              const _DetailSection(title: 'Instructions'),
              const SizedBox(height: 8),
              ...dish.instructions.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${e.key + 1}.',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(e.value),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Nutrition card
// ============================================================================

class _NutritionCard extends StatelessWidget {
  const _NutritionCard({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutrition per serving',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCell(
                    label: 'Calories',
                    value: '${dish.totalCalories.toStringAsFixed(1)} kcal'),
                _StatCell(
                    label: 'Protein',
                    value: '${dish.totalProtein.toStringAsFixed(1)} g'),
                _StatCell(
                    label: 'Fat',
                    value: '${dish.totalFat.toStringAsFixed(1)} g'),
                _StatCell(
                    label: 'Carbs',
                    value: '${dish.totalCarbs.toStringAsFixed(1)} g'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

// ============================================================================
// Section header
// ============================================================================

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }
}

// ============================================================================
// Helpers
// ============================================================================

String _fmtNum(double v) =>
    v % 1 == 0 ? v.toInt().toString() : v.toString();
