import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../../core/logging/app_log_service.dart';
import '../data/auth_repository.dart';
import '../domain/user_profile.dart';

/// Live stream of the signed-in user's profile document.
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(null);
  return ref.watch(authRepositoryProvider).watchProfile(uid);
});

/// Derived list of meal slot names; falls back to defaults until profile loads.
final userSlotsProvider = Provider<List<String>>((ref) {
  return ref.watch(userProfileProvider).valueOrNull?.mealSlots ??
      UserProfile.defaultMealSlots;
});

/// Persists changes to the user's meal slot list.
final profileMutationProvider =
    AsyncNotifierProvider<ProfileMutationNotifier, void>(
  ProfileMutationNotifier.new,
);

class ProfileMutationNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> updateSlots(List<String> slots) async {
    state = const AsyncLoading();
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .updateProfile(uid, {'mealSlots': slots}),
    );
    if (state is AsyncError<void>) {
      AppLogService.instance.error(
        'updateSlots failed',
        error: (state as AsyncError<void>).error,
        stackTrace: (state as AsyncError<void>).stackTrace,
      );
    } else {
      AppLogService.instance.info('Meal slots updated: $slots');
    }
  }
}
