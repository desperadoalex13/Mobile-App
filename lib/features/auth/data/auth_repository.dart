import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../domain/user_profile.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  );
});

class AuthRepository {
  AuthRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// Signs in an existing user. Throws [FirebaseAuthException] on failure.
  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Creates a Firebase Auth user and writes a Firestore profile document.
  /// Both steps are attempted; if Firestore write fails the account still
  /// exists in Auth so the user can sign in and the profile can be recreated.
  Future<void> registerWithEmail(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    final profile = UserProfile(
      uid: uid,
      email: email,
      createdAt: DateTime.now(),
      mealSlots: UserProfile.defaultMealSlots,
    );

    await _usersCollection.doc(uid).set(profile.toFirestore());
  }

  Future<void> signOut() => _auth.signOut();

  User? get currentUser => _auth.currentUser;

  /// Returns the Firestore profile for the currently signed-in user.
  /// Returns null if the document does not exist yet.
  Future<UserProfile?> getProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  /// Updates specific fields on the user profile document.
  Future<void> updateProfile(String uid, Map<String, dynamic> fields) =>
      _usersCollection.doc(uid).update(fields);

  /// Live stream of the user profile document.
  Stream<UserProfile?> watchProfile(String uid) =>
      _usersCollection.doc(uid).snapshots().map(
            (doc) => doc.exists ? UserProfile.fromFirestore(doc) : null,
          );

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');
}
