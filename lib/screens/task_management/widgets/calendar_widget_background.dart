import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/domain/task_management/providers/calendar_local_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/screens/task_management/widgets/calendar_painter.dart';

class CalendarWidgetBackground extends ConsumerStatefulWidget {
  final BuildContext context; // Add BuildContext
  final double slotHeight;
  final double snapInterval;
  final double bottomPadding;
  final double topPadding;

  const CalendarWidgetBackground({
    super.key,
    required this.context,
    required this.slotHeight,
    required this.snapInterval,
    required this.bottomPadding,
    required this.topPadding,
  });

  @override
  ConsumerState<CalendarWidgetBackground> createState() =>
      _CalendarWidgetBackgroundState();
}

class _CalendarWidgetBackgroundState
    extends ConsumerState<CalendarWidgetBackground> {
  void _handleCalendarOnTapUp({
    required TapUpDetails details,
  }) {
    final currentCalendarState = ref.read(calendarStateNotifierProvider);
    final calendarStateNotifier =
        ref.read(calendarStateNotifierProvider.notifier);
    final localDyNotifier = ref.read(localDyProvider.notifier);
    final localCurrentTimeSlotHeightNotifier =
        ref.read(localCurrentTimeSlotHeightProvider.notifier);

    // if draggable box already created, reset state
    if (currentCalendarState.showDraggableBox) {
      calendarStateNotifier
          .toggleDraggableBox(!currentCalendarState.showDraggableBox);

      localDyNotifier.state = 0;
      localCurrentTimeSlotHeightNotifier.state = 0;

      return;
    }

    final tapPosition = details.localPosition.dy;

    // Binary search to find the correct time slot
    int slotIndex = binarySearchSlotIndex(
        tapPosition, currentCalendarState.timeSlotBoundaries);

    // Handle case where the tap is after the last slot
    if (slotIndex == -1 &&
        tapPosition >= currentCalendarState.timeSlotBoundaries.last) {
      slotIndex = currentCalendarState.timeSlotBoundaries.length - 1;
    }

    // Snap to the correct time slot
    if (slotIndex != -1) {
      // update local state
      localDyNotifier.state = currentCalendarState.timeSlotBoundaries[slotIndex];
      localCurrentTimeSlotHeightNotifier.state = currentCalendarState.defaultTimeSlotHeight;

      calendarStateNotifier.updateDraggableBoxPosition(
        dx: currentCalendarState.slotStartX,
        dy: currentCalendarState.timeSlotBoundaries[slotIndex],
      );
      calendarStateNotifier.updateCurrentTimeSlotHeight(
          currentCalendarState.defaultTimeSlotHeight); // Reset height
      calendarStateNotifier.toggleDraggableBox(true);
    }
  }

  int binarySearchSlotIndex(
    double tapPosition,
    List<double> timeSlotBoundaries,
  ) {
    int low = 0;
    int high = timeSlotBoundaries.length - 1;
    int slotIndex = -1;

    while (low <= high) {
      int mid = (low + high) ~/ 2;

      if (mid < timeSlotBoundaries.length - 1 &&
          tapPosition >= timeSlotBoundaries[mid] &&
          tapPosition < timeSlotBoundaries[mid + 1]) {
        slotIndex = mid; // Found the slot
        break;
      } else if (tapPosition < timeSlotBoundaries[mid]) {
        high = mid - 1; // Search in the left half
      } else {
        low = mid + 1; // Search in the right half
      }
    }
    return slotIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> timePeriods = [
      '12 AM',
      ' 1 AM',
      ' 2 AM',
      ' 3 AM',
      ' 4 AM',
      ' 5 AM',
      ' 6 AM',
      ' 7 AM',
      ' 8 AM',
      ' 9 AM',
      '10 AM',
      '11 AM',
      '12 PM',
      ' 1 PM',
      ' 2 PM',
      ' 3 PM',
      ' 4 PM',
      ' 5 PM',
      ' 6 PM',
      ' 7 PM',
      ' 8 PM',
      ' 9 PM',
      '10 PM',
      '11 PM'
    ];

    // Calculate the total height for 24 slots
    double calendarHeight = timePeriods.length * widget.slotHeight;

    return GestureDetector(
      onTapUp: (details) {
        _handleCalendarOnTapUp(details: details);
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: widget.bottomPadding),
        child: CustomPaint(
          size: Size(double.infinity, calendarHeight),
          painter: CalendarPainter(
            timePeriods: timePeriods,
            slotHeight: widget.slotHeight,
            snapInterval: widget.snapInterval,
            context: context,
            topPadding: widget.topPadding,
            onSlotCalendarPainted: (
                {required slotStartX,
                required slotWidth,
                required sidePadding,
                required textPadding}) {
              // Delay the update to avoid lifecycle issues
              Future.microtask(() {
                // update the states.
                ref
                    .read(calendarStateNotifierProvider.notifier)
                    .updateSlotStartX(slotStartX);
                ref
                    .read(calendarStateNotifierProvider.notifier)
                    .updateSlotWidth(slotWidth);
                ref
                    .read(calendarStateNotifierProvider.notifier)
                    .updateSidePadding(sidePadding);
                ref
                    .read(calendarStateNotifierProvider.notifier)
                    .updateTextPadding(textPadding);
              });
            },
          ),
        ),
      ),
    );
  }
}
