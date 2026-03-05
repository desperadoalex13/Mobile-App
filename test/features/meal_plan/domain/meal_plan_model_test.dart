import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/meal_plan/domain/meal_plan_model.dart';

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

void main() {
  group('MealSlot', () {
    test('defaults returns three slots', () {
      final defaults = MealSlot.defaults;
      expect(defaults.length, 3);
      expect(defaults.map((s) => s.name), ['Breakfast', 'Lunch', 'Dinner']);
      expect(defaults.every((s) => s.dishIds.isEmpty), isTrue);
    });

    test('fromMap / toMap round-trip', () {
      final slot = MealSlot(name: 'Brunch', dishIds: ['d1', 'd2']);
      final restored = MealSlot.fromMap(slot.toMap());
      expect(restored.name, 'Brunch');
      expect(restored.dishIds, ['d1', 'd2']);
    });
  });

  group('DayPlan', () {
    test('fromMap / toMap round-trip', () {
      final date = DateTime(2026, 3, 6);
      final day = DayPlan(
        date: date,
        mealSlots: [MealSlot(name: 'Breakfast', dishIds: ['d1'])],
      );
      final restored = DayPlan.fromMap(day.toMap());
      expect(restored.date, date);
      expect(restored.mealSlots.length, 1);
      expect(restored.mealSlots.first.name, 'Breakfast');
      expect(restored.mealSlots.first.dishIds, ['d1']);
    });
  });

  group('MealPlan', () {
    test('toFirestore / fromFirestore round-trip', () {
      final weekStart = DateTime(2026, 3, 2);
      final plan = MealPlan(
        id: 'plan1',
        weekStartDate: weekStart,
        days: [
          DayPlan(
            date: DateTime(2026, 3, 2),
            mealSlots: MealSlot.defaults,
          ),
        ],
      );

      final map = plan.toFirestore();
      final doc = _FakeDoc('plan1', map);
      final restored = MealPlan.fromFirestore(doc);

      expect(restored.id, 'plan1');
      expect(restored.weekStartDate, weekStart);
      expect(restored.days.length, 1);
      expect(restored.days.first.mealSlots.length, 3);
    });
  });
}
