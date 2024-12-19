import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timetailor/core/config/routes.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/custom_snackbars.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/data/task_management/models/task.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/date_provider.dart';
import 'package:timetailor/domain/task_management/providers/task_form_provider.dart';
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
    CustomSnackbars.longDurationSnackBarWithAction(
      contentString: "Task completed.",
      actionText: "Undo",
      onPressed: () => taskNotifier.undoTaskCompletion(
        taskToUndo: currentTask,
        dyTop: dyTop,
        dyBottom: dyBottom,
      ),
    );
  }

  // Determine the task display type based on duration
  String getTaskDisplayType(int duration) {
    if (duration <= 5) {
      return 'mini';
    } else if (duration < 15) {
      return 'small';
    } else {
      return 'normal';
    }
  }

  Row buildTaskRow({
    required String taskName,
    required int duration,
    required String startTime,
    required String endTime,
    required Map<String, double> taskDimensions,
  }) {
    final currentDateNotifier = ref.read(currentDateNotifierProvider.notifier);
    const double sidePadding = 16;
    const double topPadding = 8;

    if (getTaskDisplayType(duration) == 'mini') {
      return Row(
        children: [
          const SizedBox(width: sidePadding),
          Expanded(flex: 5, child: MiniTaskNameText(taskName)),
          const Expanded(flex: 1, child: SizedBox()),
          Expanded(flex: 4, child: MiniTaskNameText("$startTime - $endTime")),
          const SizedBox(width: sidePadding),
        ],
      );
    } else if (getTaskDisplayType(duration) == 'small') {
      return Row(
        children: [
          const SizedBox(width: sidePadding),
          Expanded(flex: 5, child: SmallTaskNameText(taskName)),
          const Expanded(flex: 1, child: SizedBox()),
          Expanded(flex: 4, child: SmallTaskTimeText("$startTime - $endTime")),
          const SizedBox(width: sidePadding),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: sidePadding),
          Expanded(
            flex: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: topPadding),
                NormalTaskNameText(taskName),
                NormalTaskNameText("$startTime - $endTime"),
              ],
            ),
          ),
          const SizedBox(width: sidePadding),
          if (currentDateNotifier.currentDateMoreThanEqualToday())
            IconButton(
              icon: const Icon(Icons.check_circle_outline_rounded),
              onPressed: () {
                completeTask(
                  dyTop: taskDimensions['dyTop']!,
                  dyBottom: taskDimensions['dyBottom']!,
                );
              },
            ),
        ],
      );
    }
  }

  void handleOnDoubleTap() {
    CustomSnackbars.clearSnackBars();
    final taskNotifier = ref.read(tasksNotifierProvider.notifier);

    // reset any previous task editing
    taskNotifier.endTaskCreation();

    // update edit status and selectedTask
    ref.read(isEditingTaskProvider.notifier).state = true;
    ref.read(selectedTaskProvider.notifier).state = widget.task;

    final selectedTask = ref.read(selectedTaskProvider)!;
    final taskDimensions = taskNotifier.calculateTimeSlotFromTaskTime(
        startTime: selectedTask.startTime, endTime: selectedTask.endTime);
    final selectedTaskDyTop = taskDimensions["dyTop"]!;
    final selectedTaskTimeSlotHeight = taskDimensions["currentTimeSlotHeight"]!;
    final formNotifier = ref.read(taskFormNotifierProvider.notifier);

    print("selected Task: ${selectedTask.name}");

    //update draggable box and bottom sheet to reflect selected task
    ref.read(localDyProvider.notifier).state = selectedTaskDyTop;
    ref.read(localCurrentTimeSlotHeightProvider.notifier).state =
        selectedTaskTimeSlotHeight;
    taskNotifier.updateTaskTimeStateFromDraggableBox(
        dy: selectedTaskDyTop,
        currentTimeSlotHeight: selectedTaskTimeSlotHeight);
    formNotifier.updateName(selectedTask.name);
    formNotifier.updateDescription(selectedTask.description);

    print(
        "formState name after update: ${ref.read(taskFormNotifierProvider).name}");

    // remove task temporarily, for when editing task.
    taskNotifier.removeTask(selectedTask);

    // show the draggable box and bottom sheet for edit
    ref.read(showDraggableBoxProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(selectedTaskProvider);
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
    final selectedTask = ref.watch(selectedTaskProvider);
    final isEditingThisTask =
        ref.watch(isEditingTaskProvider) && widget.task == selectedTask;
    final isCurrentDateTodayOrGreater = ref
        .read(currentDateNotifierProvider.notifier)
        .currentDateMoreThanEqualToday();

    return Positioned(
      left: slotStartX,
      top: topPosition,
      child: GestureDetector(
        onTap: () {
          context.go(RoutePath.taskDetailsPath, extra: widget.task);
        },
        onDoubleTap: () {
          if (isCurrentDateTodayOrGreater) {
            handleOnDoubleTap();
          }
        },
        child: !isEditingThisTask
            ? Stack(
                children: [
                  // Task Item container
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
                  // Task item content
                  SizedBox(
                    width: slotWidth,
                    height: slotHeight,
                    child: buildTaskRow(
                        duration: widget.task.duration,
                        endTime: endTime,
                        startTime: startTime,
                        taskDimensions: taskDimensions,
                        taskName: widget.task.name),
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
