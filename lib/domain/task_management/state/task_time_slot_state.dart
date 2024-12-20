import 'package:timetailor/domain/task_management/state/draggable_box_state.dart';

class TaskTimeSlotState {
  final double currentTimeSlotHeight;
  final DraggableBoxState draggableBox;


  TaskTimeSlotState({
    required this.currentTimeSlotHeight,
    required this.draggableBox,
  });

  TaskTimeSlotState copyWith({
    double? currentTimeSlotHeight,
    DraggableBoxState? draggableBox,
  }) {
    return TaskTimeSlotState(
      currentTimeSlotHeight:
          currentTimeSlotHeight ?? this.currentTimeSlotHeight,
      draggableBox: draggableBox ?? this.draggableBox,
    );
  }
}
