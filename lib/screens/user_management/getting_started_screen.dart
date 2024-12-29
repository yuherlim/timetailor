import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/widgets/styled_button.dart';
import 'package:timetailor/core/shared/widgets/styled_text.dart';

class GettingStartedScreen extends StatelessWidget {
  const GettingStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Monochrome dark background
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const AppBarText(
            'Getting Started'), // StyledHeaderText for consistent styling
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App name
            const Center(
              child: AppNameText("TimeTailor"),
            ),

            const SizedBox(height: 32),

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

            const SizedBox(height: 32),

            const Center(
              child: UserOnboardingMessageText(
                  "Welcome to TimeTailor! Let's set up your profile and get started on your journey to effortless time management."),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StyledButton(
                  onPressed: () => context.go(RoutePath.loginPath),
                  child: const ButtonText("Login"),
                ),
                StyledButton(
                  onPressed: () => context.go(RoutePath.registerPath),
                  child: const ButtonText("Register"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
