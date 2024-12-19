import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/custom_snackbars.dart';
import 'package:timetailor/core/shared/styled_button.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/data/task_management/models/task.dart';
import 'package:timetailor/domain/task_management/providers/bottom_sheet_scroll_controller_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/date_provider.dart';
import 'package:timetailor/domain/task_management/providers/task_form_provider.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';
import 'package:timetailor/screens/task_management/widgets/task_details_screen/complete_button.dart';
import 'package:timetailor/screens/task_management/widgets/task_details_screen/content_divider.dart';
import 'package:timetailor/screens/task_management/widgets/task_details_screen/view_description.dart';
import 'package:timetailor/screens/task_management/widgets/task_details_screen/view_notes_section.dart';
import 'package:timetailor/screens/task_management/widgets/task_details_screen/view_title_date.dart';

class TaskDetailsScreen extends StatefulHookConsumerWidget {
  final Task task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends ConsumerState<TaskDetailsScreen> {
  void handleEdit() {
    CustomSnackbars.clearSnackBars();
    // navigate to the task management screen
    context.go(RoutePath.taskManagementPath);

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
    //scroll to max extent
    ref
        .read(bottomSheetScrollControllerNotifierProvider.notifier)
        .scrollToMaxExtentWithoutAnimation();
  }

  void handleUndo() {
    final tasksNotifier = ref.read(tasksNotifierProvider.notifier);
    final taskDimensions = tasksNotifier.calculateTimeSlotFromTaskTime(
        startTime: widget.task.startTime, endTime: widget.task.endTime);
    final dyTop = taskDimensions['dyTop']!;
    final dyBottom = taskDimensions['dyBottom']!;
    tasksNotifier.undoTaskCompletion(
      taskToUndo: widget.task.copyWith(isCompleted: false),
      dyTop: dyTop,
      dyBottom: dyBottom,
    );
    context.go(RoutePath.taskManagementPath);
  }

  void handleDelete() {
    final tasksNotifier = ref.read(tasksNotifierProvider.notifier);
    final taskDimensions = tasksNotifier.calculateTimeSlotFromTaskTime(
        startTime: widget.task.startTime, endTime: widget.task.endTime);
    final dyTop = taskDimensions['dyTop']!;
    final dyBottom = taskDimensions['dyBottom']!;
    final taskToRemove = widget.task;
    tasksNotifier.removeTask(taskToRemove);
    CustomSnackbars.longDurationSnackBarWithAction(
      contentString: "Task deletion successful!",
      actionText: "undo",
      onPressed: () => tasksNotifier.undoTaskDeletion(
        taskToUndo: taskToRemove,
        dyBottom: dyBottom,
        dyTop: dyTop,
      ),
    );
    context.go(RoutePath.taskManagementPath);
  }

  void showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this task?'),
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
                handleDelete(); // Execute the confirmation action
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
    CustomSnackbars.clearSnackBars();
    final isCurrentDateTodayOrGreater = ref
        .read(currentDateNotifierProvider.notifier)
        .currentDateMoreThanEqualToday();
    final isFromTaskHistoryScreen = GoRouter.of(context).state?.fullPath ==
        RoutePath.taskDetailsFromHistoryPath;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        title: const AppBarText("Task Details"),
        actions: [
          if (isCurrentDateTodayOrGreater)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                // Handle menu item selection
                if (value == 'Edit') {
                  handleEdit();
                } else if (value == 'Undo') {
                  handleUndo();
                } else if (value == 'Delete') {
                  showDeleteConfirmation(context);
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  if (isCurrentDateTodayOrGreater && !isFromTaskHistoryScreen)
                    const PopupMenuItem<String>(
                      value: 'Edit',
                      child: Text('Edit'),
                    ),
                  if (isCurrentDateTodayOrGreater && isFromTaskHistoryScreen)
                    const PopupMenuItem<String>(
                      value: 'Undo',
                      child: Text('Undo'),
                    ),
                  const PopupMenuItem<String>(
                    value: 'Delete',
                    child: Text('Delete'),
                  ),
                ];
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ViewTitleDate(task: widget.task),
                      const ContentDivider(),
                      ViewDescription(task: widget.task),
                      const ContentDivider(),
                      ViewNotesSection(task: widget.task),
                      const SizedBox(height: 16),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isCurrentDateTodayOrGreater && !isFromTaskHistoryScreen)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const ContentDivider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: CompleteButton(
                    task: widget.task,
                  ),
                ),
              ],
            ),
        ],
      ),
      // Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     Padding(
      //       padding: const EdgeInsets.only(left: 16.0, top: 16.0),
      //       child: TitleTextInHistory(formattedDate),
      //     ),
      //     const Padding(
      //       padding: EdgeInsets.only(top: 16.0),
      //       child: Divider(
      //         color: Colors.white, // Line color
      //         thickness: 1, // Line thickness
      //         height: 0,
      //       ),
      //     ),
      //     completedTasks.isEmpty
      //         ? const Expanded(
      //             child: Center(
      //               child: TitleTextInHistory(
      //                 "No completed tasks for today.",
      //               ),
      //             ),
      //           )
      //         : Expanded(
      //             child: ListView.builder(
      //               itemCount: completedTasks.length,
      //               itemBuilder: (context, index) {
      //                 final task = completedTasks[index];
      //                 return CompletedTaskListItem(task: task);
      //               },
      //             ),
      //           ),
      //   ],
      // ),
    );
  }
}
