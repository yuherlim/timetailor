import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';

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

    return Positioned(
      left: slotStartX,
      top: localDy,
      child: Container(
        width: slotWidth,// Fixed width
        height: localCurrentTimeSlotHeight, // Dynamically adjusted height.
        decoration: BoxDecoration(
          color: AppColors.primaryAccent.withOpacity(0.2),
          border: Border.all(
            color: AppColors.primaryAccent, // Border color
            width: 2.0, // Border thickness
          ),
        ),
      ),
    );
  }
}
