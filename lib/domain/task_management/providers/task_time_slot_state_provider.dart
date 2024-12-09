import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timetailor/domain/task_management/state/task_time_slot_state.dart';
import 'package:timetailor/domain/task_management/state/draggable_box_state.dart';

part 'task_time_slot_state_provider.g.dart'; // Generated file

@riverpod
class TaskTimeSlotStateNotifier extends _$TaskTimeSlotStateNotifier {
  @override
  TaskTimeSlotState build() {
    return TaskTimeSlotState(
      currentTimeSlotHeight: 0,
      draggableBox: DraggableBoxState(dx: 0, dy: 0),
    );
  }

  void updateCurrentTimeSlotHeight(double height) {
    state = state.copyWith(currentTimeSlotHeight: height);
  }

  void updateDraggableBoxPosition({double? dx, double? dy}) {
    state = state.copyWith(
      draggableBox: state.draggableBox.copyWith(
        dx: dx,
        dy: dy,
      ),
    );
  }
}
