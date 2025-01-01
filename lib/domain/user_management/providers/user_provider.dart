import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timetailor/data/user_management/models/app_user.dart';
import 'package:timetailor/data/user_management/repositories/app_user_repository.dart';
import 'package:timetailor/data/user_management/repositories/firebase_auth_service.dart';
import 'package:timetailor/domain/note_management/providers/notes_provider.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';

part 'user_provider.g.dart';

final appUserRepositoryProvider = Provider<AppUserRepository>((ref) {
  return AppUserRepository();
});

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  final appUserRepository = ref.read(appUserRepositoryProvider);
  final taskRepository = ref.read(taskRepositoryProvider);
  final noteRepository = ref.read(noteRepositoryProvider);
  return FirebaseAuthService(
    appUserRepository: appUserRepository,
    noteRepository: noteRepository,
    taskRepository: taskRepository,
  );
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
