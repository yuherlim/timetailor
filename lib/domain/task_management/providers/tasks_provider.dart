import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timetailor/data/task_management/models/task.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_read_only_provider.dart';
import 'package:timetailor/domain/task_management/providers/date_provider.dart';

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

  List<Task>? getAllCompletedTasksForCurrentDate() {
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

  // these methods are to be converted to use firestore later.

  //fetchTasksOnce

  bool checkAddTaskValidity({
    required double dyTop,
    required double dyBottom,
  }) {
    return !state.any(
      (task) {
        final taskDimensions = calculateTimeSlotFromTaskTime(
            startTime: task.startTime, endTime: task.endTime);
        final taskDyTop = taskDimensions['dyTop']!;
        final taskDyBottom = taskDimensions['dyBottom']!;

        // Check if the current task overlaps with any existing uncompleted task
        return dyBottom > taskDyTop && dyTop < taskDyBottom && !task.isCompleted;
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

  void cancelTaskCreation() {
    // reset draggableBox show state
    ref.read(showDraggableBoxProvider.notifier).state = false;
  }
}
