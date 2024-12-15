import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:timetailor/data/task_management/models/task.dart';
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          widget.task.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
            // "Completed at: ${widget.task.completedAt}", // Ensure `completedAt` is formatted if needed.
            "$startTime - $endTime"),
        trailing: IconButton(
          icon: const Icon(Symbols.undo_rounded),
          onPressed: () => tasksNotifier.undoTaskCompletion(
            dyTop: dyTop,
            dyBottom: dyBottom,
            taskToUndo: widget.task.copyWith(isCompleted: false),
          ),
        ),
      ),
    );
  }
}
