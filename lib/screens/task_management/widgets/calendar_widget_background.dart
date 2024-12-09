import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/domain/task_management/providers/calendar_local_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_read_only_provider.dart';
import 'package:timetailor/domain/task_management/task_manager.dart';
import 'package:timetailor/screens/task_management/widgets/calendar_painter.dart';

class CalendarWidgetBackground extends ConsumerStatefulWidget {
  const CalendarWidgetBackground({
    super.key,
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
    final localDyNotifier = ref.read(localDyProvider.notifier);
    final localCurrentTimeSlotHeightNotifier =
        ref.read(localCurrentTimeSlotHeightProvider.notifier);

    // if draggable box already created, reset state
    if (ref.read(showDraggableBoxProvider)) {
      ref.read(showDraggableBoxProvider.notifier).state =
          !ref.read(showDraggableBoxProvider);
      localDyNotifier.state = 0;
      localCurrentTimeSlotHeightNotifier.state = 0;
      return;
    }

    final tapPosition = details.localPosition.dy;

    // Binary search to find the correct time slot
    int slotIndex = TaskManager.binarySearchSlotIndex(
        tapPosition, ref.read(timeSlotBoundariesProvider));

    // Handle case where the tap is after the last slot
    if (slotIndex == -1 &&
        tapPosition >= ref.read(timeSlotBoundariesProvider).last) {
      slotIndex = ref.read(timeSlotBoundariesProvider).length - 1;
    }

    // Snap to the correct time slot
    if (slotIndex != -1) {
      // update local state
      localDyNotifier.state = ref.read(timeSlotBoundariesProvider)[slotIndex];
      localCurrentTimeSlotHeightNotifier.state =
          ref.read(defaultTimeSlotHeightProvider);
      ref.read(showDraggableBoxProvider.notifier).state = true;
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        _handleCalendarOnTapUp(details: details);
      },
      child: Padding(
        padding:
            EdgeInsets.only(bottom: ref.watch(calendarBottomPaddingProvider)),
        child: CustomPaint(
          size: Size(double.infinity, ref.watch(calendarHeightProvider)),
          painter: CalendarPainter(
            timePeriods: ref.watch(timePeriodsProvider),
            slotHeight: ref.watch(defaultTimeSlotHeightProvider),
            snapInterval: ref.watch(snapIntervalHeightProvider),
            context: context,
            topPadding: ref.watch(calendarWidgetTopBoundaryYProvider),
            onSlotCalendarPainted: (
                {required slotStartX,
                required slotWidth,
                required sidePadding,
                required textPadding}) {
              // update the states.
              // WidgetsBinding.instance.addPostFrameCallback((_) {

              // });
              Future.microtask(() {
                ref.read(slotStartXProvider.notifier).state = slotStartX;
                ref.read(slotWidthProvider.notifier).state = slotWidth;
                ref.read(sidePaddingProvider.notifier).state = sidePadding;
                ref.read(textPaddingProvider.notifier).state = textPadding;
              });
            },
          ),
        ),
      ),
    );
  }
}
