import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timetailor/domain/task_management/providers/calendar_read_only_provider.dart';

part 'current_time_position_provider.g.dart';

@Riverpod(keepAlive: true)
class CurrentTimePositionNotifier extends _$CurrentTimePositionNotifier {
  Timer? _timer;

  @override
  double build() {
    _startTimer();
    return _calculateCurrentTimePosition();
  }

  void _startTimer() {
    // Register cleanup
    ref.onDispose(() {
      _timer?.cancel();
    });

    // Update the position every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = _calculateCurrentTimePosition();
    });
  }

  double _calculateCurrentTimePosition() {
    final slotHeight = ref.read(defaultTimeSlotHeightProvider);
    final timeSlotBoundaries = ref.read(timeSlotBoundariesProvider);
    final indicatorYOffset = ref.read(timeIndicatorIconSizeProvider) / 2;
    final minuteInterval = slotHeight / 60;
    final now = DateTime.now();
    final slotHeightStart = timeSlotBoundaries[now.hour];
    double newIndicatorPosition = slotHeightStart - indicatorYOffset;

    // if there are minute in the current time, add the additional height of minutes
    if (now.minute != 0) {
      newIndicatorPosition += minuteInterval * now.minute;
    }

    return newIndicatorPosition;
  }
}
