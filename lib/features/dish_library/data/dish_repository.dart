import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../domain/dish_model.dart';

final dishRepositoryProvider = Provider<DishRepository>((ref) {
  return DishRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  );
});

class DishRepository {
  DishRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  String get _uid {
    assert(_auth.currentUser != null, 'DishRepository used while signed out');
    return _auth.currentUser!.uid;
  }

  CollectionReference<Map<String, dynamic>> get _dishes =>
      _firestore.collection('users').doc(_uid).collection('dishes');

  /// Live stream of all dishes for the current user, ordered by name.
  Stream<List<Dish>> watchDishes() => _dishes
      .orderBy('name')
      .snapshots()
      .map((snap) => snap.docs.map(Dish.fromFirestore).toList());

  /// Creates or updates a dish document (upsert via set).
  Future<void> saveDish(Dish dish) => _dishes.doc(dish.id).set(dish.toFirestore());

  Future<void> deleteDish(String dishId) => _dishes.doc(dishId).delete();

  /// Returns a client-side generated Firestore document ID for a new dish.
  String generateId() => _dishes.doc().id;
}
