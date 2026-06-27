import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  UserProfile({
    required this.uid,
    required this.email,
    required this.createdAt,
    required this.mealSlots,
    List<String>? dishTags,
    this.extra = const {},
  }) : dishTags = dishTags ?? defaultDishTags;

  final String uid;
  final String email;
  final DateTime createdAt;

  /// Configurable meal slots — default: Breakfast, Lunch, Dinner.
  /// Users can rename or add custom slots in the future.
  final List<String> mealSlots;

  /// Configurable food-type tags (e.g. Dessert, Salad, Meat) — user-editable,
  /// same pattern as [mealSlots].
  final List<String> dishTags;

  /// Extensible map for future fields without breaking existing documents.
  final Map<String, dynamic> extra;

  static const defaultMealSlots = ['Breakfast', 'Lunch', 'Dinner'];
  static const defaultDishTags = [
    'Dessert',
    'Salad',
    'Side dish',
    'Pasta',
    'Meat',
    'Fish',
    'Fastfood',
  ];

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      email: data['email'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      mealSlots: List<String>.from(data['mealSlots'] ?? defaultMealSlots),
      dishTags: List<String>.from(data['dishTags'] ?? defaultDishTags),
      extra: Map<String, dynamic>.from(data['extra'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'email': email,
        'createdAt': Timestamp.fromDate(createdAt),
        'mealSlots': mealSlots,
        'dishTags': dishTags,
        'extra': extra,
      };
}
