import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/task_management/providers/calendar_local_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/scroll_controller_provider.dart';
import 'package:timetailor/domain/task_management/state/calendar_state.dart';

class TopIndicator extends ConsumerStatefulWidget {
  final double indicatorWidth;
  final double indicatorHeight;

  const TopIndicator({
    super.key,
    required this.indicatorWidth,
    required this.indicatorHeight,
  });

  @override
  ConsumerState<TopIndicator> createState() => _TopIndicatorState();
}

class _TopIndicatorState extends ConsumerState<TopIndicator> {
  

  void _handleTopDrag({
    required DragUpdateDetails details,
  }) {
    final currentCalendarState = ref.read(calendarStateNotifierProvider);
    final localDyNotifier = ref.read(localDyProvider.notifier);
    final localCurrentTimeSlotHeightNotifier =
        ref.read(localCurrentTimeSlotHeightProvider.notifier);
    final isScrolledNotifier = ref.read(isScrolledProvider.notifier);
    final localDy = ref.watch(localDyProvider);
    final localCurrentTimeSlotHeight = ref.watch(localCurrentTimeSlotHeightProvider);
    final scrollController = ref.read(scrollControllerNotifierProvider);

    final draggableBoxBottomBoundary =
        (localDy + localCurrentTimeSlotHeight);

    final minDraggableBoxSizeDy =
        draggableBoxBottomBoundary - currentCalendarState.snapIntervalHeight;

    // Adjust height and position for top resizing
    final newDy = localDy + details.delta.dy;
    final newSize = (localCurrentTimeSlotHeight - details.delta.dy)
        .clamp(currentCalendarState.snapIntervalHeight, double.infinity);

    if (newDy >= CalendarState.calendarWidgetTopBoundaryY &&
        newDy < minDraggableBoxSizeDy) {
      localDyNotifier.state = newDy;
      localCurrentTimeSlotHeightNotifier.state = newSize;
    }

    final scrollOffset = scrollController.offset;

    ref.read(maxTaskHeightProvider.notifier).state = localDy -
        CalendarState.calendarWidgetTopBoundaryY +
        localCurrentTimeSlotHeight;

    if (localDy < scrollOffset) {
      ref.read(scrollControllerNotifierProvider.notifier).startUpwardsAutoScroll();
      isScrolledNotifier.state = true;
    } else {
      ref.read(scrollControllerNotifierProvider.notifier).stopAutoScroll();
    }
  }

  void _handleTopDragEnd() {
    final currentCalendarState = ref.read(calendarStateNotifierProvider);
    final calendarStateNotifier =
        ref.read(calendarStateNotifierProvider.notifier);
    final localDyNotifier = ref.read(localDyProvider.notifier);
    final localCurrentTimeSlotHeightNotifier =
        ref.read(localCurrentTimeSlotHeightProvider.notifier);
    final localDy = ref.watch(localDyProvider);
    final localCurrentTimeSlotHeight = ref.watch(localCurrentTimeSlotHeightProvider);
    final isScrolled = ref.watch(isScrolledProvider);

    ref.read(scrollControllerNotifierProvider.notifier).stopAutoScroll();

    // scroll extra if timeslot drag caused scrolling.
    if (isScrolled) {
      ref.read(scrollControllerNotifierProvider.notifier).scrollUp(scrollAmount: currentCalendarState.defaultTimeSlotHeight);
    }

    // Adjust for padding before snapping
    final adjustedDy =
        localDy - CalendarState.calendarWidgetTopBoundaryY;

    // Snap position to the nearest interval
    double newDy =
        (adjustedDy / currentCalendarState.snapIntervalHeight).round() *
            currentCalendarState.snapIntervalHeight;

    // Reapply the padding offset
    newDy += CalendarState.calendarWidgetTopBoundaryY;

    // Snap the height directly (no adjustment needed for height)
    final newSize = (localCurrentTimeSlotHeight /
                currentCalendarState.snapIntervalHeight)
            .round() *
        currentCalendarState.snapIntervalHeight;

    // Update local state
    localDyNotifier.state = newDy;
    localCurrentTimeSlotHeightNotifier.state = newSize;

    // Update the new position and timeslot height
    calendarStateNotifier.updateDraggableBoxPosition(dy: newDy);
    calendarStateNotifier.updateCurrentTimeSlotHeight(newSize);
  }

  @override
  Widget build(BuildContext context) {
    final currentCalendarState = ref.watch(calendarStateNotifierProvider);
    final localDy = ref.watch(localDyProvider);

    return Positioned(
      left: currentCalendarState.draggableBox.dx +
          currentCalendarState.slotWidth * 0.25 -
          widget.indicatorWidth * 0.5, // Center horizontally
      top: localDy - widget.indicatorHeight / 2, // Above the top edge
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          _handleTopDrag(details: details);
        },
        onVerticalDragEnd: (_) {
          _handleTopDragEnd();
        },
        child: Container(
          width: widget.indicatorWidth,
          height: widget.indicatorHeight,
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
