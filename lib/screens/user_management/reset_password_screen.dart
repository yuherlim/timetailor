import 'package:flutter/material.dart';
import 'package:timetailor/core/shared/widgets/styled_text.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppBarText("Reset Password"),
      ),
    );
  }
}