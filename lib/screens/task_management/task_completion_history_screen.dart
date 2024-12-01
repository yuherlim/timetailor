import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timetailor/core/shared/styled_button.dart';
import 'package:timetailor/core/shared/styled_text.dart';

class TaskCompletionHistoryScreen extends StatefulWidget {
  const TaskCompletionHistoryScreen({super.key});

  @override
  State<TaskCompletionHistoryScreen> createState() =>
      _TaskCompletionHistoryScreenState();
}

class _TaskCompletionHistoryScreenState
    extends State<TaskCompletionHistoryScreen> {
  // need the date passed in from TaskManagement
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppBarText("History"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const StyledHeading("Task Details"),
            const SizedBox(height: 20),
            const StyledTitle("Task Details"),
            const SizedBox(height: 20),
            const StyledText("Task Details"),
            const SizedBox(height: 20),
            StyledButton(
              onPressed: () {
                // Navigate back to the previous screen
                GoRouter.of(context).canPop()
                    ? {context.pop()}
                    : context.go('/tasks'); // Fallback to Tasks
              },
              child: const StyledTitle("Back"),
            ),
          ],
        ),
      ),
    );
  }
}
