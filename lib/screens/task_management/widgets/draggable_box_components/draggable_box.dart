import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';

class DraggableBox extends ConsumerStatefulWidget {

  const DraggableBox({super.key});

  @override
  ConsumerState<DraggableBox> createState() => _DraggableBoxState();
}

class _DraggableBoxState extends ConsumerState<DraggableBox> {

  @override
  Widget build(BuildContext context) {

    return // draggable box
        Positioned(
      left: ref.watch(calendarStateNotifierProvider).draggableBox.dx,
      top: ref.watch(calendarStateNotifierProvider).draggableBox.dy,
      child: Container(
        width: ref.watch(calendarStateNotifierProvider).slotWidth, // Fixed width
        height: ref.watch(calendarStateNotifierProvider).currentTimeSlotHeight, // Dynamically adjusted height.
        decoration: BoxDecoration(
          color: Colors.transparent, // Transparent background
          border: Border.all(
            color: AppColors.primaryAccent, // Border color
            width: 2.0, // Border thickness
          ),
        ),
      ),
    );
  }
}
