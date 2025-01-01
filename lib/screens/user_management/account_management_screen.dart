import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/custom_snackbars.dart';
import 'package:timetailor/core/shared/widgets/styled_button.dart';
import 'package:timetailor/core/shared/widgets/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/note_management/providers/note_form_provider.dart';
import 'package:timetailor/domain/note_management/providers/notes_provider.dart';
import 'package:timetailor/domain/task_management/providers/current_time_position_provider.dart';
import 'package:timetailor/domain/task_management/providers/date_provider.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';
import 'package:timetailor/domain/user_management/providers/user_provider.dart';

class AccountManagementScreen extends ConsumerStatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  ConsumerState<AccountManagementScreen> createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState
    extends ConsumerState<AccountManagementScreen> {
  Future<bool> checkConnectivityAndShowSnackbar() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) {
      // Show a snackbar for no internet connection
      CustomSnackbars.shortDurationSnackBar(
        contentString:
            "No internet connection. Please try again after reconnecting to the internet.",
      );
      return false;
    }
    return true;
  }

  void handleLogout() async {
    // Use the utility function to check connectivity
    final hasInternet = await checkConnectivityAndShowSnackbar();
    if (!hasInternet) return;

    final authService = ref.watch(firebaseAuthServiceProvider);
    final isLoadingNotifier = ref.read(isLoadingProvider.notifier);

    isLoadingNotifier.state = true;

    try {
      await authService.signOutUser();

      if (mounted) {
        context.go(RoutePath.gettingStartedPath);
      }
      CustomSnackbars.shortDurationSnackBar(
          contentString: "Log out successful.");
      // Invalidate providers after navigation
      Future.microtask(() => disposeKeepAliveProviders());
    } catch (e) {
      CustomSnackbars.shortDurationSnackBar(contentString: "Error: $e");
    } finally {
      isLoadingNotifier.state = false;
    }
  }

  Future<void> handleDeleteAccount() async {
    // Use the utility function to check connectivity
    final hasInternet = await checkConnectivityAndShowSnackbar();
    if (!hasInternet) return;

    final authService = ref.watch(firebaseAuthServiceProvider);
    final currentUser = await authService.getCurrentUser();

    if (currentUser == null) {
      CustomSnackbars.shortDurationSnackBar(
          contentString: "Unable to fetch user information.");
      return;
    }

    String? inputUsername;
    final isLoadingNotifier = ref.read(isLoadingProvider.notifier);

    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Account Deletion"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "To confirm deletion, type your username: ${currentUser.name}",
              ),
              const SizedBox(height: 16),
              const Text(
                "WARNING: This action cannot be UNDONE.",
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) => inputUsername = value,
                decoration: InputDecoration(
                  hintText: currentUser.name,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    if (inputUsername != currentUser.name) {
      CustomSnackbars.shortDurationSnackBar(
          contentString:
              "Username does not match. Account deletion cancelled.");
      return;
    }

    // Proceed with account deletion
    isLoadingNotifier.state = true;
    try {
      await authService.deleteAccount();
      if (mounted) {
        // ignore: use_build_context_synchronously
        context.go(RoutePath.gettingStartedPath);
      }
      CustomSnackbars.shortDurationSnackBar(
          contentString: "Account deleted successfully.");
      disposeKeepAliveProviders();
    } catch (e) {
      CustomSnackbars.shortDurationSnackBar(
          contentString: "Error deleting account: $e");
      debugPrint("Error deleting account: $e");
    } finally {
      isLoadingNotifier.state = false;
    }
  }

  void disposeKeepAliveProviders() {
    ref.invalidate(noteFormNotifierProvider);
    ref.invalidate(notesNotifierProvider);
    ref.invalidate(tasksNotifierProvider);
    ref.invalidate(currentUserFetcherProvider);
    ref.invalidate(currentUserProvider);
    ref.invalidate(currentTimePositionNotifierProvider);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.read(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        title: const AppBarText("Account Management"),
        titleSpacing: 72,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Consumer(
              builder: (context, ref, child) {
                final isLoading = ref.watch(isLoadingProvider);

                return Column(
                  children: [
                    StyledHeading("Hello, ${currentUser?.name}"),
                    const SizedBox(height: 8),
                    const StyledHeading("What do you want to do?"),
                    const SizedBox(height: 16),
                    StyledButton(
                      onPressed: () => isLoading ? null : handleLogout(),
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const ButtonText("Log out"),
                    ),
                    const SizedBox(height: 16),
                    StyledButton(
                      onPressed: () => isLoading ? null : handleDeleteAccount(),
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const ButtonText("Delete Account"),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
