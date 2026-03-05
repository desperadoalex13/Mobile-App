import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  UserProfile({
    required this.uid,
    required this.email,
    required this.createdAt,
    required this.mealSlots,
    this.extra = const {},
  });

  final String uid;
  final String email;
  final DateTime createdAt;

  /// Configurable meal slots — default: Breakfast, Lunch, Dinner.
  /// Users can rename or add custom slots in the future.
  final List<String> mealSlots;

  /// Extensible map for future fields without breaking existing documents.
  final Map<String, dynamic> extra;

  static const defaultMealSlots = ['Breakfast', 'Lunch', 'Dinner'];

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      email: data['email'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      mealSlots: List<String>.from(data['mealSlots'] ?? defaultMealSlots),
      extra: Map<String, dynamic>.from(data['extra'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'email': email,
        'createdAt': Timestamp.fromDate(createdAt),
        'mealSlots': mealSlots,
        'extra': extra,
      };
}
