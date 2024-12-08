import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/task_management/providers/calendar_local_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/state/calendar_state.dart';

class TopIndicator extends ConsumerStatefulWidget {
  final double indicatorWidth;
  final double indicatorHeight;
  final ScrollController scrollController;

  const TopIndicator({
    super.key,
    required this.indicatorWidth,
    required this.indicatorHeight,
    required this.scrollController,
  });

  @override
  ConsumerState<TopIndicator> createState() => _TopIndicatorState();
}

class _TopIndicatorState extends ConsumerState<TopIndicator> {
  Timer? _scrollTimer;

  void _handleTopDrag({
    required DragUpdateDetails details,
  }) {
    final currentCalendarState = ref.read(calendarStateNotifierProvider);
    final calendarStateNotifier =
        ref.read(calendarStateNotifierProvider.notifier);
    final localDyNotifier = ref.read(localDyProvider.notifier);
    final localCurrentTimeSlotHeightNotifier =
        ref.read(localCurrentTimeSlotHeightProvider.notifier);
    final isScrolledNotifier = ref.read(isScrolledProvider.notifier);
    final localDy = ref.watch(localDyProvider);
    final localCurrentTimeSlotHeight = ref.watch(localCurrentTimeSlotHeightProvider);

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

    final scrollOffset = widget.scrollController.offset;

    calendarStateNotifier.updateMaxTaskHeight(localDy -
        CalendarState.calendarWidgetTopBoundaryY +
        localCurrentTimeSlotHeight);

    if (localDy < scrollOffset) {
      _startUpwardsAutoScroll();
      isScrolledNotifier.state = true;
    } else {
      _stopAutoScroll();
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

    _stopAutoScroll();

    // scroll extra if timeslot drag caused scrolling.
    if (isScrolled) {
      scrollUp(scrollAmount: currentCalendarState.defaultTimeSlotHeight);
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

  void scrollUp({required double scrollAmount}) {
    final isScrolledNotifier = ref.read(isScrolledProvider.notifier);
    // reset isScrolled state
    isScrolledNotifier.state = false;

    // perform extra scrolling
    final scrollOffset = widget.scrollController.offset;
    if (scrollOffset > 0) {
      widget.scrollController.animateTo(
        (scrollOffset - scrollAmount).clamp(0.0, double.infinity),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _startUpwardsAutoScroll() {
    const double scrollAmount = 15;

    final currentCalendarState = ref.read(calendarStateNotifierProvider);
    final calendarStateNotifier =
        ref.read(calendarStateNotifierProvider.notifier);
    final localDyNotifier = ref.read(localDyProvider.notifier);
    final localCurrentTimeSlotHeightNotifier =
        ref.read(localCurrentTimeSlotHeightProvider.notifier);
    final localDy = ref.watch(localDyProvider);
    final localCurrentTimeSlotHeight = ref.watch(localCurrentTimeSlotHeightProvider);

    _stopAutoScroll(); // Stop any ongoing scroll
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final currentOffset = widget.scrollController.offset;

      if (currentOffset > 0.0) {
        widget.scrollController.jumpTo(
          max(0.0, (currentOffset - scrollAmount)), // Scroll up
        );
        final newDy = max(CalendarState.calendarWidgetTopBoundaryY,
            (localDy - scrollAmount));
        final newSize = (localCurrentTimeSlotHeight + scrollAmount)
            .clamp(currentCalendarState.snapIntervalHeight,
                currentCalendarState.maxTaskHeight);

        // update local state
        localDyNotifier.state = newDy;
        localCurrentTimeSlotHeightNotifier.state = newSize;

        calendarStateNotifier.updateDraggableBoxPosition(dy: newDy);
        calendarStateNotifier.updateCurrentTimeSlotHeight(newSize);
      } else {
        _stopAutoScroll(); // Stop scrolling if we reach the end
      }
    });
  }

  void _stopAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
  }

  @override
  void dispose() {
    // Clean up
    _stopAutoScroll();
    super.dispose();
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
