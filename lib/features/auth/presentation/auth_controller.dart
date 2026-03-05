import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_log_service.dart';
import '../data/auth_repository.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signInWithEmail(email, password);
      final uid = ref.read(authRepositoryProvider).currentUser?.uid;
      AppLogService.instance
        ..setUserId(uid)
        ..info('User signed in');
    });
    if (state is AsyncError<void>) {
      AppLogService.instance.error(
        'signIn failed',
        error: (state as AsyncError<void>).error,
        stackTrace: (state as AsyncError<void>).stackTrace,
      );
    }
  }

  Future<void> register(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .registerWithEmail(email, password);
      final uid = ref.read(authRepositoryProvider).currentUser?.uid;
      AppLogService.instance
        ..setUserId(uid)
        ..info('User registered');
    });
    if (state is AsyncError<void>) {
      AppLogService.instance.error(
        'register failed',
        error: (state as AsyncError<void>).error,
        stackTrace: (state as AsyncError<void>).stackTrace,
      );
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    AppLogService.instance.info('User signing out');
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signOut();
      AppLogService.instance.setUserId(null);
    });
    if (state is AsyncError<void>) {
      AppLogService.instance.error(
        'signOut failed',
        error: (state as AsyncError<void>).error,
      );
    }
  }
}
