import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/shared/custom_snackbars.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/data/task_management/models/task.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/date_provider.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';

class TaskItem extends ConsumerStatefulWidget {
  final Task task;

  const TaskItem({
    super.key,
    required this.task,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TaskItemState();
}

class _TaskItemState extends ConsumerState<TaskItem> {
  void completeTask({required double dyTop, required double dyBottom}) {
    debugPrint("update task's isCompleted, prompt snackbar with undo option.");
    final taskNotifier = ref.read(tasksNotifierProvider.notifier);
    final currentTask = widget.task;
    final updatedTask = widget.task.copyWith(isCompleted: true);
    taskNotifier.updateTask(updatedTask);

    // Show the SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      longDurationSnackBarWithAction(
        onPressed: () => taskNotifier.undoTaskCompletion(
          taskToUndo: currentTask,
          dyTop: dyTop,
          dyBottom: dyBottom,
        ),
        contentString: "Task completed.",
        actionText: "Undo",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, double> taskDimensions =
        ref.read(tasksNotifierProvider.notifier).calculateTimeSlotFromTaskTime(
              startTime: widget.task.startTime,
              endTime: widget.task.endTime,
            );

    final topPosition = taskDimensions['dyTop']!;
    final slotHeight = taskDimensions['currentTimeSlotHeight']! - 1;
    final slotStartX = ref.watch(slotStartXProvider);
    final slotWidth = ref.watch(slotWidthProvider);
    final taskProviderNotifier = ref.read(tasksNotifierProvider.notifier);
    final startTime = taskProviderNotifier.formatTime(
        widget.task.startTime.hour, widget.task.startTime.minute);
    final endTime = taskProviderNotifier.formatTime(
        widget.task.endTime.hour, widget.task.endTime.minute);
    final currentDateNotifier = ref.read(currentDateNotifierProvider.notifier);

    return Positioned(
      left: slotStartX,
      top: topPosition,
      child: Stack(
        children: [
          Container(
            width: slotWidth, // Fixed width
            height: slotHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.primaryColor,
              border: Border.all(
                color: AppColors.secondaryColor, // Border color
                width: 1.0, // Border thickness
              ),
            ),
          ),
          SizedBox(
            width: slotWidth,
            height: slotHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.task.duration <= 5)
                        MiniTaskNameText(widget.task.name),
                      if (!(widget.task.duration <= 5) &&
                          widget.task.duration <= 10)
                        SmallTaskNameText(widget.task.name),
                      if (!(widget.task.duration <= 25))
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: TaskNameText(widget.task.name),
                        ),
                      if (!(widget.task.duration <= 25))
                        TaskNameText("$startTime - $endTime"),
                    ],
                  ),
                ),
                if (!(widget.task.duration <= 25) && currentDateNotifier.currentDateIsToday())
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    onPressed: () {
                      debugPrint("complete task.");
                      completeTask(
                        dyTop: taskDimensions['dyTop']!,
                        dyBottom: taskDimensions['dyBottom']!,
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    ;
  }
}
