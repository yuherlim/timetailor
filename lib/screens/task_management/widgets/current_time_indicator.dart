import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/state/calendar_state.dart';

class CurrentTimeIndicator extends ConsumerStatefulWidget {
  const CurrentTimeIndicator({
    super.key,
  });

  @override
  ConsumerState<CurrentTimeIndicator> createState() =>
      _CurrentTimeIndicatorState();
}

class _CurrentTimeIndicatorState extends ConsumerState<CurrentTimeIndicator> {
  late double topPosition;
  Timer? _timer;
  double calendarHeight = 0;
  double calendarWidgetTopPadding = CalendarState.calendarWidgetTopBoundaryY;
  static const double timeIndicatorIconSize = 8;
  static const timeIndicatorStartY = timeIndicatorIconSize * 0.5;

  @override
  void initState() {
    _calculateCurrentTimePosition();

    // Wait for widget to finish building before fetching these values.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentCalendarState = ref.read(calendarStateNotifierProvider);
      calendarHeight = currentCalendarState.calendarHeight;

      print("=========================");
      print("debugging time indicator");
      print("=========================");

      print("calendar Height: $calendarHeight");
      print(
          "calendar bottom boundary: ${currentCalendarState.calendarWidgetBottomBoundaryY}");
    });

    // Update the position every minute
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateCurrentTimePosition();
    });
    super.initState();
  }

  void _calculateCurrentTimePosition() {
    final now = DateTime.now();

    // Total seconds passed since midnight
    final totalSeconds = now.hour * 3600 + now.minute * 60 + now.second;

    // Total seconds in a day (24 hours)
    const totalSecondsInDay = 24 * 3600;

    // Calculate the fraction of the day passed
    final fractionOfDay = totalSeconds / totalSecondsInDay;

    // Calculate the top position
    final newTopPosition = fractionOfDay * calendarHeight;

    setState(() {
      // account for calendarWidgetTopPadding and timeIndicatorStartY offset
      topPosition =
          newTopPosition + calendarWidgetTopPadding - timeIndicatorStartY;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentCalendarState = ref.watch(calendarStateNotifierProvider);

    // time indicator position
    final screenWidth = MediaQuery.of(context).size.width;
    final indicatorSidePadding = currentCalendarState.sidePadding;
    final textPadding = currentCalendarState.textPadding;
    final timeIndicatorStartX = indicatorSidePadding +
        screenWidth * 0.1 +
        textPadding -
        timeIndicatorIconSize * 0.5;

    return Positioned(
      top: topPosition, // Dynamically calculate this position
      left: timeIndicatorStartX,
      right: 0,
      child: Row(
        children: [
          Container(
            width: timeIndicatorIconSize, // Diameter of the circle
            height: timeIndicatorIconSize,
            decoration: BoxDecoration(
              color: AppColors.timeIndicatorColor, // Color of the circle
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Divider(
              color: AppColors.timeIndicatorColor,
              thickness: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
