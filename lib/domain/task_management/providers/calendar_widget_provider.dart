import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calendar_widget_provider.g.dart'; // Generated file

@riverpod
class SlotStartXNotifier extends _$SlotStartXNotifier {
  @override
  double build() {
    return 0;
  }

  void updateSlotStartX(double slotStartX) {
    state = slotStartX;
  }
}

@riverpod
class SlotWidthNotifier extends _$SlotWidthNotifier {
  @override
  double build() {
    return 0;
  }

  void updateSlotWidth(double slotWidth) {
    state = slotWidth;
  }
}
