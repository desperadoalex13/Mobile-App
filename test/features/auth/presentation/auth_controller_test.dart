import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/auth/data/auth_repository.dart';
import 'package:mobile_app/features/auth/presentation/auth_controller.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockAuthRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('AuthController.signIn', () {
    test('transitions to AsyncData on success', () async {
      when(() => mockRepo.signInWithEmail(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockRepo.currentUser).thenReturn(null);

      await container.read(authControllerProvider.notifier).signIn(
            'a@b.com',
            'pass123',
          );

      expect(container.read(authControllerProvider), isA<AsyncData<void>>());
    });

    test('transitions to AsyncError on failure', () async {
      when(() => mockRepo.signInWithEmail(any(), any()))
          .thenThrow(Exception('auth error'));

      await container.read(authControllerProvider.notifier).signIn(
            'a@b.com',
            'wrong',
          );

      expect(container.read(authControllerProvider), isA<AsyncError<void>>());
    });
  });

  group('AuthController.register', () {
    test('transitions to AsyncData on success', () async {
      when(() => mockRepo.registerWithEmail(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockRepo.currentUser).thenReturn(null);

      await container.read(authControllerProvider.notifier).register(
            'new@user.com',
            'secure123',
          );

      expect(container.read(authControllerProvider), isA<AsyncData<void>>());
    });

    test('transitions to AsyncError on failure', () async {
      when(() => mockRepo.registerWithEmail(any(), any()))
          .thenThrow(Exception('email taken'));

      await container.read(authControllerProvider.notifier).register(
            'taken@user.com',
            'pass',
          );

      expect(container.read(authControllerProvider), isA<AsyncError<void>>());
    });
  });

  group('AuthController.signOut', () {
    test('transitions to AsyncData on success', () async {
      when(() => mockRepo.signOut()).thenAnswer((_) async {});

      await container.read(authControllerProvider.notifier).signOut();

      expect(container.read(authControllerProvider), isA<AsyncData<void>>());
    });

    test('transitions to AsyncError on failure', () async {
      when(() => mockRepo.signOut()).thenThrow(Exception('signout failed'));

      await container.read(authControllerProvider.notifier).signOut();

      expect(container.read(authControllerProvider), isA<AsyncError<void>>());
    });
  });
}
