import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/data/task_management/models/task.dart';
import 'package:timetailor/domain/task_management/providers/date_provider.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';

class CompletedTaskListItem extends ConsumerStatefulWidget {
  final Task task;

  const CompletedTaskListItem({
    super.key,
    required this.task,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CompletedTaskListItemState();
}

class _CompletedTaskListItemState extends ConsumerState<CompletedTaskListItem> {
  void showDeleteConfirmation(BuildContext context) {
    final tasksNotifier = ref.read(tasksNotifierProvider.notifier);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
              'Are you sure you want to delete this task from task history?'),
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
                tasksNotifier.removeTaskFromHistory(
                    widget.task); // Execute the confirmation action
              },
              child: Text('Delete',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksNotifier = ref.read(tasksNotifierProvider.notifier);
    final startTime = tasksNotifier.formatTime(
        widget.task.startTime.hour, widget.task.startTime.minute);
    final endTime = tasksNotifier.formatTime(
        widget.task.endTime.hour, widget.task.endTime.minute);
    final taskDimensions = tasksNotifier.calculateTimeSlotFromTaskTime(
      startTime: widget.task.startTime,
      endTime: widget.task.endTime,
    );
    final dyTop = taskDimensions['dyTop']!;
    final dyBottom = taskDimensions['dyBottom']!;
    final isCurrentDateOrMore = ref
        .read(currentDateNotifierProvider.notifier)
        .currentDateMoreThanEqualToday();

    return InkWell(
      onTap: () =>
          context.go(RoutePath.taskDetailsFromHistoryPath, extra: widget.task),
      child: Card(
        child: ListTile(
          title: Text(
            widget.task.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
              // "Completed at: ${widget.task.completedAt}", // Ensure `completedAt` is formatted if needed.
              "$startTime - $endTime"),
          trailing: isCurrentDateOrMore
              ? Row(
                  mainAxisSize:
                      MainAxisSize.min, // Ensure Row takes minimal space
                  children: [
                    IconButton(
                      icon: const Icon(Symbols.undo_rounded),
                      onPressed: () => tasksNotifier.undoTaskCompletion(
                        dyTop: dyTop,
                        dyBottom: dyBottom,
                        taskToUndo: widget.task.copyWith(isCompleted: false),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever_outlined),
                      onPressed: () => showDeleteConfirmation(context),
                    ),
                  ],
                )
              : null,
        ),
      ),
    );
  }
}
