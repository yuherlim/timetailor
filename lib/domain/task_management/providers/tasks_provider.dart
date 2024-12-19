import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timetailor/core/shared/custom_snackbars.dart';
import 'package:timetailor/data/task_management/models/task.dart';
import 'package:timetailor/domain/task_management/providers/bottom_sheet_scroll_controller_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_read_only_provider.dart';
import 'package:timetailor/domain/task_management/providers/date_provider.dart';
import 'package:timetailor/domain/task_management/providers/task_form_controller_provider.dart';
import 'package:timetailor/domain/task_management/providers/task_form_provider.dart';
import 'package:timetailor/main.dart';

part 'tasks_provider.g.dart'; // Generated file

@riverpod
class TasksNotifier extends _$TasksNotifier {
  @override
  List<Task> build() {
    return tasks;
  }

  List<Task>? getAllTasksForCurrentDate() {
    final currentDate = ref.read(currentDateNotifierProvider);
    return state
        .where((task) =>
            currentDate.isAtSameMomentAs(task.date) && !task.isCompleted)
        .toList();
  }

  List<Task> getAllCompletedTasksForCurrentDate() {
    final currentDate = ref.read(currentDateNotifierProvider);
    return state
        .where((task) =>
            currentDate.isAtSameMomentAs(task.date) && task.isCompleted)
        .toList();
  }

  void addTask(Task task) {
    state = [...state, task];
  }

  void updateTask(Task updatedTask) {
    state = state
        .map((currentTask) =>
            currentTask.id == updatedTask.id ? updatedTask : currentTask)
        .toList();
  }

  void removeTask(Task task) {
    state = state.where((currentTask) => currentTask != task).toList();
  }

  void undoTaskCreation(Task taskToUndo) {
    removeTask(taskToUndo);
    CustomSnackbars.shortDurationSnackBar(contentString: "Task removed.");
  }

  void undoTaskEdit(Task taskToUndo) {
    updateTask(taskToUndo);
    CustomSnackbars.shortDurationSnackBar(
        contentString: "Task changes reverted!");
  }

  void undoCompletedTasksRemoval(List<Task> tasksToRestore) {
    state = [...state, ...tasksToRestore];
    CustomSnackbars.shortDurationSnackBar(
        contentString: "Completed task(s) restored!");
  }

  void removeCompletedTasksForCurrentDate() {
    final currentDate = ref.read(currentDateNotifierProvider);
    // Store the list of tasks to be removed for undo functionality
    final tasksToRemove = state
        .where(
          (task) => task.isCompleted && currentDate.isAtSameMomentAs(task.date),
        )
        .toList();

    // Update the state by filtering out the tasks to be removed
    state = state
        .where(
          (task) =>
              !(task.isCompleted && currentDate.isAtSameMomentAs(task.date)),
        )
        .toList();

    if (tasksToRemove.isNotEmpty) {
      CustomSnackbars.longDurationSnackBarWithAction(
        contentString: "All completed tasks removed successfully!",
        actionText: "Undo",
        onPressed: () => undoCompletedTasksRemoval(tasksToRemove),
      );
    } else {
      CustomSnackbars.shortDurationSnackBar(
          contentString: "No completed task(s) to remove.");
    }
  }

  void removeTaskFromHistory(Task task) {
    state = state.where((currentTask) => currentTask != task).toList();
    CustomSnackbars.longDurationSnackBarWithAction(
      contentString: "Task deletion successful!",
      actionText: "Undo",
      onPressed: () => undoTaskHistoryDeletion(
        taskToUndo: task,
      ),
    );
  }

  // these methods are to be converted to use firestore later.

  //fetchTasksOnce

  // for undo deleted task in the history screen
  void undoTaskHistoryDeletion({
    required Task taskToUndo,
  }) {
    addTask(taskToUndo);
    CustomSnackbars.shortDurationSnackBar(
        contentString: "Undo task deletion successful!");
  }

  // for undo completed task and deleted task
  void undoTaskStatusChange({
    required Task taskToUndo,
    required double dyTop,
    required double dyBottom,
    required String successMessage,
    required String failureMessage,
  }) {
    if (checkAddTaskValidity(dyTop: dyTop, dyBottom: dyBottom)) {
      updateTask(taskToUndo);
      CustomSnackbars.shortDurationSnackBar(contentString: successMessage);
    } else {
      CustomSnackbars.shortDurationSnackBar(contentString: failureMessage);
    }
  }

  bool checkAddTaskValidity({
    required double dyTop,
    required double dyBottom,
  }) {
    final currentDate = ref.read(currentDateNotifierProvider);

    return !state.any(
      (task) {
        final taskDimensions = calculateTimeSlotFromTaskTime(
            startTime: task.startTime, endTime: task.endTime);
        final taskDyTop = taskDimensions['dyTop']!;
        final taskDyBottom = taskDimensions['dyBottom']!;

        // Check if the current task overlaps with any existing uncompleted task for the currentDate
        return dyBottom > taskDyTop &&
            dyTop < taskDyBottom &&
            !task.isCompleted &&
            task.date.isAtSameMomentAs(currentDate);
      },
    );
  }

  // Converts dy and height into start and end times.
  void updateTaskTimeStateFromDraggableBox({
    required double dy,
    required double currentTimeSlotHeight,
  }) {
    // Calculate start time
    final startTime = calculateStartTime();
    final startHour = startTime["startHour"]!;
    final startMinutes = startTime["startMinutes"]!;

    // Calculate end time
    final endTime = calculateEndTime();
    final endHour = endTime["endHour"]!;
    final endMinutes = endTime["endMinutes"]!;

    ref.read(startTimeProvider.notifier).state =
        formatTime(startHour, startMinutes);
    ref.read(endTimeProvider.notifier).state = formatTime(endHour, endMinutes);
  }

  // Get the task's position from their start and end time.
  Map<String, double> calculateTimeSlotFromTaskTime({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    // Fetch required providers
    final snapIntervalMinutes = ref.read(snapIntervalMinutesProvider);
    final snapIntervalHeight = ref.read(snapIntervalHeightProvider);
    final calendarWidgetTopBoundaryY =
        ref.read(calendarWidgetTopBoundaryYProvider);

    // Ensure endTime is after startTime
    assert(endTime.isAfter(startTime), 'endTime must be after startTime.');

    // Calculate the start time's offset from midnight in minutes
    int startOffsetMinutes = startTime.hour * 60 + startTime.minute;

    // Calculate dyTop (position of the box's top edge)
    double dyTop = calendarWidgetTopBoundaryY +
        (startOffsetMinutes / snapIntervalMinutes) * snapIntervalHeight;

    // Calculate the duration in minutes between start and end times
    int durationMinutes = endTime.difference(startTime).inMinutes;

    // Calculate currentTimeSlotHeight (box height in pixels)
    double currentTimeSlotHeight =
        (durationMinutes / snapIntervalMinutes) * snapIntervalHeight;

    // Calculate dyBottom (position of the box's bottom edge)
    double dyBottom = dyTop + currentTimeSlotHeight;

    // Return the computed values
    return {
      'dyTop': dyTop,
      'currentTimeSlotHeight': currentTimeSlotHeight,
      'dyBottom': dyBottom,
    };
  }

  // Format as "HH:MM AM/PM" from a 24 hours format string
  String formatTime(int hour, int minutes) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final normalizedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final paddedMinutes = minutes.toString().padLeft(2, '0');
    return '$normalizedHour:$paddedMinutes $period';
  }

  Map<String, DateTime> getStartTimeEndTimeInDateTime() {
    final currentDate = ref.read(currentDateNotifierProvider);

    // Calculate start time
    final startTime = calculateStartTime();
    final startHour = startTime["startHour"]!;
    final startMinutes = startTime["startMinutes"]!;

    // Calculate end time
    final endTime = calculateEndTime();
    final endHour = endTime["endHour"]!;
    final endMinutes = endTime["endMinutes"]!;

    final startTimeDateTime = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
      startHour,
      startMinutes,
    );

    final endTimeDateTime = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
      endHour,
      endMinutes,
    );

    return {
      "startTime": startTimeDateTime,
      "endTime": endTimeDateTime,
    };
  }

  Map<String, int> calculateStartTime() {
    final defaultTimeSlotHeight = ref.read(defaultTimeSlotHeightProvider);
    final calendarWidgetTopBoundaryY =
        ref.read(calendarWidgetTopBoundaryYProvider);
    final localDy = ref.read(localDyProvider);
    final snapIntervalHeight = ref.read(snapIntervalHeightProvider);
    final snapIntervalMinutes = ref.read(snapIntervalMinutesProvider);

    double topOffsetFromCalendarStart = localDy - calendarWidgetTopBoundaryY;
    int startHour = (topOffsetFromCalendarStart ~/ defaultTimeSlotHeight);
    int startMinutes = (((topOffsetFromCalendarStart % defaultTimeSlotHeight) /
                    snapIntervalHeight)
                .round() *
            snapIntervalMinutes)
        .toInt();

    // Normalize startMinutes to prevent weird times like "7:60 PM"
    startHour += startMinutes ~/ 60; // Carry over extra minutes to hours
    startMinutes %= 60; // Ensure minutes stay within 0-59

    return {
      "startHour": startHour,
      "startMinutes": startMinutes,
    };
  }

  Map<String, int> calculateEndTime() {
    final snapIntervalHeight = ref.read(snapIntervalHeightProvider);
    final calendarWidgetBottomBoundaryY =
        ref.read(calendarWidgetBottomBoundaryYProvider);
    final localDyBottom = ref.read(localDyBottomProvider);

// Calculate duration in minutes
    int durationMinutes = calculateDurationInMinutes();

    // Calculate start time
    final startTime = calculateStartTime();
    final startHour = startTime["startHour"]!;
    final startMinutes = startTime["startMinutes"]!;

    // Calculate end time
    int endHour = startHour + (durationMinutes ~/ 60);
    int endMinutes = startMinutes + (durationMinutes % 60);

    final lastSnapIntervalMidpointDy =
        calendarWidgetBottomBoundaryY - snapIntervalHeight / 2;

    if (localDyBottom > lastSnapIntervalMidpointDy) {
      endHour = 23; // Set to 11 PM
      endMinutes = 59; // Set to 59 minutes
    }

    // Normalize endMinutes to prevent weird times like "7:60 PM"
    endHour += endMinutes ~/ 60; // Carry over extra minutes to hours
    endMinutes %= 60; // Ensure minutes stay within 0-59

    return {
      "endHour": endHour,
      "endMinutes": endMinutes,
    };
  }

  int calculateDurationInMinutes() {
    final localCurrentTimeSlotHeight =
        ref.read(localCurrentTimeSlotHeightProvider);
    final snapIntervalHeight = ref.read(snapIntervalHeightProvider);
    final snapIntervalMinutes = ref.read(snapIntervalMinutesProvider);

    return ((localCurrentTimeSlotHeight / snapIntervalHeight).round() *
            snapIntervalMinutes)
        .toInt();
  }

  String formattedDurationString() {
    final durationMinutes = calculateDurationInMinutes();
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;

    final hourStr = "$hours hour(s)";
    final minuteStr = "$minutes minute(s)";

    String outputStr = "";

    if (hours > 0) {
      outputStr += hourStr;
    }

    if (minutes > 0) {
      outputStr += " $minuteStr";
    }

    return outputStr;
  }

  String durationIndicatorString() {
    final durationMinutes = calculateDurationInMinutes();
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;

    final hourStr = "$hours hr(s)";
    final minuteStr = "$minutes min(s)";

    String outputStr = "";

    if (hours > 0) {
      outputStr += hourStr;
    }

    if (minutes > 0) {
      outputStr += " $minuteStr";
    }

    return outputStr;
  }

  void endTaskCreation() {
    final taskFormNotifier = ref.read(taskFormNotifierProvider.notifier);
    ref.read(showDraggableBoxProvider.notifier).state = false;
    taskFormNotifier.resetState();
    resetBottomSheetState();
    resetEditState();
    // reset draggableBox show state
  }

  void resetBottomSheetState() {
    final initialExtent = ref.read(initialBottomSheetExtentProvider);
    final sheetExtentNotifier = ref.read(sheetExtentProvider.notifier);
    final bottomSheetControllerNotifier =
        ref.read(bottomSheetScrollControllerNotifierProvider.notifier);
    sheetExtentNotifier.update(initialExtent);
    bottomSheetControllerNotifier.scrollToInitialExtentWithoutAnimation();
  }

  void resetEditState() {
    final taskNotifier = ref.read(tasksNotifierProvider.notifier);
    final selectedTask = ref.read(selectedTaskProvider);

    // turn off edit mode
    ref.read(isEditingTaskProvider.notifier).state = false;

    // if task edit was successful, selectedTask should be null
    if (selectedTask == null) {
      debugPrint("currently no selected task, means no task currently editing");
      return;
    } else {
      // Add back task if edit fail.
      taskNotifier.addTask(selectedTask);
    }
  }
}
