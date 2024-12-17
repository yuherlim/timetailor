import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/domain/task_management/providers/calendar_read_only_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';

class OverlappingStatusIndicator extends ConsumerWidget {
  const OverlappingStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotStartX = ref.watch(slotStartXProvider);
    final slotWidth = ref.watch(slotWidthProvider);
    final dy = ref.watch(localDyProvider);
    const resizingOutput = "Overlapping...";
    final textSize =
        const TimeIndicatorText(resizingOutput).getTextSize(context);
    final leftPosition = slotStartX + slotWidth / 2 - textSize.width / 2;
    final topPosition = dy - textSize.height;
    final dyBottom = ref.watch(localDyBottomProvider);
    final isTaskNotOverlapping = ref
        .read(tasksNotifierProvider.notifier)
        .checkAddTaskValidity(dyTop: dy, dyBottom: dyBottom);
    final draggableBoxSizeIsSmall = ref.watch(dragIndicatorHeightProvider) <
        ref.watch(snapIntervalHeightProvider) * 6;

    if (!isTaskNotOverlapping) {
      return Positioned(
        left: leftPosition,
        top: !draggableBoxSizeIsSmall ? topPosition : topPosition - 16,
        child: const TimeIndicatorText(resizingOutput),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
