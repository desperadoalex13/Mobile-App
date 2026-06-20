import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/dish_library/domain/dish_model.dart';
import 'package:mobile_app/features/dish_library/domain/product_model.dart';
import 'package:mobile_app/features/meal_plan/domain/meal_plan_model.dart';
import 'package:mobile_app/features/shopping_list/domain/shopping_list_model.dart';

ShoppingItem _item({
  String name = 'Milk',
  String category = 'Dairy',
  bool isPurchased = false,
}) =>
    ShoppingItem(
      name: name,
      totalAmount: 1.0,
      unit: 'L',
      category: category,
      isPurchased: isPurchased,
    );

Ingredient _ingredient({
  required String productId,
  required String name,
  required double amountPerServing,
  String unit = 'g',
}) =>
    Ingredient(
      productId: productId,
      name: name,
      amountPerServing: amountPerServing,
      unit: unit,
      caloriesPerServing: 0,
      proteinPerServing: 0,
      fatPerServing: 0,
      carbsPerServing: 0,
    );

void main() {
  group('ShoppingItem', () {
    test('key is built from lowercased name + unit', () {
      final item = _item(name: 'Milk');
      expect(item.key, 'milk|L');
    });
  });

  group('ShoppingList.groupedByCategory', () {
    test('groups items by category', () {
      final list = ShoppingList(items: [
        _item(name: 'a', category: 'Dairy'),
        _item(name: 'b', category: 'Produce'),
        _item(name: 'c', category: 'Dairy'),
      ]);
      final grouped = list.groupedByCategory;
      expect(grouped.keys, containsAll(['Dairy', 'Produce']));
      expect(grouped['Dairy']!.length, 2);
      expect(grouped['Produce']!.length, 1);
    });

    test('is empty for empty list', () {
      expect(ShoppingList(items: []).groupedByCategory, isEmpty);
    });
  });

  group('ShoppingList.fromMealPlan', () {
    final chicken = Dish(
      id: 'dish_chicken',
      name: 'Chicken',
      servings: 1,
      ingredients: [
        _ingredient(productId: 'chicken_breast', name: 'Chicken breast', amountPerServing: 150),
        _ingredient(productId: 'rice', name: 'Rice', amountPerServing: 100),
      ],
    );

    MealPlan planWithDish(String dishId, {int occurrences = 1}) {
      final slots = List.generate(
        occurrences,
        (i) => MealSlot(name: 'Slot$i', dishIds: [dishId]),
      );
      return MealPlan(
        id: '2026-01-05',
        weekStartDate: DateTime(2026, 1, 5),
        days: [DayPlan(date: DateTime(2026, 1, 5), mealSlots: slots)],
      );
    }

    test('returns empty list when mealPlan is null', () {
      final list = ShoppingList.fromMealPlan(
        mealPlan: null,
        dishes: [chicken],
        products: [],
        purchasedKeys: {},
        otherCategory: 'Other',
      );
      expect(list.items, isEmpty);
    });

    test('aggregates ingredient amounts across occurrences of the same dish', () {
      final list = ShoppingList.fromMealPlan(
        mealPlan: planWithDish('dish_chicken', occurrences: 2),
        dishes: [chicken],
        products: [],
        purchasedKeys: {},
        otherCategory: 'Other',
      );
      final chickenItem = list.items.firstWhere((i) => i.name == 'Chicken breast');
      expect(chickenItem.totalAmount, 300); // 150 * 2 occurrences
    });

    test('resolves category from matching product, falls back to otherCategory', () {
      final list = ShoppingList.fromMealPlan(
        mealPlan: planWithDish('dish_chicken'),
        dishes: [chicken],
        products: [
          ProductEntry(
            id: 'chicken_breast',
            name: 'Chicken breast',
            category: 'Meat & Poultry',
            kcalPer100: 0,
            proteinPer100: 0,
            fatPer100: 0,
            carbsPer100: 0,
          ),
        ],
        purchasedKeys: {},
        otherCategory: 'Other',
      );
      final chickenItem = list.items.firstWhere((i) => i.name == 'Chicken breast');
      final riceItem = list.items.firstWhere((i) => i.name == 'Rice');
      expect(chickenItem.category, 'Meat & Poultry');
      expect(riceItem.category, 'Other');
    });

    test('marks items purchased when their key is in purchasedKeys', () {
      final list = ShoppingList.fromMealPlan(
        mealPlan: planWithDish('dish_chicken'),
        dishes: [chicken],
        products: [],
        purchasedKeys: {'rice|g'},
        otherCategory: 'Other',
      );
      final riceItem = list.items.firstWhere((i) => i.name == 'Rice');
      final chickenItem = list.items.firstWhere((i) => i.name == 'Chicken breast');
      expect(riceItem.isPurchased, isTrue);
      expect(chickenItem.isPurchased, isFalse);
    });

    test('ignores dish IDs that no longer exist in the library', () {
      final list = ShoppingList.fromMealPlan(
        mealPlan: planWithDish('missing_dish'),
        dishes: [chicken],
        products: [],
        purchasedKeys: {},
        otherCategory: 'Other',
      );
      expect(list.items, isEmpty);
    });
  });
}
