import 'package:timetailor/domain/task_management/state/draggable_box_state.dart';

class CalendarState {
  final double currentTimeSlotHeight;
  final DraggableBoxState draggableBox;


  CalendarState({
    required this.currentTimeSlotHeight,
    required this.draggableBox,
  });

  CalendarState copyWith({
    double? currentTimeSlotHeight,
    DraggableBoxState? draggableBox,
  }) {
    return CalendarState(
      currentTimeSlotHeight:
          currentTimeSlotHeight ?? this.currentTimeSlotHeight,
      draggableBox: draggableBox ?? this.draggableBox,
    );
  }
}
