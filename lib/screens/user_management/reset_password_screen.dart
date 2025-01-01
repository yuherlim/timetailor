import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/custom_snackbars.dart';
import 'package:timetailor/core/shared/widgets/styled_button.dart';
import 'package:timetailor/core/shared/widgets/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/user_management/providers/user_provider.dart';

class ResetPasswordScreen extends HookWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final resetPasswordScrollController = useScrollController();
    final emailController = useTextEditingController();

    final errorFeedback = useState<String?>(null);
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: Colors.grey[900], // Monochrome dark background
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const AppBarText(
            'Reset Password'), // StyledHeaderText for consistent styling
      ),
      body: SingleChildScrollView(
        controller: resetPasswordScrollController,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App logo
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/logo/timetailor_logo.png', // Path to your image file in the assets folder
                      width: 200, // Set the desired width
                      height: 200, // Set the desired height
                      fit: BoxFit
                          .cover, // Control how the image fits within the space
                    ),
                  ),
                ),

                const SizedBox(height: 16.0),

                // Intro text
                const Center(
                  child: UserOnboardingMessageText(
                      'Enter your email to reset your password.'),
                ),

                const SizedBox(height: 16.0),

                // Email address input
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                      color: AppColors
                          .textColor), // Text color for dark background
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Error feedback
                if (errorFeedback.value != null)
                  Text(
                    errorFeedback.value!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                const SizedBox(height: 16.0),

                // Submit button
                Consumer(
                  builder: (childContext, ref, child) {
                    final isLoadingNotifier =
                        ref.read(isLoadingProvider.notifier);
                    final isLoading = ref.watch(isLoadingProvider);
                    final authService = ref.watch(firebaseAuthServiceProvider);

                    return StyledButton(
                      onPressed: () async {
                        // Check internet connectivity
                        final connectivityResult =
                            await Connectivity().checkConnectivity();

                        if (connectivityResult
                            .contains(ConnectivityResult.none)) {
                          // Show a snackbar for no internet connection
                          CustomSnackbars.shortDurationSnackBar(
                            contentString:
                                "No internet connection. Please try again after reconnecting to the internet.",
                          );
                          return;
                        }

                        if (formKey.currentState!.validate()) {
                          errorFeedback.value = null;

                          final email = emailController.text.trim();

                          isLoadingNotifier.state = true;

                          try {
                            // Call the sendPasswordResetEmail method
                            final result =
                                await authService.sendPasswordResetEmail(email);

                            if (result != null) {
                              errorFeedback.value = result;
                              CustomSnackbars.shortDurationSnackBar(
                                contentString:
                                    "Send reset password email failed: $result",
                              );
                            } else {
                              if (context.mounted) {
                                context.go(RoutePath.loginPath);
                              }
                              // Show success message and navigate to login screen
                              CustomSnackbars.shortDurationSnackBar(
                                contentString:
                                    "Reset password email sent successfully. Please check your email.",
                              );
                            }
                          } catch (e) {
                            debugPrint("An error occurred: $e");
                            CustomSnackbars.shortDurationSnackBar(
                              contentString: "An error occurred: $e",
                            );
                          } finally {
                            isLoadingNotifier.state = false;
                          }
                        }
                      },
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const ButtonText('Send Reset Email'),
                    );
                  },
                ),

                const SizedBox(height: 16.0),

                // Back to login prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const UserOnboardingMessageText(
                        "Remembered your password?"),
                    Consumer(
                      builder: (childContext, ref, child) {
                        final isLoading = ref.watch(isLoadingProvider);
                        return StyledButton(
                          onPressed: isLoading
                              ? null
                              : () => context.go(RoutePath.loginPath),
                          child: const ButtonText("Login"),
                        );
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
