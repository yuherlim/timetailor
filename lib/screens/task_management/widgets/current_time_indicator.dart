import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';

class CurrentTimeIndicator extends ConsumerStatefulWidget {
  final void Function({required double position}) scrollToCurrentTimeIndicator;

  const CurrentTimeIndicator({
    super.key,
    required this.scrollToCurrentTimeIndicator,
  });

  @override
  ConsumerState<CurrentTimeIndicator> createState() =>
      _CurrentTimeIndicatorState();
}

class _CurrentTimeIndicatorState extends ConsumerState<CurrentTimeIndicator> {
  double topPosition = 0;
  Timer? _timer;
  static const double timeIndicatorIconSize = 8;

  @override
  void initState() {
    // _calculateCurrentTimePosition();

    // Initial setup after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateCurrentTimePosition();
      widget.scrollToCurrentTimeIndicator(position: topPosition);
    });


    // Update the position every minute
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateCurrentTimePosition();
    });
    super.initState();
  }

  void _calculateCurrentTimePosition() {
    final currentCalendarState = ref.read(calendarStateNotifierProvider);
    final slotHeight = currentCalendarState.defaultTimeSlotHeight;
    final timeSlotBoundaries = currentCalendarState.timeSlotBoundaries;
    const indicatorYOffset = timeIndicatorIconSize / 2;
    final minuteInterval = slotHeight / 60;
    final now = DateTime.now();
    final slotHeightStart = timeSlotBoundaries[now.hour];
    double newIndicatorPosition = slotHeightStart - indicatorYOffset;

    // if there are minute in the current time, add the additional height of minutes
    if (now.minute != 0) {
      newIndicatorPosition += minuteInterval * now.minute;
    }

    setState(() {
      topPosition = newIndicatorPosition;
    });

    // print("=========================");
    // print("debugging time indicator position");
    // print("=========================");

    // print("defaultSlotHeight: ${currentCalendarState.defaultTimeSlotHeight}");
    // print("calendarHeight: ${currentCalendarState.calendarHeight}");
    // print("timeSlotBoundaries: ${currentCalendarState.timeSlotBoundaries}");
    // print(
    //     "calendar bottom boundary: ${currentCalendarState.calendarWidgetBottomBoundaryY}");
    // print("currentTime: ${now.toString()}");
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
            child: Padding(
              padding: EdgeInsets.only(right: indicatorSidePadding),
              child: SizedBox(
                height: timeIndicatorIconSize,
                child: Divider(
                  color: AppColors.timeIndicatorColor,
                  thickness: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
