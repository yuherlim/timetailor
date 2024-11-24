import 'package:flutter/material.dart';
import 'package:timetailor/core/shared/styled_text.dart';

class AccountManagementScreen extends StatelessWidget {
  const AccountManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const StyledTitle("Account Management"),
        centerTitle: true,
      ),
      body: const Placeholder(),
    );
  }
}