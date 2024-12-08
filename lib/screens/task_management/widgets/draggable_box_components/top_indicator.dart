import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';

class TopIndicator extends ConsumerWidget {
  final double indicatorWidth;
  final double indicatorHeight;
  final double localDy;
  final double localCurrentTimeSlotHeight;
  final void Function({required DragUpdateDetails details}) onDragUpdate;
  final VoidCallback onDragEnd;

  const TopIndicator({
    super.key,
    required this.indicatorWidth,
    required this.indicatorHeight,
    required this.localDy,
    required this.localCurrentTimeSlotHeight,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCalendarState = ref.read(calendarStateNotifierProvider);

    return Positioned(
      left: currentCalendarState.draggableBox.dx +
          currentCalendarState.slotWidth * 0.25 -
          indicatorWidth * 0.5, // Center horizontally
      top: localDy - indicatorHeight / 2, // Above the top edge
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          onDragUpdate(details: details);
        },
        onVerticalDragEnd: (_) {
          onDragEnd();
        },
        child: Container(
          width: indicatorWidth,
          height: indicatorHeight,
          decoration: BoxDecoration(
            color: AppColors.primaryAccent,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Center(
            child: Icon(
              Icons.arrow_upward,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}