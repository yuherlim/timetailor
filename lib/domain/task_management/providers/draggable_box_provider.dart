import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timetailor/domain/task_management/state/draggable_box_state.dart';

part 'draggable_box_provider.g.dart'; // Generated file

@riverpod
class DraggableBoxNotifier extends _$DraggableBoxNotifier {
  @override
  DraggableBoxState build() {
    return DraggableBoxState(
      dx: 0,
      dy: 0,
      currentTimeSlotHeight: 0,
    );
  }

  void updateDraggableBoxPosition({double? dx, double? dy}) {
    state = state.copyWith(
      dx: dx,
      dy: dy,
    );
  }
}
