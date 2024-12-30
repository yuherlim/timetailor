import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timetailor/data/user_management/models/app_user.dart';
import 'package:timetailor/data/user_management/repositories/app_user_repository.dart';
import 'package:timetailor/data/user_management/repositories/firebase_auth_service.dart';

part 'user_provider.g.dart';

final appUserRepositoryProvider = Provider<AppUserRepository>((ref) {
  return AppUserRepository();
});

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  final appUserRepository = ref.read(appUserRepositoryProvider);
  return FirebaseAuthService(appUserRepository: appUserRepository);
});

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final isLoadingProvider = StateProvider<bool>((ref) => false);

final currentUserProvider = StateProvider<AppUser?>((ref) => null);

@Riverpod(keepAlive: true)
class CurrentUserFetcher extends _$CurrentUserFetcher {
  FirebaseAuthService get _authService => ref.read(firebaseAuthServiceProvider);

  @override
  Future<AppUser?> build() async {
    return await _authService.getCurrentUser();
  }

  Future<void> refreshUser() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authService.getCurrentUser());
  }
}