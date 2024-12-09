import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timetailor/data/task_management/models/task.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_read_only_provider.dart';

part 'tasks_provider.g.dart'; // Generated file

@riverpod
class TasksNotifier extends _$TasksNotifier {
  @override
  List<Task> build() {
    return tasks;
  }

  void addTask(Task task) {
    state = [...state, task];
  }

  void updateTask(Task task) {
    state = state.map((currentTask) {
      // Replace the task with the updatedTask if the IDs match
      return task.id == currentTask.id ? task : currentTask;
    }).toList();
  }

  void removeTask(Task task) {
    state = state.where((currentTask) => currentTask != task).toList();
  }

  // these methods are to be converted to use firestore later.

  //fetchTasksOnce

  // Converts dy and height into start and end times.
  void updateTaskTimeStateFromDraggableBox({
    required double dy,
    required double currentTimeSlotHeight,
  }) {
    // Fetch required providers
    final defaultTimeSlotHeight = ref.read(defaultTimeSlotHeightProvider);
    final snapIntervalMinutes = ref.read(snapIntervalMinutesProvider);
    final snapIntervalHeight = ref.read(snapIntervalHeightProvider);
    final calendarWidgetTopBoundaryY =
        ref.read(calendarWidgetTopBoundaryYProvider);
    final localDy = dy;
    final localCurrentTimeSlotHeight = currentTimeSlotHeight;

    // Calculate start time
    double topOffsetFromCalendarStart = localDy - calendarWidgetTopBoundaryY;
    int startHour = (topOffsetFromCalendarStart ~/ defaultTimeSlotHeight);
    int startMinutes = ((topOffsetFromCalendarStart % defaultTimeSlotHeight) /
                snapIntervalHeight)
            .round() *
        snapIntervalMinutes as int;

    // Calculate duration in minutes
    int durationMinutes =
        (localCurrentTimeSlotHeight / snapIntervalHeight).round() *
            snapIntervalMinutes as int;

    // Calculate end time
    int endHour = startHour + (durationMinutes ~/ 60);
    int endMinutes = startMinutes + (durationMinutes % 60);

    // Format as "HH:MM AM/PM"
    String formatTime(int hour, int minutes) {
      final period = hour >= 12 ? 'PM' : 'AM';
      final normalizedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final paddedMinutes = minutes.toString().padLeft(2, '0');
      return '$normalizedHour:$paddedMinutes $period';
    }

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
}
