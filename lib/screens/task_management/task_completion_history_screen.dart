import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/styled_button.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';
import 'package:timetailor/screens/task_management/widgets/task_completion_history_screen/completed_task_list_item.dart';

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
    ref.watch(tasksNotifierProvider);
    final completedTasks = ref
        .read(tasksNotifierProvider.notifier)
        .getAllCompletedTasksForCurrentDate();
    return Scaffold(
      appBar: AppBar(
        title: const AppBarText("History"),
      ),
      body: completedTasks.isEmpty
          ? Center(
              child: Text(
                "No completed tasks for today.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : ListView.builder(
              itemCount: completedTasks.length,
              itemBuilder: (context, index) {
                final task = completedTasks[index];
                return CompletedTaskListItem(task: task);
              },
            ),
    );
  }
}
