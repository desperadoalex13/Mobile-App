import '../../dish_library/domain/dish_model.dart';
import '../../dish_library/domain/product_model.dart';
import '../../meal_plan/domain/meal_plan_model.dart';

class ShoppingList {
  ShoppingList({required this.items});

  final List<ShoppingItem> items;

  Map<String, List<ShoppingItem>> get groupedByCategory {
    final grouped = <String, List<ShoppingItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    return grouped;
  }

  /// Aggregates ingredient amounts for every dish referenced anywhere in
  /// [mealPlan]'s week, grouped by ingredient name + unit. The list is
  /// regenerated on every read — only [purchasedKeys] is persisted.
  factory ShoppingList.fromMealPlan({
    required MealPlan? mealPlan,
    required List<Dish> dishes,
    required List<ProductEntry> products,
    required Set<String> purchasedKeys,
    required String otherCategory,
  }) {
    if (mealPlan == null) return ShoppingList(items: []);

    final dishById = {for (final d in dishes) d.id: d};
    final categoryByProductId = {for (final p in products) p.id: p.category};

    final totals = <String, _Accumulator>{};
    for (final day in mealPlan.days) {
      for (final slot in day.mealSlots) {
        for (final dishId in slot.dishIds) {
          final dish = dishById[dishId];
          if (dish == null) continue;
          for (final ingredient in dish.ingredients) {
            final name = ingredient.name.trim();
            final key = '${name.toLowerCase()}|${ingredient.unit}';
            final category =
                categoryByProductId[ingredient.productId] ?? otherCategory;
            totals
                .putIfAbsent(
                    key, () => _Accumulator(name, ingredient.unit, category))
                .amount += ingredient.amountPerServing;
          }
        }
      }
    }

    final items = totals.entries.map((entry) {
      final acc = entry.value;
      return ShoppingItem(
        name: acc.name,
        totalAmount: double.parse(acc.amount.toStringAsFixed(2)),
        unit: acc.unit,
        category: acc.category,
        isPurchased: purchasedKeys.contains(entry.key),
      );
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return ShoppingList(items: items);
  }
}

class _Accumulator {
  _Accumulator(this.name, this.unit, this.category);
  final String name;
  final String unit;
  final String category;
  double amount = 0;
}

class ShoppingItem {
  ShoppingItem({
    required this.name,
    required this.totalAmount,
    required this.unit,
    required this.category,
    this.isPurchased = false,
  });

  final String name;
  final double totalAmount;
  final String unit;
  final String category;
  final bool isPurchased;

  /// Stable key used to persist checked-off state across regenerations.
  String get key => '${name.toLowerCase()}|$unit';
}
