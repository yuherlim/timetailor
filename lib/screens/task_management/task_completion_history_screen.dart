import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/styled_button.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';

class TaskCompletionHistoryScreen extends ConsumerStatefulWidget {
  const TaskCompletionHistoryScreen({super.key});

  @override
  ConsumerState<TaskCompletionHistoryScreen> createState() =>
      _TaskCompletionHistoryScreenState();
}

class _TaskCompletionHistoryScreenState
    extends ConsumerState<TaskCompletionHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final completedTasks = ref
        .read(tasksNotifierProvider.notifier)
        .getAllCompletedTasksForCurrentDate();
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
                    : context
                        .go(RoutePath.taskManagementPath); // Fallback to Tasks
              },
              child: const StyledTitle("Back"),
            ),
          ],
        ),
      ),
    );
  }
}
