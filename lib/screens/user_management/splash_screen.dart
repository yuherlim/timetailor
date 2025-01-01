import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/domain/user_management/providers/user_provider.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';
import 'package:timetailor/domain/note_management/providers/notes_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Future<void> fetchDbData(User firebaseUser) async {
    final userRepository = ref.read(appUserRepositoryProvider);
    final currentSignedInUserNotifier = ref.read(currentUserProvider.notifier);
    final tasksNotifier = ref.read(tasksNotifierProvider.notifier);
    final notesNotifier = ref.read(notesNotifierProvider.notifier);

    try {
      // Fetch user data
      final appUser = await userRepository.getUserById(firebaseUser.uid);
      currentSignedInUserNotifier.state = appUser; // Cache the user

      // Fetch tasks and notes
      await Future.wait([
        tasksNotifier.fetchTasksFromFirestore(),
        notesNotifier.fetchNotesFromFirestore(),
      ]);

      debugPrint("[SplashScreen] Database data fetched successfully.");
    } catch (e) {
      debugPrint("[SplashScreen] Error fetching database data: $e");
      // Handle errors if needed
      rethrow; // Optional: rethrow the error to handle it further up
    }
  }

  Future<void> _handleNavigation(
      User? firebaseUser, BuildContext context) async {
    if (firebaseUser == null) {
      // Not logged in => navigate to Getting Started
      context.go(RoutePath.gettingStartedPath);
    } else {
      try {
        // Fetch database data
        await fetchDbData(firebaseUser);

        // Navigate to Task Management
        if (context.mounted) {
          context.go(RoutePath.taskManagementPath);
        }
      } catch (e) {
        debugPrint('[SplashScreen] Navigation aborted due to an error: $e');
        // Optionally handle errors, e.g., show an error screen
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsyncValue = ref.watch(authStateProvider);

    userAsyncValue.when(
      data: (firebaseUser) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _handleNavigation(firebaseUser, context);
        });
      },
      loading: () {
        // Optionally show a loading spinner
      },
      error: (error, stackTrace) {
        debugPrint('[SplashScreen] Error during auth state fetch: $error');
        // Optionally show an error screen
      },
    );

    // Splash screen UI
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Loading user data..."),
            SizedBox(height: 16),
            CircularProgressIndicator(), // Show loading spinner while waiting
          ],
        ),
      ),
    );
  }
}
