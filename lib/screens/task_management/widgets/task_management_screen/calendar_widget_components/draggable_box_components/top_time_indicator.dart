import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/shared/widgets/styled_text.dart';
import 'package:timetailor/domain/task_management/providers/calendar_read_only_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';
import 'package:timetailor/domain/task_management/task_manager.dart';

class TopTimeIndicator extends ConsumerStatefulWidget {
  const TopTimeIndicator({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TopTimeIndicatorState();
}

class _TopTimeIndicatorState extends ConsumerState<TopTimeIndicator> {
  double calculateTopPosition({
    required double dy,
    required double textHeight,
  }) {
    final timeSlotBoundaries = ref.read(timeSlotBoundariesProvider);
    // Adjust for padding before snapping
    final adjustedDy = dy - ref.read(calendarWidgetTopBoundaryYProvider);

    // Snap position to the nearest interval
    double newDy = double.parse(((adjustedDy / ref.read(snapIntervalHeightProvider)).round() *
        ref.read(snapIntervalHeightProvider)).toStringAsFixed(2));

    // Reapply the padding offset
    newDy += ref.read(calendarWidgetTopBoundaryYProvider);

    // minor adjustments to center the text and put it inline with the line.
    final finalDy = newDy - textHeight / 2;

    
  

    return !timeSlotBoundaries.contains(newDy) ? finalDy : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final sidePadding = ref.watch(sidePaddingProvider);
    final dy = ref.watch(localDyProvider);
    final startTime =
        ref.read(tasksNotifierProvider.notifier).calculateStartTime();
    final startHour = startTime["startHour"]!;
    final startMinutes = startTime["startMinutes"]!;
    final startTimeOutput = ref.read(tasksNotifierProvider.notifier).formatTime(startHour, startMinutes);
    final textSize = TimeIndicatorText(startTimeOutput).getTextSize(context);
    final topPosition = calculateTopPosition(
      dy: dy,
      textHeight: textSize.height,
    );

    if (topPosition != 0.0) {
      return Positioned(
        left: sidePadding,
        top: topPosition,
        child: TimeIndicatorText(TaskManager.addPaddingToTime(startTimeOutput)),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
