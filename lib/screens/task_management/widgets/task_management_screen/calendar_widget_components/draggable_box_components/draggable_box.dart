import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';

class DraggableBox extends ConsumerWidget {

  const DraggableBox({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotStartX = ref.watch(slotStartXProvider);
    final slotWidth = ref.watch(slotWidthProvider);
    final localDy = ref.watch(localDyProvider);
    final localCurrentTimeSlotHeight = ref.watch(localCurrentTimeSlotHeightProvider);
    final localDyBottom = ref.watch(localDyBottomProvider);
    final isTaskNotOverlapping = ref
        .read(tasksNotifierProvider.notifier)
        .checkAddTaskValidity(dyTop: localDy, dyBottom: localDyBottom);

    debugPrint("dyTop: $localDy, dyBottom: $localDyBottom, height: $localCurrentTimeSlotHeight");

    return Positioned(
      left: slotStartX,
      top: localDy,
      child: Container(
        width: slotWidth,// Fixed width
        height: localCurrentTimeSlotHeight, // Dynamically adjusted height.
        decoration: BoxDecoration(
          // color: AppColors.primaryColor.withOpacity(0.2),
          color: Colors.transparent,
          border: Border.all(
            color: isTaskNotOverlapping ? AppColors.primaryAccent : Colors.red, // Border color
            width: 2.0, // Border thickness
          ),
        ),
      ),
    );
  }
}
