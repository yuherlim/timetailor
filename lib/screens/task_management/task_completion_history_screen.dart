import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timetailor/core/shared/widgets/content_divider.dart';
import 'package:timetailor/core/shared/widgets/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/task_management/providers/date_provider.dart';
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
  void showClearHistoryConfirmation(BuildContext context) {
    final tasksNotifier = ref.read(tasksNotifierProvider.notifier);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Clear History'),
          content: const Text(
              'Are you sure you want to remove all completed tasks from task history?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                tasksNotifier
                    .removeCompletedTasksForCurrentDate(); // Execute the confirmation action
              },
              child: Text('Remove',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(tasksNotifierProvider);
    final completedTasks = ref
        .read(tasksNotifierProvider.notifier)
        .getAllCompletedTasksForCurrentDate();
    final currentDate = ref.watch(currentDateNotifierProvider);
    // Format DateTime to "Monday, 16 December 2024"
    final String formattedDate =
        DateFormat('EEEE, d MMMM yyyy').format(currentDate);
    final isCurrentDateTodayOrGreater = ref
        .read(currentDateNotifierProvider.notifier)
        .currentDateMoreThanEqualToday();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        title: const AppBarText("History"),
        actions: [
          if (isCurrentDateTodayOrGreater)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                // Handle menu item selection
                if (value == 'Clear History') {
                  // Example action: Clear history logic
                  showClearHistoryConfirmation(context);
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'Clear History',
                    child: Text('Clear History'),
                  ),
                ];
              },
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0),
            child: NoListItemTitle(formattedDate),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: ContentDivider(),
          ),
          completedTasks.isEmpty
              ? const Expanded(
                  child: Center(
                    child: NoListItemTitle(
                      "No completed tasks for today.",
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: completedTasks.length,
                    itemBuilder: (context, index) {
                      final task = completedTasks[index];
                      return CompletedTaskListItem(task: task);
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
