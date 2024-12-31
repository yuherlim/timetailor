import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timetailor/core/shared/custom_snackbars.dart';
import 'package:timetailor/core/shared/utils.dart';
import 'package:timetailor/data/task_management/models/task.dart';
import 'package:timetailor/data/task_management/repositories/task_repository.dart';
import 'package:timetailor/domain/note_management/providers/note_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/bottom_sheet_scroll_controller_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_read_only_provider.dart';
import 'package:timetailor/domain/task_management/providers/date_provider.dart';
import 'package:timetailor/domain/task_management/providers/task_form_provider.dart';
import 'package:timetailor/domain/user_management/providers/user_provider.dart';

part 'tasks_provider.g.dart'; // Generated file

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

@riverpod
class TasksNotifier extends _$TasksNotifier {
  TaskRepository get _taskRepository => ref.read(taskRepositoryProvider);
  String get _currentUserId => ref.read(currentUserProvider)!.id;
  // NoteRepository get _noteRepository => ref.read(noteRepositoryProvider);

  bool isLoading = false; // Add loading state

  @override
  List<Task> build() {
    return [];
  }

  Future<void> fetchTasksFromFirestore() async {
    isLoading = true; // Start loading
    try {
      final tasks = await _taskRepository.getTasksByUserId(_currentUserId);
      state = tasks;
    } catch (e) {
      CustomSnackbars.shortDurationSnackBar(
          contentString: "Failed to fetch tasks: $e");
    } finally {
      isLoading = false; // End loading
    }
  }

  // Future<void> addNoteToTask(String noteId) async {
  //   final selectedTask = ref.read(selectedTaskProvider)!;
  //   // if noteId already in selectedTask linkedNote list
  //   if (selectedTask.linkedNote.contains(noteId)) {
  //     CustomSnackbars.shortDurationSnackBar(
  //         contentString: "This note has already been added to this task.");
  //     return;
  //   }

  //   final updatedLinkedNotes = [...selectedTask.linkedNote, noteId];
  //   final updatedTask = selectedTask.copyWith(linkedNote: updatedLinkedNotes);
  //   try {
  //     await updateTask(updatedTask); // Persist the changes
  //   } catch (e) {
  //     CustomSnackbars.shortDurationSnackBar(
  //         contentString: "Failed to add note to the task: $e");
  //   }
  // }

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
        .toList()
      ..sort((a, b) {
        final startTimeComparison = a.startTime.compareTo(b.startTime);
        if (startTimeComparison != 0) {
          return startTimeComparison; // Sort by startTime first
        }
        return a.endTime
            .compareTo(b.endTime); // If startTime is equal, sort by endTime
      });
  }

  Future<void> addTask(Task task) async {
    // Optimistically update local state
    final previousState = state;
    state = [...state, task];

    try {
      await _taskRepository.addTask(task); // Sync to Firestore
    } catch (e) {
      // Roll back local state if Firebase operation fails
      state = previousState;
      CustomSnackbars.shortDurationSnackBar(
          contentString: "Failed to add task: $e");
    }
  }

  Future<void> updateTask(Task updatedTask) async {
    // Optimistically update local state
    final previousState = state;
    state = state
        .map((task) => task.id == updatedTask.id ? updatedTask : task)
        .toList();

    try {
      await _taskRepository.updateTask(updatedTask); // Sync to Firestore
    } catch (e) {
      // Roll back local state if Firebase operation fails
      state = previousState;
      CustomSnackbars.shortDurationSnackBar(
          contentString: "Failed to update task: $e");
    }
  }

  Future<void> removeTask(Task task) async {
    // Optimistically update local state
    final previousState = state;
    state = state.where((currentTask) => currentTask.id != task.id).toList();

    try {
      await _taskRepository.deleteTask(task.id); // Sync to Firestore
    } catch (e) {
      // Roll back local state if Firebase operation fails
      state = previousState;
      CustomSnackbars.shortDurationSnackBar(
          contentString: "Failed to remove task: $e");
    }
  }

  Future<void> undoTaskCreation(Task taskToUndo) async {
    await removeTask(taskToUndo);
    CustomSnackbars.shortDurationSnackBar(contentString: "Task removed.");
  }

  Future<void> undoTaskEdit(
      Task taskToUndo,
      Function(Task task) navigateToTaskDetails,
      bool isEditFromTaskDetails) async {
    await updateTask(taskToUndo);
    CustomSnackbars.shortDurationSnackBar(
        contentString: "Task changes reverted!");

    //; update undo flag for if edit was from task details.
    if (isEditFromTaskDetails) {
      navigateToTaskDetails(taskToUndo);
    }
  }

  Future<void> undoCompletedTasksRemoval(List<Task> tasksToRestore) async {
    try {
      // Add tasks to Firestore in parallel
      await Future.wait(tasksToRestore.map((task) => addTask(task)));

      CustomSnackbars.shortDurationSnackBar(
          contentString: "Completed task(s) restored!");
    } catch (e) {
      CustomSnackbars.shortDurationSnackBar(
          contentString: "Failed to restore completed tasks: $e");
    }
  }

  Future<void> removeCompletedTasksForCurrentDate() async {
    final currentDate = ref.read(currentDateNotifierProvider);
    final tasksToRemove = state
        .where(
          (task) => task.isCompleted && currentDate.isAtSameMomentAs(task.date),
        )
        .toList();

    if (tasksToRemove.isEmpty) {
      CustomSnackbars.shortDurationSnackBar(
          contentString: "No completed task(s) to remove.");
      return;
    }

    try {
      // Update the state by filtering out the removed tasks
      state = state
          .where(
            (task) =>
                !(task.isCompleted && currentDate.isAtSameMomentAs(task.date)),
          )
          .toList();

      // Remove tasks concurrently from Firestore
      await Future.wait(tasksToRemove.map((task) => removeTask(task)));

      CustomSnackbars.longDurationSnackBarWithAction(
        contentString: "All completed tasks removed successfully!",
        actionText: "Undo",
        onPressed: () => undoCompletedTasksRemoval(tasksToRemove),
      );
    } catch (e) {
      CustomSnackbars.shortDurationSnackBar(
          contentString: "Failed to remove completed tasks: $e");
    }
  }

  Future<void> removeTaskFromHistory(Task task) async {
    try {
      // Remove task from local state
      state = state.where((currentTask) => currentTask != task).toList();

      // Delete the task from Firestore
      await _taskRepository.deleteTask(task.id);

      // Show snackbar with undo option
      CustomSnackbars.longDurationSnackBarWithAction(
        contentString: "Task deletion successful!",
        actionText: "Undo",
        onPressed: () => undoTaskHistoryDeletion(taskToUndo: task),
      );
    } catch (e) {
      // Handle errors (e.g., network issues, Firestore failures)
      CustomSnackbars.shortDurationSnackBar(
          contentString: "Failed to delete task: $e");
    }
  }

  // these methods are to be converted to use firestore later.

  //fetchTasksOnce

  // for undo deleted task in the history screen
  Future<void> undoTaskHistoryDeletion({
    required Task taskToUndo,
  }) async {
    await addTask(taskToUndo);
    CustomSnackbars.shortDurationSnackBar(
        contentString: "Undo task deletion successful!");
  }

  // for undo completed task and deleted task
  Future<void> undoTaskCompletion({
    required Task taskToUndo,
    required double dyTop,
    required double dyBottom,
  }) async {
    if (checkAddTaskValidity(dyTop: dyTop, dyBottom: dyBottom)) {
      await updateTask(taskToUndo);
      CustomSnackbars.shortDurationSnackBar(
          contentString: "Undo task completion successful!");
    } else {
      CustomSnackbars.shortDurationSnackBar(
          contentString: "Undo task completion failed! Overlapping tasks.");
    }
  }

  Future<void> undoTaskDeletion({
    required Task taskToUndo,
    required double dyTop,
    required double dyBottom,
  }) async {
    if (checkAddTaskValidity(dyTop: dyTop, dyBottom: dyBottom)) {
      await addTask(taskToUndo);
      CustomSnackbars.shortDurationSnackBar(
          contentString: "Undo task deletion successful!");
    } else {
      CustomSnackbars.shortDurationSnackBar(
          contentString: "Undo task deletion failed! Overlapping tasks.");
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
    Utils.clearAllFormFieldFocus();
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

    // reset linked notes state provider to empty list
    ref.invalidate(linkedNotesProvider);
    
    // reser viewing note status 
    ref.invalidate(isViewingNoteProvider);

    // turn off edit mode
    ref.read(isEditingTaskProvider.notifier).state = false;

    // if task edit was successful, selectedTask should be null
    if (selectedTask == null) {
      debugPrint("currently no selected task, means no task currently editing");
      return;
    } else {
      // Add back task if edit fail.
      taskNotifier.addTask(selectedTask);
      // reset selectedTask state
      ref.read(selectedTaskProvider.notifier).state = null;
    }
  }
}
