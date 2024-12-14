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

    return Positioned(
      left: ref.watch(slotStartXProvider),
      top: ref.watch(localDyProvider),
      child: Container(
        width: ref.watch(slotWidthProvider), // Fixed width
        height: ref.watch(localCurrentTimeSlotHeightProvider), // Dynamically adjusted height.
        decoration: BoxDecoration(
          color: AppColors.primaryAccent.withOpacity(0.2), // Transparent background
          border: Border.all(
            color: AppColors.primaryAccent, // Border color
            width: 2.0, // Border thickness
          ),
        ),
      ),
    );
  }
}
