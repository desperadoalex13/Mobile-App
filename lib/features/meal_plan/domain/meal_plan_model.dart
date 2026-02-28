import 'package:cloud_firestore/cloud_firestore.dart';

class MealPlan {
  MealPlan({
    required this.id,
    required this.weekStartDate,
    required this.days,
  });

  final String id;
  final DateTime weekStartDate;
  final List<DayPlan> days;

  factory MealPlan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MealPlan(
      id: doc.id,
      weekStartDate: (data['weekStartDate'] as Timestamp).toDate(),
      days: (data['days'] as List<dynamic>)
          .map((d) => DayPlan.fromMap(d as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'weekStartDate': Timestamp.fromDate(weekStartDate),
        'days': days.map((d) => d.toMap()).toList(),
      };
}

class DayPlan {
  DayPlan({required this.date, required this.mealSlots});

  final DateTime date;
  final List<MealSlot> mealSlots;

  factory DayPlan.fromMap(Map<String, dynamic> map) => DayPlan(
        date: (map['date'] as Timestamp).toDate(),
        mealSlots: (map['mealSlots'] as List<dynamic>)
            .map((s) => MealSlot.fromMap(s as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'date': Timestamp.fromDate(date),
        'mealSlots': mealSlots.map((s) => s.toMap()).toList(),
      };
}

class MealSlot {
  MealSlot({
    required this.name,
    required this.dishIds,
  });

  final String name;
  final List<String> dishIds;

  static List<MealSlot> get defaults => [
        MealSlot(name: 'Breakfast', dishIds: []),
        MealSlot(name: 'Lunch', dishIds: []),
        MealSlot(name: 'Dinner', dishIds: []),
      ];

  factory MealSlot.fromMap(Map<String, dynamic> map) => MealSlot(
        name: map['name'] as String,
        dishIds: List<String>.from(map['dishIds'] as List),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'dishIds': dishIds,
      };
}
