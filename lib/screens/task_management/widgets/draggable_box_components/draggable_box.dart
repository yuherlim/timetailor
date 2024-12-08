import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';

class DraggableBox extends ConsumerWidget {
  final double localCurrentTimeSlotHeight;

  const DraggableBox({
    super.key,
    required this.localCurrentTimeSlotHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCalendarState = ref.watch(calendarStateNotifierProvider);

    return Container(
      width: currentCalendarState.slotWidth, // Fixed width
      height: localCurrentTimeSlotHeight, // Dynamically adjusted height.
      decoration: BoxDecoration(
        color: Colors.transparent, // Transparent background
        border: Border.all(
          color: AppColors.primaryAccent, // Border color
          width: 2.0, // Border thickness
        ),
      ),
    );
  }
}
