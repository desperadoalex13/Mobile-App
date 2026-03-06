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

  /// Copies all 7 days from the previous week into [targetWeek], overwriting
  /// any existing dishes. Returns false if the source week has no dishes.
  Future<bool> copyWeek({required DateTime targetWeek}) async {
    state = const AsyncLoading();
    bool hadContent = false;
    state = await AsyncValue.guard(() async {
      final sourceWeek = targetWeek.subtract(const Duration(days: 7));
      final sourcePlan =
          await ref.read(mealPlanRepositoryProvider).fetchWeek(sourceWeek);

      if (sourcePlan == null || sourcePlan.days.every((d) =>
          d.mealSlots.every((s) => s.dishIds.isEmpty))) {
        return; // source is empty — caller handles snackbar
      }
      hadContent = true;

      final weekId = targetWeek.toIso8601String().substring(0, 10);
      final newDays = List.generate(7, (i) {
        final targetDate = targetWeek.add(Duration(days: i));
        final sourceDay = sourcePlan.days.firstWhere(
          (d) => d.date.weekday == targetDate.weekday,
          orElse: () => DayPlan(date: targetDate, mealSlots: MealSlot.defaults),
        );
        return DayPlan(
          date: targetDate,
          mealSlots: sourceDay.mealSlots
              .map((s) => MealSlot(
                    name: s.name,
                    dishIds: List<String>.from(s.dishIds),
                  ))
              .toList(),
        );
      });

      await ref.read(mealPlanRepositoryProvider).savePlan(
            MealPlan(id: weekId, weekStartDate: targetWeek, days: newDays),
          );
    });
    if (state is AsyncError<void>) {
      AppLogService.instance.error(
        'copyWeek failed: target=$targetWeek',
        error: (state as AsyncError<void>).error,
        stackTrace: (state as AsyncError<void>).stackTrace,
      );
    } else if (hadContent) {
      AppLogService.instance.info('Week copied to $targetWeek');
    }
    return hadContent;
  }

  /// Copies a single day from the previous week into [targetDate], overwriting
  /// that day's slots. Returns false if the source day has no dishes.
  Future<bool> copyDay({required DateTime targetDate}) async {
    state = const AsyncLoading();
    bool hadContent = false;
    state = await AsyncValue.guard(() async {
      final targetWeek = ref.read(selectedWeekProvider);
      final sourceWeek = targetWeek.subtract(const Duration(days: 7));
      final sourcePlan =
          await ref.read(mealPlanRepositoryProvider).fetchWeek(sourceWeek);

      final sourceDay = sourcePlan?.days.firstWhere(
        (d) => d.date.weekday == targetDate.weekday,
        orElse: () => DayPlan(date: targetDate, mealSlots: MealSlot.defaults),
      );

      if (sourceDay == null ||
          sourceDay.mealSlots.every((s) => s.dishIds.isEmpty)) {
        return; // source day is empty
      }
      hadContent = true;

      final weekId = targetWeek.toIso8601String().substring(0, 10);
      final existing = ref.read(mealPlanProvider).valueOrNull;
      final days = existing?.days ??
          List.generate(
            7,
            (i) => DayPlan(
              date: targetWeek.add(Duration(days: i)),
              mealSlots: MealSlot.defaults,
            ),
          );

      final updatedDays = days.map((day) {
        if (!day.date.isSameDay(targetDate)) return day;
        return DayPlan(
          date: day.date,
          mealSlots: sourceDay.mealSlots
              .map((s) => MealSlot(
                    name: s.name,
                    dishIds: List<String>.from(s.dishIds),
                  ))
              .toList(),
        );
      }).toList();

      await ref.read(mealPlanRepositoryProvider).savePlan(
            MealPlan(id: weekId, weekStartDate: targetWeek, days: updatedDays),
          );
    });
    if (state is AsyncError<void>) {
      AppLogService.instance.error(
        'copyDay failed: target=$targetDate',
        error: (state as AsyncError<void>).error,
        stackTrace: (state as AsyncError<void>).stackTrace,
      );
    } else if (hadContent) {
      AppLogService.instance.info('Day copied to $targetDate');
    }
    return hadContent;
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
