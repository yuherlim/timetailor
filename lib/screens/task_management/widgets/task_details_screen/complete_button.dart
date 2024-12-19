import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/custom_snackbars.dart';
import 'package:timetailor/core/shared/styled_button.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/data/task_management/models/task.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';
import 'package:go_router/go_router.dart';

class CompleteButton extends ConsumerWidget {
  final Task task;

  const CompleteButton({super.key, required this.task});

  void handleMarkComplete(WidgetRef ref, BuildContext context) {
    final tasksNotifier = ref.read(tasksNotifierProvider.notifier);
    final Map<String, double> taskDimensions =
        ref.read(tasksNotifierProvider.notifier).calculateTimeSlotFromTaskTime(
              startTime: task.startTime,
              endTime: task.endTime,
            );
    final dyTop = taskDimensions['dyTop']!;
    final dyBottom = taskDimensions['dyBottom']!;
    final updatedTask = task.copyWith(isCompleted: true);

    tasksNotifier.updateTask(updatedTask);

    CustomSnackbars.longDurationSnackBarWithAction(
      contentString: "Task completed.",
      actionText: "Undo",
      onPressed: () => tasksNotifier.undoTaskCompletion(
        dyTop: dyTop,
        dyBottom: dyBottom,
        taskToUndo: task,
      ),
    );

    context.go(RoutePath.taskManagementPath);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StyledButton(
      onPressed: () => handleMarkComplete(ref, context),
      child: const ButtonText("Mark completed"),
    );
  }
}
