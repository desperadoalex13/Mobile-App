import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_log_service.dart';
import '../../../shared/utils/date_utils.dart';
import '../data/meal_plan_repository.dart';
import '../domain/meal_plan_model.dart';

/// The Monday of the currently selected week.
final selectedWeekProvider = StateProvider<DateTime>(
  (ref) => DateTime.now().startOfWeek,
);

/// Live stream of the meal plan for the selected week (null if not created yet).
final mealPlanProvider = StreamProvider<MealPlan?>((ref) {
  final week = ref.watch(selectedWeekProvider);
  return ref.watch(mealPlanRepositoryProvider).watchWeek(week);
});

final mealPlanMutationProvider =
    AsyncNotifierProvider<MealPlanMutationNotifier, void>(
  MealPlanMutationNotifier.new,
);

class MealPlanMutationNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> addDish(DateTime date, String slotName, String dishId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final week = ref.read(selectedWeekProvider);
      final existing = ref.read(mealPlanProvider).valueOrNull;
      final updated = _buildUpdatedPlan(
        existing: existing,
        week: week,
        date: date,
        slotName: slotName,
        dishId: dishId,
        remove: false,
      );
      await ref.read(mealPlanRepositoryProvider).savePlan(updated);
    });
    if (state is AsyncError<void>) {
      AppLogService.instance.error(
        'addDish failed: slot=$slotName dish=$dishId',
        error: (state as AsyncError<void>).error,
        stackTrace: (state as AsyncError<void>).stackTrace,
      );
    } else {
      AppLogService.instance.info('Dish added to plan: $dishId @ $slotName');
    }
  }

  Future<void> removeDish(DateTime date, String slotName, String dishId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final week = ref.read(selectedWeekProvider);
      final existing = ref.read(mealPlanProvider).valueOrNull;
      final updated = _buildUpdatedPlan(
        existing: existing,
        week: week,
        date: date,
        slotName: slotName,
        dishId: dishId,
        remove: true,
      );
      await ref.read(mealPlanRepositoryProvider).savePlan(updated);
    });
    if (state is AsyncError<void>) {
      AppLogService.instance.error(
        'removeDish failed: slot=$slotName dish=$dishId',
        error: (state as AsyncError<void>).error,
      );
    } else {
      AppLogService.instance.info('Dish removed from plan: $dishId @ $slotName');
    }
  }

  /// Builds the updated [MealPlan] by reconstructing the object graph immutably.
  /// Creates a blank 7-day plan if [existing] is null (lazy creation).
  MealPlan _buildUpdatedPlan({
    required MealPlan? existing,
    required DateTime week,
    required DateTime date,
    required String slotName,
    required String dishId,
    required bool remove,
  }) {
    final weekId = week.toIso8601String().substring(0, 10);

    final days = existing?.days ??
        List.generate(
          7,
          (i) => DayPlan(
            date: week.add(Duration(days: i)),
            mealSlots: MealSlot.defaults,
          ),
        );

    final updatedDays = days.map((day) {
      if (!day.date.isSameDay(date)) return day;

      final updatedSlots = day.mealSlots.map((slot) {
        if (slot.name != slotName) return slot;

        final ids = List<String>.from(slot.dishIds);
        if (remove) {
          ids.remove(dishId);
        } else {
          if (!ids.contains(dishId)) ids.add(dishId);
        }
        return MealSlot(name: slot.name, dishIds: ids);
      }).toList();

      return DayPlan(date: day.date, mealSlots: updatedSlots);
    }).toList();

    return MealPlan(
      id: weekId,
      weekStartDate: week,
      days: updatedDays,
    );
  }
}
