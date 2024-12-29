import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/custom_snackbars.dart';
import 'package:timetailor/core/shared/widgets/styled_button.dart';
import 'package:timetailor/core/shared/widgets/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';

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
                StyledButton(
                  onPressed: () async {
                    // Check internet connectivity
                    final connectivityResult =
                        await Connectivity().checkConnectivity();

                    // Handle the emitted list of ConnectivityResult
                    if (connectivityResult.contains(ConnectivityResult.none)) {
                      // Show a snackbar for no internet connection
                      CustomSnackbars.shortDurationSnackBar(
                          contentString:
                              "No internet connection. Please try again after reconnecting to the internet.");
                      return;
                    }

                    if (formKey.currentState!.validate()) {
                      errorFeedback.value = null;

                      final email = emailController.text.trim();

                      // // TODO: Implement password reset logic
                      // final result = await AuthService.sendPasswordResetEmail(email);
                      // // final result = null;

                      // // TODO: update this based on the return value of sendPasswordResetEmail
                      // if (result == null) {
                      //   errorFeedback.value = 'Error sending reset email. Please try again.';
                      // } else {
                      //   // navigate to gegt started, show snack bar indicating that the request for reset password has been submitted.
                      //   CustomSnackbars.shortDurationSnackBar(contentString: "Reset password request submitted, please check your email.");
                      // }
                    }
                  },
                  child: const ButtonText('Send Reset Email'),
                ),

                const SizedBox(height: 16.0),

                // Back to login prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const UserOnboardingMessageText(
                        "Remembered your password?"),
                    StyledButton(
                      onPressed: () => context.go(RoutePath.loginPath),
                      child: const ButtonText("Login"),
                    ),
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
