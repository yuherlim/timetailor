import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timetailor/domain/task_management/state/calendar_state.dart';
import 'package:timetailor/domain/task_management/state/draggable_box_state.dart';

part 'calendar_state_provider.g.dart'; // Generated file

@riverpod
class CalendarStateNotifier extends _$CalendarStateNotifier {
  @override
  CalendarState build() {
    return CalendarState(
      currentTimeSlotHeight: 0,
      defaultTimeSlotHeight: 0,
      pixelsPerMinute: 0,
      snapInterval: 0,
      draggableBox: DraggableBoxState(dx: 0, dy: 0),
      showDraggableBox: false,
      timeSlotBoundaries: [],
      maxTaskHeight: 0,
      calendarWidgetBottomBoundaryY: 0,
      calendarHeight: 0,
      slotStartX: 0,
      slotWidth: 0,
    );
  }

  void updateCurrentTimeSlotHeight(double height) {
    state = state.copyWith(currentTimeSlotHeight: height);
  }

  void updateDefaultTimeSlotHeight(double height) {
    state = state.copyWith(defaultTimeSlotHeight: height);
  }

  void updatePixelsPerMinute(double pixelsPerMinute) {
    state = state.copyWith(pixelsPerMinute: pixelsPerMinute);
  }

  void updateSnapInterval(double snapInterval) {
    state = state.copyWith(snapInterval: snapInterval);
  }

  void updateDraggableBoxPosition({double? dx, double? dy}) {
    state = state.copyWith(
      draggableBox: state.draggableBox.copyWith(
        dx: dx,
        dy: dy,
      ),
    );
  }

  void toggleDraggableBox(bool value) {
    state = state.copyWith(showDraggableBox: value);
  }

  void updateTimeSlotBoundaries(List<double> timeSlotBoundaries) {
    state = state.copyWith(timeSlotBoundaries: timeSlotBoundaries);
  }

  void updateMaxTaskHeight(double height) {
    state = state.copyWith(maxTaskHeight: height);
  }

  void updateCalendarWidgetBottomBoundaryY(double calendarWidgetBottomBoundaryY) {
    state = state.copyWith(calendarWidgetBottomBoundaryY: calendarWidgetBottomBoundaryY);
  }

  void updateCalendarHeight(double calendarHeight) {
    state = state.copyWith(calendarHeight: calendarHeight);
  }

  void updateSlotStartX(double slotStartX) {
    state = state.copyWith(slotStartX: slotStartX);
  }

  void updateSlotWidth(double slotWidth) {
    state = state.copyWith(slotWidth: slotWidth);
  }
}
