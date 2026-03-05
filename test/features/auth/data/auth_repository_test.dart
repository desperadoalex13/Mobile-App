import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/auth/data/auth_repository.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

// ignore: subtype_of_sealed_class
class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class
class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

// ---------------------------------------------------------------------------

void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockUserCredential mockCredential;
  late MockUser mockUser;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocRef;
  late AuthRepository repo;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockCredential = MockUserCredential();
    mockUser = MockUser();
    mockCollection = MockCollectionReference();
    mockDocRef = MockDocumentReference();

    repo = AuthRepository(mockAuth, mockFirestore);

    // Default Firestore chain
    when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
    when(() => mockCollection.doc(any())).thenReturn(mockDocRef);
  });

  group('signInWithEmail', () {
    test('calls signInWithEmailAndPassword with correct args', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
            email: 'a@b.com',
            password: 'pass123',
          )).thenAnswer((_) async => mockCredential);

      await repo.signInWithEmail('a@b.com', 'pass123');

      verify(() => mockAuth.signInWithEmailAndPassword(
            email: 'a@b.com',
            password: 'pass123',
          )).called(1);
    });

    test('propagates FirebaseAuthException on failure', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
        FirebaseAuthException(code: 'wrong-password'),
      );

      expect(
        () => repo.signInWithEmail('a@b.com', 'wrong'),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });

  group('registerWithEmail', () {
    test('creates auth user and writes Firestore document', () async {
      when(() => mockCredential.user).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('test-uid');
      when(() => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockCredential);
      when(() => mockDocRef.set(any())).thenAnswer((_) async {});

      await repo.registerWithEmail('new@user.com', 'securepass');

      verify(() => mockAuth.createUserWithEmailAndPassword(
            email: 'new@user.com',
            password: 'securepass',
          )).called(1);
      verify(() => mockDocRef.set(any())).called(1);
    });
  });

  group('signOut', () {
    test('calls auth.signOut()', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      await repo.signOut();

      verify(() => mockAuth.signOut()).called(1);
    });
  });

  group('currentUser', () {
    test('delegates to FirebaseAuth.currentUser', () {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      expect(repo.currentUser, mockUser);
    });

    test('returns null when not signed in', () {
      when(() => mockAuth.currentUser).thenReturn(null);
      expect(repo.currentUser, isNull);
    });
  });

  group('getProfile', () {
    test('returns null when no current user', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await repo.getProfile();

      expect(result, isNull);
      verifyNever(() => mockFirestore.collection(any()));
    });

    test('returns null when document does not exist', () async {
      final mockSnap = MockDocumentSnapshot();
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('uid1');
      when(() => mockDocRef.get()).thenAnswer((_) async => mockSnap);
      when(() => mockSnap.exists).thenReturn(false);

      final result = await repo.getProfile();

      expect(result, isNull);
    });
  });
}
