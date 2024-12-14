import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/domain/task_management/providers/calendar_read_only_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';

class BottomDurationIndicator extends ConsumerStatefulWidget {
  const BottomDurationIndicator({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BottomDurationIndicatorState();
}

class _BottomDurationIndicatorState
    extends ConsumerState<BottomDurationIndicator> {
  @override
  Widget build(BuildContext context) {
    ref.watch(localCurrentTimeSlotHeightProvider);
    final durationOutput =
        ref.read(tasksNotifierProvider.notifier).durationIndicatorString();
    final textSize = TimeIndicatorText(durationOutput).getTextSize(context);
    final slotStartX = ref.read(slotStartXProvider);
    final slotWidth = ref.read(slotWidthProvider);
    final dyBottom = ref.watch(localDyBottomProvider);
    final leftPosition = slotStartX + slotWidth * 0.25 - textSize.width / 2;
    final topPosition = dyBottom;
    final draggableBoxSizeIsSmall = ref.watch(dragIndicatorHeightProvider) <
        ref.watch(snapIntervalHeightProvider) * 2;

    return Positioned(
      left: leftPosition,
      top: !draggableBoxSizeIsSmall ? topPosition : topPosition - 8,
      child: TimeIndicatorText(durationOutput),
    );
  }
}
