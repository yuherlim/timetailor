import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/domain/task_management/providers/calendar_read_only_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';

class DraggingStatusIndicator extends ConsumerWidget {
  final bool isTopDraggingIndicator;

  const DraggingStatusIndicator(
      {super.key, required this.isTopDraggingIndicator});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotStartX = ref.watch(slotStartXProvider);
    final slotWidth = ref.watch(slotWidthProvider);
    final dy = ref.watch(localDyProvider);
    final dyBottom = ref.watch(localDyBottomProvider);
    const draggingOutput = "Dragging...";
    final textSize =
        const TimeIndicatorText(draggingOutput).getTextSize(context);
    final topPosition =
        isTopDraggingIndicator ? dy : dyBottom - textSize.height;
    final leftPosition = slotStartX + slotWidth / 2 - textSize.width / 2;
    final isDragging = ref.watch(isDraggableBoxLongPressedProvider);
    final draggableBoxSizeIsSmall = ref.watch(dragIndicatorHeightProvider) <
        ref.watch(snapIntervalHeightProvider) * 6;
    final isTaskNotOverlapping = ref
        .read(tasksNotifierProvider.notifier)
        .checkAddTaskValidity(dyTop: dy, dyBottom: dyBottom);

    if (isDragging && draggableBoxSizeIsSmall && !isTaskNotOverlapping && isTopDraggingIndicator) {
      return const SizedBox.shrink();
    } else if (isDragging) {
      return Positioned(
        left: leftPosition,
        top: !draggableBoxSizeIsSmall
            ? topPosition
            : isTopDraggingIndicator
                ? topPosition - 32
                : topPosition + 32,
        child: const TimeIndicatorText(draggingOutput),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
