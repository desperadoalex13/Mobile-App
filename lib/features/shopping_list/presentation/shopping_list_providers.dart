import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_log_service.dart';
import '../../dish_library/presentation/dish_providers.dart';
import '../../meal_plan/presentation/meal_plan_providers.dart';
import '../data/shopping_list_repository.dart';
import '../domain/shopping_list_model.dart';

String _weekId(DateTime week) => week.toIso8601String().substring(0, 10);

/// Live stream of purchased item keys for the selected week.
final purchasedKeysProvider = StreamProvider<Set<String>>((ref) {
  final weekId = _weekId(ref.watch(selectedWeekProvider));
  return ref.watch(shoppingListRepositoryProvider).watchPurchasedKeys(weekId);
});

/// Shopping list generated from the selected week's meal plan, with
/// checked-off state merged in from [purchasedKeysProvider].
final shoppingListProvider = Provider<AsyncValue<ShoppingList>>((ref) {
  final mealPlanAsync = ref.watch(mealPlanProvider);
  final dishesAsync = ref.watch(dishesProvider);
  final productsAsync = ref.watch(productsProvider);
  final purchasedAsync = ref.watch(purchasedKeysProvider);

  if (mealPlanAsync.hasError) {
    return AsyncError(
        mealPlanAsync.error!, mealPlanAsync.stackTrace ?? StackTrace.current);
  }
  if (dishesAsync.hasError) {
    return AsyncError(
        dishesAsync.error!, dishesAsync.stackTrace ?? StackTrace.current);
  }
  if (productsAsync.hasError) {
    return AsyncError(
        productsAsync.error!, productsAsync.stackTrace ?? StackTrace.current);
  }
  if (purchasedAsync.hasError) {
    return AsyncError(purchasedAsync.error!,
        purchasedAsync.stackTrace ?? StackTrace.current);
  }
  if (mealPlanAsync.isLoading ||
      dishesAsync.isLoading ||
      productsAsync.isLoading ||
      purchasedAsync.isLoading) {
    return const AsyncLoading();
  }

  return AsyncData(ShoppingList.fromMealPlan(
    mealPlan: mealPlanAsync.valueOrNull,
    dishes: dishesAsync.valueOrNull ?? const [],
    products: productsAsync.valueOrNull ?? const [],
    purchasedKeys: purchasedAsync.valueOrNull ?? const {},
    otherCategory: 'Other',
  ));
});

final shoppingListMutationProvider =
    AsyncNotifierProvider<ShoppingListMutationController, void>(
  ShoppingListMutationController.new,
);

class ShoppingListMutationController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> togglePurchased(ShoppingItem item) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final weekId = _weekId(ref.read(selectedWeekProvider));
      await ref
          .read(shoppingListRepositoryProvider)
          .setPurchased(weekId, item.key, !item.isPurchased);
    });
    if (state is AsyncError<void>) {
      AppLogService.instance.error(
        'togglePurchased failed: ${item.key}',
        error: (state as AsyncError<void>).error,
      );
    }
  }
}
