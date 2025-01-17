import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/shared/custom_snackbars.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_read_only_provider.dart';
import 'package:timetailor/domain/task_management/providers/date_provider.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';
import 'package:timetailor/domain/task_management/task_utils.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/calendar_widget_components/calendar_painter.dart';

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
    CustomSnackbars.clearSnackBars();

    final localDyNotifier = ref.read(localDyProvider.notifier);
    final localCurrentTimeSlotHeightNotifier =
        ref.read(localCurrentTimeSlotHeightProvider.notifier);

    // if draggable box already created, reset state
    if (ref.read(showDraggableBoxProvider)) {
      ref.read(tasksNotifierProvider.notifier).endTaskCreation();
      localDyNotifier.state = 0;
      localCurrentTimeSlotHeightNotifier.state = 0;
      return;
    }

    final tapPosition = details.localPosition.dy;

    // Binary search to find the correct time slot
    int slotIndex = TaskUtils.binarySearchSlotIndex(
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

      // update local start time and end time with values from draggable box
      ref
          .read(tasksNotifierProvider.notifier)
          .updateTaskTimeStateFromDraggableBox(
            dy: ref.read(localDyProvider),
            currentTimeSlotHeight: ref.read(localCurrentTimeSlotHeightProvider),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        if (ref
            .read(currentDateNotifierProvider.notifier)
            .currentDateMoreThanEqualToday()) {
          _handleCalendarOnTapUp(details: details);
        }
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
