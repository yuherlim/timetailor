import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/task_management/providers/calendar_local_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/scroll_controller_provider.dart';

class BottomIndicator extends ConsumerStatefulWidget {
  final double indicatorWidth;
  final double indicatorHeight;

  const BottomIndicator({
    super.key,
    required this.indicatorWidth,
    required this.indicatorHeight,
  });

  @override
  ConsumerState<BottomIndicator> createState() => _BottomIndicatorState();
}

class _BottomIndicatorState extends ConsumerState<BottomIndicator> {
  void _handleBottomDrag({
    required DragUpdateDetails details,
  }) {
    final currentCalendarState = ref.read(calendarStateNotifierProvider);
    final localCurrentTimeSlotHeightNotifier =
        ref.read(localCurrentTimeSlotHeightProvider.notifier);
    final isScrolledNotifier = ref.read(isScrolledProvider.notifier);
    final localDy = ref.watch(localDyProvider);
    final localCurrentTimeSlotHeight =
        ref.watch(localCurrentTimeSlotHeightProvider);
    final scrollController = ref.read(scrollControllerNotifierProvider);

    // Get the scroll offset of the calendar
    final scrollOffset = scrollController.offset;
    final remainingScrollableContentInView =
        scrollController.position.viewportDimension;

    // Calculate the maximum height for the task to prevent exceeding the calendar boundary
    ref.read(maxTaskHeightProvider.notifier).state = max(
        (currentCalendarState.calendarWidgetBottomBoundaryY - localDy),
        currentCalendarState.snapIntervalHeight);

    final maxTaskHeight = ref.read(maxTaskHeightProvider);

    debugPrint("before clamp");
    debugPrint("localCurrentTimeSlotHeight: $localCurrentTimeSlotHeight");
    debugPrint("moved by: ${details.delta.dy}");
    debugPrint("Clamping localCurrentTimeSlotHeight:");
    debugPrint("Lower bound: ${currentCalendarState.snapIntervalHeight}");
    debugPrint("Upper bound: $maxTaskHeight");

    // Adjust height for bottom resizing
    final newSize = (localCurrentTimeSlotHeight + details.delta.dy).clamp(
        currentCalendarState.snapIntervalHeight,
        maxTaskHeight);

    debugPrint("after clamp");
    if (newSize >= currentCalendarState.snapIntervalHeight) {
      localCurrentTimeSlotHeightNotifier.state = newSize;
    }

    // Calculate the bottom position of the draggable box
    final draggableBoxBottomBoundary = localDy + localCurrentTimeSlotHeight;

    // Calculate the visible bottom boundary of the viewport
    final viewportBottom = scrollOffset + remainingScrollableContentInView;

    // Scroll if the bottom of the box goes beyond the viewport
    if (draggableBoxBottomBoundary > viewportBottom) {
      ref
          .read(scrollControllerNotifierProvider.notifier)
          .startDownwardsAutoScroll();
      isScrolledNotifier.state = true;
    } else {
      ref.read(scrollControllerNotifierProvider.notifier).stopAutoScroll();
    }
  }

  void _handleBottomDragEnd() {
    final currentCalendarState = ref.read(calendarStateNotifierProvider);
    final calendarStateNotifier =
        ref.read(calendarStateNotifierProvider.notifier);
    final localCurrentTimeSlotHeightNotifier =
        ref.read(localCurrentTimeSlotHeightProvider.notifier);
    final isScrolled = ref.watch(isScrolledProvider);
    final localCurrentTimeSlotHeight =
        ref.watch(localCurrentTimeSlotHeightProvider);

    ref.read(scrollControllerNotifierProvider.notifier).stopAutoScroll();

    // scroll extra if timeslot drag caused scrolling.
    if (isScrolled) {
      ref
          .read(scrollControllerNotifierProvider.notifier)
          .scrollDown(scrollAmount: currentCalendarState.defaultTimeSlotHeight);
    }

    // Snap height to the nearest interval after dragging
    final newSize =
        (localCurrentTimeSlotHeight / currentCalendarState.snapIntervalHeight)
                .round() *
            currentCalendarState.snapIntervalHeight;

    localCurrentTimeSlotHeightNotifier.state = newSize;

    calendarStateNotifier.updateCurrentTimeSlotHeight(newSize);
  }

  @override
  Widget build(BuildContext context) {
    final currentCalendarState = ref.watch(calendarStateNotifierProvider);
    final localDy = ref.watch(localDyProvider);
    final localCurrentTimeSlotHeight =
        ref.watch(localCurrentTimeSlotHeightProvider);

    return Positioned(
      left: currentCalendarState.draggableBox.dx +
          currentCalendarState.slotWidth * 0.75 -
          widget.indicatorWidth * 0.5, // Center horizontally
      top: localDy +
          localCurrentTimeSlotHeight -
          widget.indicatorHeight / 2, // Below the bottom edge
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          _handleBottomDrag(details: details);
        },
        onVerticalDragEnd: (_) {
          _handleBottomDragEnd();
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
              Icons.arrow_downward,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
