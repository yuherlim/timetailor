import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/widgets/styled_button.dart';
import 'package:timetailor/core/shared/widgets/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';

class LoginScreen extends HookWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginScrollController = useScrollController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    final errorFeedback = useState<String?>(null);
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: Colors.grey[900], // Monochrome dark background
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const AppBarText(
            'Login'), // StyledHeaderText for consistent styling
      ),
      body: SingleChildScrollView(
        controller: loginScrollController,
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
                      fit: BoxFit.cover, // Control how the image fits within the space
                    ),
                  ),
                ),

                const SizedBox(height: 16.0),

                // Intro text
                const Center(
                  child: UserOnboardingMessageText(
                      'Welcome back! Log in to start managing your schedule.'),
                ),

                const SizedBox(height: 16.0),

                // Email address input
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                      color: AppColors.textColor), // Text color for dark background
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

                // Password input
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  style: TextStyle(
                      color: AppColors.textColor), // Text color for dark background
                  decoration: InputDecoration(
                    labelText: 'Password',
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
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Error feedback
                if (errorFeedback.value != null)
                  Text(
                    errorFeedback.value!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                const SizedBox(height: 16.0),

                // Submit button
                StyledButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      errorFeedback.value = null;

                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();

                      // final user = await AuthService.signIn(email, password);
                      // // final user = null;

                      // if (user == null) {
                      //   errorFeedback.value = 'Incorrect login credentials.';
                      // } else {
                      //   // Navigate to the main app screen
                      //   Navigator.pushReplacementNamed(context, '/home');
                      // }
                    }
                  },
                  child: const ButtonText('Log In'),
                ),

                const SizedBox(height: 16.0),

                // Sign up prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const UserOnboardingMessageText("Don\'t have an account?"),
                    StyledButton(
                      onPressed: () => context.go(RoutePath.registerPath),
                      child: const ButtonText("Register"),
                    ),
                  ],
                ),

                // Forgot password prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const UserOnboardingMessageText("Forgot your password?"),
                    StyledButton(
                      onPressed: () => context.go(RoutePath.resetPasswordPath),
                      child: const ButtonText("Reset Password"),
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
