import '../domain/dish_model.dart';

/// Pre-built starter dishes (Ukrainian breakfast menu).
/// Each dish uses a fixed ID prefixed with "seed_" so re-importing is safe
/// (Firestore set() overwrites the same document instead of duplicating).
abstract class DishSeeder {
  static List<Dish> get starterDishes => [
        _fishSandwiches(),
        _oatmeal(),
        _syrnyky(),
        _lazyVarenyky(),
        _mlyntsi(),
        _waffles(),
        _hotSandwiches(),
      ];

  // ---------------------------------------------------------------------------
  // Helper: scale a per-100 value to an actual amount
  // ---------------------------------------------------------------------------
  static double _n(double per100, double amount) =>
      double.parse((per100 * amount / 100).toStringAsFixed(2));

  // ---------------------------------------------------------------------------
  // Dishes
  // ---------------------------------------------------------------------------

  static Dish _fishSandwiches() => Dish(
        id: 'seed_fish_sandwiches',
        name: 'Бутерброди з рибою',
        servings: 3, // 3 sandwiches: 3 black + 3 white slices = 6 total
        ingredients: [
          Ingredient(
            productId: 'bread_white',
            name: 'Хліб чорний',
            amountPerServing: 30, // 1 slice per sandwich
            unit: 'g',
            caloriesPerServing: _n(214, 30),
            proteinPerServing: _n(7.3, 30),
            fatPerServing: _n(1.0, 30),
            carbsPerServing: _n(43.0, 30),
          ),
          Ingredient(
            productId: 'bread_white',
            name: 'Хліб білий',
            amountPerServing: 30,
            unit: 'g',
            caloriesPerServing: _n(265, 30),
            proteinPerServing: _n(9.0, 30),
            fatPerServing: _n(3.2, 30),
            carbsPerServing: _n(49.4, 30),
          ),
          Ingredient(
            productId: 'butter',
            name: 'Масло',
            amountPerServing: 16.7, // 50g / 3
            unit: 'g',
            caloriesPerServing: _n(717, 16.7),
            proteinPerServing: _n(0.9, 16.7),
            fatPerServing: _n(81.0, 16.7),
            carbsPerServing: _n(0.1, 16.7),
          ),
          Ingredient(
            productId: 'manual_fish',
            name: 'Риба',
            amountPerServing: 33.3, // 100g / 3
            unit: 'g',
            caloriesPerServing: _n(200, 33.3),
            proteinPerServing: _n(20.0, 33.3),
            fatPerServing: _n(13.0, 33.3),
            carbsPerServing: 0,
          ),
        ],
        instructions: [],
      );

  static Dish _oatmeal() => Dish(
        id: 'seed_oatmeal',
        name: 'Вівсянка',
        servings: 1,
        ingredients: [
          Ingredient(
            productId: 'oats_dry',
            name: 'Вівсянка',
            amountPerServing: 100,
            unit: 'g',
            caloriesPerServing: _n(389, 100),
            proteinPerServing: _n(17.0, 100),
            fatPerServing: _n(7.0, 100),
            carbsPerServing: _n(66.3, 100),
          ),
          Ingredient(
            productId: 'banana',
            name: 'Банан',
            amountPerServing: 120, // 1 medium banana
            unit: 'g',
            caloriesPerServing: _n(89, 120),
            proteinPerServing: _n(1.1, 120),
            fatPerServing: _n(0.3, 120),
            carbsPerServing: _n(22.8, 120),
          ),
          Ingredient(
            productId: 'bread_white',
            name: 'Хліб',
            amountPerServing: 30, // 1 slice
            unit: 'g',
            caloriesPerServing: _n(265, 30),
            proteinPerServing: _n(9.0, 30),
            fatPerServing: _n(3.2, 30),
            carbsPerServing: _n(49.4, 30),
          ),
          Ingredient(
            productId: 'milk_whole',
            name: 'Молоко',
            amountPerServing: 200, // 1 glass
            unit: 'ml',
            caloriesPerServing: _n(61, 200),
            proteinPerServing: _n(3.2, 200),
            fatPerServing: _n(3.3, 200),
            carbsPerServing: _n(4.8, 200),
          ),
        ],
        instructions: [],
      );

  static Dish _syrnyky() => Dish(
        id: 'seed_syrnyky',
        name: 'Сирники',
        servings: 4,
        ingredients: [
          Ingredient(
            // Semi-finished cottage cheese pancakes: ~200 kcal/100g
            productId: 'manual_syrnyky',
            name: 'Сирники (напівфабрикат)',
            amountPerServing: 75, // 300g / 4
            unit: 'g',
            caloriesPerServing: _n(200, 75),
            proteinPerServing: _n(10.0, 75),
            fatPerServing: _n(8.0, 75),
            carbsPerServing: _n(22.0, 75),
          ),
        ],
        instructions: [
          'Смажити на олії з двох сторін до золотистої скоринки.',
        ],
      );

  static Dish _lazyVarenyky() => Dish(
        id: 'seed_lazy_varenyky',
        name: 'Ліниві вареники',
        servings: 4,
        ingredients: [
          Ingredient(
            productId: 'cottage_cheese',
            name: 'Сир кисломолочний',
            amountPerServing: 50, // 200g / 4
            unit: 'g',
            caloriesPerServing: _n(98, 50),
            proteinPerServing: _n(11.1, 50),
            fatPerServing: _n(4.3, 50),
            carbsPerServing: _n(3.4, 50),
          ),
          Ingredient(
            productId: 'flour_wheat',
            name: 'Борошно',
            amountPerServing: 25, // 100g / 4
            unit: 'g',
            caloriesPerServing: _n(364, 25),
            proteinPerServing: _n(10.3, 25),
            fatPerServing: _n(1.0, 25),
            carbsPerServing: _n(76.3, 25),
          ),
          Ingredient(
            productId: 'sugar_white',
            name: 'Цукор',
            amountPerServing: 6.25, // 25g / 4
            unit: 'g',
            caloriesPerServing: _n(387, 6.25),
            proteinPerServing: 0,
            fatPerServing: 0,
            carbsPerServing: _n(100.0, 6.25),
          ),
        ],
        instructions: [],
      );

  static Dish _mlyntsi() => Dish(
        id: 'seed_mlyntsi',
        name: 'Млинці',
        servings: 4,
        ingredients: [
          Ingredient(
            // Semi-finished pancakes: ~220 kcal/100g
            productId: 'manual_mlyntsi',
            name: 'Млинці (напівфабрикат)',
            amountPerServing: 100, // 400g / 4
            unit: 'g',
            caloriesPerServing: _n(220, 100),
            proteinPerServing: _n(5.0, 100),
            fatPerServing: _n(10.0, 100),
            carbsPerServing: _n(28.0, 100),
          ),
          Ingredient(
            productId: 'sour_cream',
            name: 'Сметана',
            amountPerServing: 25, // 100g / 4
            unit: 'g',
            caloriesPerServing: _n(198, 25),
            proteinPerServing: _n(2.4, 25),
            fatPerServing: _n(19.4, 25),
            carbsPerServing: _n(4.6, 25),
          ),
        ],
        instructions: [],
      );

  static Dish _waffles() => Dish(
        id: 'seed_waffles',
        name: 'Вафлі',
        servings: 4,
        ingredients: [
          Ingredient(
            productId: 'flour_wheat',
            name: 'Борошно',
            amountPerServing: 37.5, // 150g / 4
            unit: 'g',
            caloriesPerServing: _n(364, 37.5),
            proteinPerServing: _n(10.3, 37.5),
            fatPerServing: _n(1.0, 37.5),
            carbsPerServing: _n(76.3, 37.5),
          ),
          Ingredient(
            productId: 'sugar_white',
            name: 'Цукор',
            amountPerServing: 8.75, // 35g / 4
            unit: 'g',
            caloriesPerServing: _n(387, 8.75),
            proteinPerServing: 0,
            fatPerServing: 0,
            carbsPerServing: _n(100.0, 8.75),
          ),
          Ingredient(
            productId: 'butter',
            name: 'Масло',
            amountPerServing: 12.5, // 50g / 4
            unit: 'g',
            caloriesPerServing: _n(717, 12.5),
            proteinPerServing: _n(0.9, 12.5),
            fatPerServing: _n(81.0, 12.5),
            carbsPerServing: _n(0.1, 12.5),
          ),
          Ingredient(
            productId: 'egg_whole',
            name: 'Яйце',
            amountPerServing: 15, // 60g total (1 egg) / 4
            unit: 'g',
            caloriesPerServing: _n(155, 15),
            proteinPerServing: _n(13.0, 15),
            fatPerServing: _n(11.0, 15),
            carbsPerServing: _n(1.1, 15),
          ),
          Ingredient(
            productId: 'milk_whole',
            name: 'Молоко',
            amountPerServing: 62.5, // 250ml / 4
            unit: 'ml',
            caloriesPerServing: _n(61, 62.5),
            proteinPerServing: _n(3.2, 62.5),
            fatPerServing: _n(3.3, 62.5),
            carbsPerServing: _n(4.8, 62.5),
          ),
        ],
        instructions: [],
      );

  static Dish _hotSandwiches() => Dish(
        id: 'seed_hot_sandwiches',
        name: 'Гарячі сендвічі',
        servings: 3, // 6 slices = 3 sandwiches (2 slices each)
        ingredients: [
          Ingredient(
            productId: 'bread_white',
            name: 'Хліб білий',
            amountPerServing: 60, // 2 slices per sandwich
            unit: 'g',
            caloriesPerServing: _n(265, 60),
            proteinPerServing: _n(9.0, 60),
            fatPerServing: _n(3.2, 60),
            carbsPerServing: _n(49.4, 60),
          ),
          Ingredient(
            productId: 'egg_whole',
            name: 'Яйце',
            amountPerServing: 60, // 1 egg per sandwich
            unit: 'g',
            caloriesPerServing: _n(155, 60),
            proteinPerServing: _n(13.0, 60),
            fatPerServing: _n(11.0, 60),
            carbsPerServing: _n(1.1, 60),
          ),
          Ingredient(
            productId: 'cheese_cheddar',
            name: 'Сир',
            amountPerServing: 17, // ~50g total / 3
            unit: 'g',
            caloriesPerServing: _n(402, 17),
            proteinPerServing: _n(25.0, 17),
            fatPerServing: _n(33.0, 17),
            carbsPerServing: _n(1.3, 17),
          ),
          Ingredient(
            productId: 'manual_buzhenyna',
            name: 'Буженіна / ковбаса',
            amountPerServing: 33, // ~100g total / 3
            unit: 'g',
            caloriesPerServing: _n(250, 33),
            proteinPerServing: _n(16.0, 33),
            fatPerServing: _n(20.0, 33),
            carbsPerServing: _n(2.0, 33),
          ),
          Ingredient(
            productId: 'lettuce_iceberg',
            name: 'Листя салату',
            amountPerServing: 10, // 30g total / 3
            unit: 'g',
            caloriesPerServing: _n(14, 10),
            proteinPerServing: _n(0.9, 10),
            fatPerServing: _n(0.1, 10),
            carbsPerServing: _n(2.9, 10),
          ),
        ],
        instructions: [],
      );
}
