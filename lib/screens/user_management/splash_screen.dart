import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/domain/user_management/providers/user_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  // A guard variable to ensure we only navigate once

  Future<void> _handleNavigation(
      User? firebaseUser, BuildContext context) async {
    final userRepository = ref.read(appUserRepositoryProvider);
    final currentSignedInUserNotifier = ref.read(currentUserProvider.notifier);

    if (firebaseUser == null) {
      // Not logged in => navigate to Getting Started
      context.go(RoutePath.gettingStartedPath);
    } else {
      // Logged in => fetch user data and navigate to Task Management
      try {
        final appUser = await userRepository.getUserById(firebaseUser.uid);
        currentSignedInUserNotifier.state = appUser; // Cache the user
        if (context.mounted) {
          context.go(RoutePath.taskManagementPath);
        }
      } catch (e) {
        debugPrint('Error fetching user data: $e');
        // Optionally, show an error page or retry mechanism here
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
        debugPrint('Error during auth state fetch: $error');
        // Optionally show an error screen
      },
    );

    // Splash screen UI
    return const Scaffold(
      body: Center(
        child:
            CircularProgressIndicator(), // Show loading spinner while waiting
      ),
    );
  }
}
