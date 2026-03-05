import 'package:cloud_firestore/cloud_firestore.dart';

class Dish {
  Dish({
    required this.id,
    required this.name,
    required this.servings,
    required this.ingredients,
    this.instructions = const [],
    this.extraFields = const {},
  });

  final String id;
  final String name;
  final int servings;
  final List<Ingredient> ingredients;
  final List<String> instructions;

  /// Extensible field map — new fields can be added without schema migration.
  final Map<String, dynamic> extraFields;

  factory Dish.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Dish(
      id: doc.id,
      name: data['name'] as String,
      servings: data['servings'] as int,
      ingredients: (data['ingredients'] as List<dynamic>)
          .map((i) => Ingredient.fromMap(i as Map<String, dynamic>))
          .toList(),
      instructions: List<String>.from(data['instructions'] ?? []),
      extraFields: Map<String, dynamic>.from(data['extra'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'servings': servings,
        'ingredients': ingredients.map((i) => i.toMap()).toList(),
        'instructions': instructions,
        'extra': extraFields,
      };

  double get totalCalories =>
      ingredients.fold(0, (acc, i) => acc + i.caloriesPerServing);

  double get totalProtein =>
      ingredients.fold(0, (acc, i) => acc + i.proteinPerServing);

  double get totalFat =>
      ingredients.fold(0, (acc, i) => acc + i.fatPerServing);

  double get totalCarbs =>
      ingredients.fold(0, (acc, i) => acc + i.carbsPerServing);
}

class Ingredient {
  Ingredient({
    required this.productId,
    required this.name,
    required this.amountPerServing,
    required this.unit,
    required this.caloriesPerServing,
    required this.proteinPerServing,
    required this.fatPerServing,
    required this.carbsPerServing,
  });

  final String productId;
  final String name;
  final double amountPerServing;
  final String unit;
  final double caloriesPerServing;
  final double proteinPerServing;
  final double fatPerServing;
  final double carbsPerServing;

  factory Ingredient.fromMap(Map<String, dynamic> map) => Ingredient(
        productId: map['productId'] as String,
        name: map['name'] as String,
        amountPerServing: (map['amountPerServing'] as num).toDouble(),
        unit: map['unit'] as String,
        caloriesPerServing: (map['calories'] as num).toDouble(),
        proteinPerServing: (map['protein'] as num).toDouble(),
        fatPerServing: (map['fat'] as num).toDouble(),
        carbsPerServing: (map['carbs'] as num).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'name': name,
        'amountPerServing': amountPerServing,
        'unit': unit,
        'calories': caloriesPerServing,
        'protein': proteinPerServing,
        'fat': fatPerServing,
        'carbs': carbsPerServing,
      };
}
