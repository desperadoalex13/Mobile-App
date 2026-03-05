import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/dish_library/domain/dish_model.dart';

// ignore: subtype_of_sealed_class
class _FakeDoc extends Fake implements DocumentSnapshot {
  _FakeDoc(this._id, this._data);
  final String _id;
  final Map<String, dynamic> _data;

  @override
  String get id => _id;

  @override
  Object? data() => _data;
}

Ingredient _makeIngredient({
  double calories = 0,
  double protein = 0,
  double fat = 0,
  double carbs = 0,
}) =>
    Ingredient(
      productId: 'p1',
      name: 'Test',
      amountPerServing: 100,
      unit: 'g',
      caloriesPerServing: calories,
      proteinPerServing: protein,
      fatPerServing: fat,
      carbsPerServing: carbs,
    );

void main() {
  group('Ingredient', () {
    test('fromMap / toMap round-trip', () {
      final ing = _makeIngredient(calories: 100, protein: 5, fat: 3, carbs: 15);
      final map = ing.toMap();
      final restored = Ingredient.fromMap(map);

      expect(restored.productId, ing.productId);
      expect(restored.name, ing.name);
      expect(restored.amountPerServing, ing.amountPerServing);
      expect(restored.unit, ing.unit);
      expect(restored.caloriesPerServing, ing.caloriesPerServing);
      expect(restored.proteinPerServing, ing.proteinPerServing);
      expect(restored.fatPerServing, ing.fatPerServing);
      expect(restored.carbsPerServing, ing.carbsPerServing);
    });

    test('fromMap handles integer nutrition values', () {
      final map = {
        'productId': 'p2',
        'name': 'Egg',
        'amountPerServing': 60,
        'unit': 'g',
        'calories': 80,
        'protein': 6,
        'fat': 5,
        'carbs': 1,
      };
      final ing = Ingredient.fromMap(map);
      expect(ing.caloriesPerServing, 80.0);
      expect(ing.proteinPerServing, 6.0);
    });
  });

  group('Dish nutrition aggregation', () {
    Dish makeDish(List<Ingredient> ingredients) => Dish(
          id: 'd1',
          name: 'Test Dish',
          servings: 2,
          ingredients: ingredients,
        );

    test('empty dish has zero totals', () {
      final dish = makeDish([]);
      expect(dish.totalCalories, 0.0);
      expect(dish.totalProtein, 0.0);
      expect(dish.totalFat, 0.0);
      expect(dish.totalCarbs, 0.0);
    });

    test('sums calories across ingredients', () {
      final dish = makeDish([
        _makeIngredient(calories: 100),
        _makeIngredient(calories: 200),
      ]);
      expect(dish.totalCalories, 300.0);
    });

    test('sums protein across ingredients', () {
      final dish = makeDish([
        _makeIngredient(protein: 10),
        _makeIngredient(protein: 5),
      ]);
      expect(dish.totalProtein, 15.0);
    });

    test('sums fat across ingredients', () {
      final dish = makeDish([
        _makeIngredient(fat: 8),
        _makeIngredient(fat: 2),
      ]);
      expect(dish.totalFat, 10.0);
    });

    test('sums carbs across ingredients', () {
      final dish = makeDish([
        _makeIngredient(carbs: 20),
        _makeIngredient(carbs: 30),
      ]);
      expect(dish.totalCarbs, 50.0);
    });
  });

  group('Dish serialisation', () {
    test('toFirestore / fromFirestore round-trip', () {
      final original = Dish(
        id: 'dish1',
        name: 'Pasta',
        servings: 4,
        ingredients: [_makeIngredient(calories: 150)],
        instructions: ['Boil water', 'Cook pasta'],
        extraFields: {'source': 'grandma'},
      );

      final map = original.toFirestore();
      final doc = _FakeDoc('dish1', map);
      final restored = Dish.fromFirestore(doc);

      expect(restored.id, 'dish1');
      expect(restored.name, 'Pasta');
      expect(restored.servings, 4);
      expect(restored.ingredients.length, 1);
      expect(restored.instructions, ['Boil water', 'Cook pasta']);
      expect(restored.extraFields, {'source': 'grandma'});
    });

    test('instructions default to empty list when absent', () {
      final doc = _FakeDoc('d1', {
        'name': 'Soup',
        'servings': 2,
        'ingredients': [],
        // no instructions
        'extra': {},
      });
      final dish = Dish.fromFirestore(doc);
      expect(dish.instructions, isEmpty);
    });
  });
}
