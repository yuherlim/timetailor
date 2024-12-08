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
