import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../domain/meal_plan_model.dart';

final mealPlanRepositoryProvider = Provider<MealPlanRepository>((ref) {
  return MealPlanRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  );
});

class MealPlanRepository {
  MealPlanRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  String get _uid {
    assert(_auth.currentUser != null, 'MealPlanRepository used while signed out');
    return _auth.currentUser!.uid;
  }

  CollectionReference<Map<String, dynamic>> get _plans =>
      _firestore.collection('users').doc(_uid).collection('mealPlans');

  String _weekId(DateTime monday) => monday.toIso8601String().substring(0, 10);

  Stream<MealPlan?> watchWeek(DateTime monday) =>
      _plans.doc(_weekId(monday)).snapshots().map(
            (doc) => doc.exists ? MealPlan.fromFirestore(doc) : null,
          );

  Future<void> savePlan(MealPlan plan) =>
      _plans.doc(plan.id).set(plan.toFirestore());

  /// One-time read of a week's plan (used for copy operations).
  Future<MealPlan?> fetchWeek(DateTime monday) async {
    final doc = await _plans.doc(_weekId(monday)).get();
    return doc.exists ? MealPlan.fromFirestore(doc) : null;
  }
}
