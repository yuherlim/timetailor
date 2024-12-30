import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/custom_snackbars.dart';
import 'package:timetailor/core/shared/widgets/styled_button.dart';
import 'package:timetailor/core/shared/widgets/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/note_management/providers/note_form_provider.dart';
import 'package:timetailor/domain/user_management/providers/user_provider.dart';

class AccountManagementScreen extends ConsumerStatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  ConsumerState<AccountManagementScreen> createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState
    extends ConsumerState<AccountManagementScreen> {
  void handleLogout() async {
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
      disposeKeepAliveProviders();
    } catch (e) {
      CustomSnackbars.shortDurationSnackBar(contentString: "Error: $e");
    } finally {
      isLoadingNotifier.state = false;
    }
  }

  void disposeKeepAliveProviders() {
    ref.invalidate(noteFormNotifierProvider);
  }

  @override
  Widget build(BuildContext context) {
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

                return StyledButton(
                  onPressed: () => isLoading ? null : handleLogout(),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const ButtonText("Log out"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
