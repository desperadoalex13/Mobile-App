import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/auth/domain/user_profile.dart';

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
  group('UserProfile', () {
    test('defaultMealSlots are Breakfast, Lunch, Dinner', () {
      expect(
        UserProfile.defaultMealSlots,
        ['Breakfast', 'Lunch', 'Dinner'],
      );
    });

    test('toFirestore round-trips correctly', () {
      final now = DateTime(2026, 3, 6, 12, 0, 0);
      final profile = UserProfile(
        uid: 'uid1',
        email: 'a@b.com',
        createdAt: now,
        mealSlots: ['Breakfast', 'Dinner'],
        extra: {'key': 'value'},
      );

      final map = profile.toFirestore();

      expect(map['email'], 'a@b.com');
      expect((map['createdAt'] as Timestamp).toDate(), now);
      expect(map['mealSlots'], ['Breakfast', 'Dinner']);
      expect(map['extra'], {'key': 'value'});
    });

    test('fromFirestore deserialises all fields', () {
      final now = DateTime(2026, 3, 6);
      final doc = _FakeDoc('uid42', {
        'email': 'test@example.com',
        'createdAt': Timestamp.fromDate(now),
        'mealSlots': ['Breakfast', 'Lunch'],
        'extra': {'plan': 'free'},
      });

      final profile = UserProfile.fromFirestore(doc);

      expect(profile.uid, 'uid42');
      expect(profile.email, 'test@example.com');
      expect(profile.createdAt, now);
      expect(profile.mealSlots, ['Breakfast', 'Lunch']);
      expect(profile.extra, {'plan': 'free'});
    });

    test('fromFirestore uses defaultMealSlots when field absent', () {
      final doc = _FakeDoc('uid1', {
        'email': 'x@y.com',
        'createdAt': Timestamp.fromDate(DateTime(2026)),
        // no mealSlots field
        'extra': {},
      });

      final profile = UserProfile.fromFirestore(doc);
      expect(profile.mealSlots, UserProfile.defaultMealSlots);
    });

    test('extra defaults to empty map when absent', () {
      final doc = _FakeDoc('uid1', {
        'email': 'x@y.com',
        'createdAt': Timestamp.fromDate(DateTime(2026)),
        'mealSlots': UserProfile.defaultMealSlots,
        // no extra field
      });

      final profile = UserProfile.fromFirestore(doc);
      expect(profile.extra, isEmpty);
    });
  });
}
