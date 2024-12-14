import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/domain/task_management/providers/calendar_read_only_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';
import 'package:timetailor/domain/task_management/task_manager.dart';

class BottomTimeIndicator extends ConsumerStatefulWidget {
  const BottomTimeIndicator({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BottomTimeIndicatorState();
}

class _BottomTimeIndicatorState extends ConsumerState<BottomTimeIndicator> {
  double calculateTopPosition({
    required double dyBottom,
    required double textHeight,
  }) {
    final timeSlotBoundaries = ref.read(timeSlotBoundariesProvider);
    // Adjust for padding before snapping
    final adjustedDy = dyBottom - ref.read(calendarWidgetTopBoundaryYProvider);

    // Snap position to the nearest interval
    double newDy = (adjustedDy / ref.read(snapIntervalHeightProvider)).round() *
        ref.read(snapIntervalHeightProvider);

    // Reapply the padding offset
    newDy += ref.read(calendarWidgetTopBoundaryYProvider);

    // minor adjustments to center the text and put it inline with the line.
    final finalDy = newDy - textHeight / 2;

    debugPrint("finalDy: $finalDy");

    return !timeSlotBoundaries.contains(newDy) ? finalDy : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final sidePadding = ref.watch(sidePaddingProvider);
    final dyBottom = ref.watch(localDyBottomProvider);
    final endTime =
        ref.read(tasksNotifierProvider.notifier).calculateEndTime();
    final endHour = endTime["endHour"]!;
    final endMinutes = endTime["endMinutes"]!;
    final endTimeOutput = ref
        .read(tasksNotifierProvider.notifier)
        .formatTime(endHour, endMinutes);
    final textSize = TimeIndicatorText(endTimeOutput).getTextSize(context);
    final topPosition = calculateTopPosition(
      dyBottom: dyBottom,
      textHeight: textSize.height,
    );

    debugPrint("endTime: $endTimeOutput");
    debugPrint("dyTop: ${ref.read(localDyProvider)}");
    debugPrint("currentHeight: ${ref.read(localCurrentTimeSlotHeightProvider)}");
    debugPrint("dyBottom: $dyBottom");

    // only print if it is not the main time slot.
    if (topPosition != 0.0) {
      return Positioned(
        left: sidePadding,
        top: topPosition,
        child: TimeIndicatorText(TaskManager.addPaddingToTime(endTimeOutput)),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
