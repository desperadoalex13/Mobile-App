import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_log_service.dart';
import '../data/dish_repository.dart';
import '../domain/dish_model.dart';

/// Live stream of all dishes for the signed-in user.
final dishesProvider = StreamProvider<List<Dish>>((ref) {
  return ref.watch(dishRepositoryProvider).watchDishes();
});

/// Handles create / update / delete mutations.
final dishMutationProvider =
    AsyncNotifierProvider<DishMutationController, void>(
  DishMutationController.new,
);

class DishMutationController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> saveDish(Dish dish) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(dishRepositoryProvider).saveDish(dish),
    );
    if (state is AsyncError<void>) {
      AppLogService.instance.error(
        'saveDish failed: ${dish.id}',
        error: (state as AsyncError<void>).error,
        stackTrace: (state as AsyncError<void>).stackTrace,
      );
    } else {
      AppLogService.instance.info('Dish saved: ${dish.id}');
    }
  }

  Future<void> deleteDish(String dishId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(dishRepositoryProvider).deleteDish(dishId),
    );
    if (state is AsyncError<void>) {
      AppLogService.instance.error(
        'deleteDish failed: $dishId',
        error: (state as AsyncError<void>).error,
      );
    } else {
      AppLogService.instance.info('Dish deleted: $dishId');
    }
  }
}
