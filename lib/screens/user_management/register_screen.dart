import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/widgets/styled_button.dart';
import 'package:timetailor/core/shared/widgets/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';

class RegisterScreen extends HookWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final registerScrollController = useScrollController();
    final usernameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();

    final errorFeedback = useState<String?>(null);
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: Colors.grey[900], // Monochrome dark background
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const AppBarText(
            'Register'), // StyledHeaderText for consistent styling
      ),
      body: SingleChildScrollView(
        controller: registerScrollController,
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
                      'Create an account to start managing your schedule.'),
                ),
        
                const SizedBox(height: 16.0),
        
                // Username input
                TextFormField(
                  controller: usernameController,
                  style: TextStyle(
                      color: AppColors.textColor), // Text color for dark background
                  decoration: InputDecoration(
                    labelText: 'Username',
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
                      return 'Please enter your username';
                    }
                    return null;
                  },
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
                    errorMaxLines: 5,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    final passwordRegex = RegExp(
                      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$%\^&\*\(\)_\+\-=\[\]\{\},.<>\/\?]).{8,}$',
                    );
                    if (!passwordRegex.hasMatch(value)) {
                      return 'Password must contain at least 8 characters, one uppercase letter, one lowercase letter, one digit, and one special character';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
        
                // Confirm Password input
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  style: TextStyle(
                      color: AppColors.textColor), // Text color for dark background
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
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
                      return 'Please confirm your password';
                    }
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
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
        
                      final username = usernameController.text.trim();
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();
        
                      // final result = await AuthService.register(username, email, password);
                      // // final result = null;
        
                      // if (result == null) {
                      //   errorFeedback.value = 'Registration failed. Please try again.';
                      // } else {
                      //   Navigator.pushReplacementNamed(context, '/home');
                      // }
                    }
                  },
                  child: const ButtonText('Register'),
                ),
        
                const SizedBox(height: 16.0),
        
                 // Login prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const UserOnboardingMessageText("Already have an account?"),
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
