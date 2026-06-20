import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';

final shoppingListRepositoryProvider =
    Provider<ShoppingListRepository>((ref) {
  return ShoppingListRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  );
});

class ShoppingListRepository {
  ShoppingListRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  String get _uid {
    assert(_auth.currentUser != null,
        'ShoppingListRepository used while signed out');
    return _auth.currentUser!.uid;
  }

  DocumentReference<Map<String, dynamic>> _doc(String weekId) => _firestore
      .collection('users')
      .doc(_uid)
      .collection('shoppingLists')
      .doc(weekId);

  /// Live stream of purchased item keys for the given week.
  Stream<Set<String>> watchPurchasedKeys(String weekId) =>
      _doc(weekId).snapshots().map((doc) => Set<String>.from(
          doc.data()?['purchasedKeys'] as List<dynamic>? ?? const []));

  Future<void> setPurchased(String weekId, String key, bool purchased) =>
      _doc(weekId).set({
        'purchasedKeys': purchased
            ? FieldValue.arrayUnion([key])
            : FieldValue.arrayRemove([key]),
      }, SetOptions(merge: true));
}
