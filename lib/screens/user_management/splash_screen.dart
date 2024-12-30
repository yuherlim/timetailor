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
  bool _didNavigate = false;

  @override
  Widget build(BuildContext context) {
    final userAsyncValue = ref.watch(authStateProvider);

    userAsyncValue.when(
      data: (user) {
        // If we've not yet navigated, do it now in a post-frame callback
        if (!_didNavigate) {
          print("splash screen is run");
          _didNavigate = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            if (user == null) {
              // Not logged in => go to Getting Started
              context.go(RoutePath.gettingStartedPath);
            } else {
              // Logged in => go to Task Management
              context.go(RoutePath.taskManagementPath);
            }
          });
        }
      },
      loading: () {
        // Show a progress indicator while Firebase initializes
      },
      error: (error, stackTrace) {
        // Optionally navigate to an error page or show a message
        debugPrint('Splash authState error: $error');
      },
    );

    // The splash UI
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
