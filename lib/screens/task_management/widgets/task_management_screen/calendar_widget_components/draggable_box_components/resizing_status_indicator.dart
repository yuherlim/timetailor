import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/domain/task_management/providers/calendar_read_only_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';

class ResizingStatusIndicator extends ConsumerWidget {
  final bool isTopResizingIndicator;

  const ResizingStatusIndicator({super.key, required this.isTopResizingIndicator});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotStartX = ref.watch(slotStartXProvider);
    final slotWidth = ref.watch(slotWidthProvider);
    final dy = ref.watch(localDyProvider);
    final dyBottom = ref.watch(localDyBottomProvider);
    const resizingOutput = "Resizing...";
    final textSize = const TimeIndicatorText(resizingOutput).getTextSize(context);
    final topPosition = isTopResizingIndicator ? dy: dyBottom - textSize.height;
    final leftPosition = slotStartX + slotWidth / 2 - textSize.width / 2;
    final isResizing = ref.watch(isResizingProvider);
    final draggableBoxSizeIsSmall = ref.watch(dragIndicatorHeightProvider) <
    ref.watch(snapIntervalHeightProvider) * 6;

    if (isResizing) {
      return Positioned(
        left: leftPosition,
        top: !draggableBoxSizeIsSmall ? topPosition : isTopResizingIndicator ? topPosition - 32 : topPosition + 32,
        child: const TimeIndicatorText(resizingOutput),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}