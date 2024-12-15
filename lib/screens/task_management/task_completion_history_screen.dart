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
        .watch(tasksNotifierProvider.notifier)
        .getAllCompletedTasksForCurrentDate();
    return Scaffold(
      appBar: AppBar(
        title: const AppBarText("History"),
      ),
      // body: 
    );
  }
}
