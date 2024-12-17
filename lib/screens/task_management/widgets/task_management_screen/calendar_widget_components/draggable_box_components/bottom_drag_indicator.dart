import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_read_only_provider.dart';
import 'package:timetailor/domain/task_management/providers/scroll_controller_provider.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';

class BottomDragIndicator extends ConsumerStatefulWidget {
  const BottomDragIndicator({
    super.key,
  });

  @override
  ConsumerState<BottomDragIndicator> createState() =>
      _BottomDragIndicatorState();
}

class _BottomDragIndicatorState extends ConsumerState<BottomDragIndicator> {
  bool _hasTriggeredBottomHapticFeedback = false;

  void bottomBoundaryHapticFeedback(double draggableBoxBottomBoundary) {
    const double tolerance = 1.0;
    final calendarBottomBoundary =
        ref.read(calendarWidgetBottomBoundaryYProvider);
    if ((draggableBoxBottomBoundary - calendarBottomBoundary).abs() <=
        tolerance) {
      if (!_hasTriggeredBottomHapticFeedback) {
        HapticFeedback.mediumImpact();
        _hasTriggeredBottomHapticFeedback = true; // Trigger only once
      }
    } else {
      _hasTriggeredBottomHapticFeedback = false; // Reset when moving away
    }
  }

  void _handleBottomDrag({
    required DragUpdateDetails details,
  }) {
    final localCurrentTimeSlotHeightNotifier =
        ref.read(localCurrentTimeSlotHeightProvider.notifier);
    final isScrolledNotifier = ref.read(isScrolledProvider.notifier);
    final isScrolledUpNotifier = ref.read(isScrolledUpProvider.notifier);
    final localDy = ref.read(localDyProvider);
    final localCurrentTimeSlotHeight =
        ref.read(localCurrentTimeSlotHeightProvider);
    final scrollController = ref.read(scrollControllerNotifierProvider);

    // Get the scroll offset of the calendar
    final scrollOffset = scrollController.offset;
    final remainingScrollableContentInView =
        scrollController.position.viewportDimension;

    // state updates
    ref.read(isResizingProvider.notifier).state = true;
    // hide bottom sheet while dragging
    ref.read(sheetExtentProvider.notifier).hideBottomSheet();

    // Calculate the maximum height for the task to prevent exceeding the calendar boundary
    ref.read(maxTaskHeightProvider.notifier).state = max(
        (ref.read(calendarWidgetBottomBoundaryYProvider) - localDy),
        ref.read(snapIntervalHeightProvider));

    final maxTaskHeight = ref.read(maxTaskHeightProvider);

    // Adjust height for bottom resizing
    final double newSize = (localCurrentTimeSlotHeight + details.delta.dy)
        .clamp(ref.read(snapIntervalHeightProvider), maxTaskHeight);

    if (newSize >= ref.read(snapIntervalHeightProvider)) {
      localCurrentTimeSlotHeightNotifier.state = newSize;
    }

    // Calculate the bottom position of the draggable box
    final draggableBoxBottomBoundary = localDy + localCurrentTimeSlotHeight;

    // Trigger haptic feedback when the bottom boundary is reached
    bottomBoundaryHapticFeedback(draggableBoxBottomBoundary);

    // Calculate the visible bottom boundary of the viewport
    final viewportBottom = scrollOffset + remainingScrollableContentInView;

    // Scroll if the bottom of the box goes beyond the viewport
    if (draggableBoxBottomBoundary > viewportBottom) {
      ref
          .read(scrollControllerNotifierProvider.notifier)
          .startDownwardsAutoScroll();
      isScrolledNotifier.state = true;
      isScrolledUpNotifier.state = false;
    } else if (draggableBoxBottomBoundary < scrollOffset) {
      ref
          .read(scrollControllerNotifierProvider.notifier)
          .startBottomBoundaryUpwardsAutoScroll();
      isScrolledNotifier.state = true;
      isScrolledUpNotifier.state = true;
    } else {
      ref.read(scrollControllerNotifierProvider.notifier).stopAutoScroll();
    }
  }

  void _handleBottomDragEnd() {
    final localCurrentTimeSlotHeightNotifier =
        ref.read(localCurrentTimeSlotHeightProvider.notifier);
    final isScrolled = ref.read(isScrolledProvider);
    final isScrolledUp = ref.read(isScrolledUpProvider);
    final localCurrentTimeSlotHeight =
        ref.read(localCurrentTimeSlotHeightProvider);

    ref.read(scrollControllerNotifierProvider.notifier).stopAutoScroll();

    // state updates
    ref.read(isResizingProvider.notifier).state = false;
    // display back bottom sheet when drag end
    ref.read(sheetExtentProvider.notifier).redisplayBottomSheet();

    // scroll extra if timeslot drag caused scrolling.
    if (isScrolled && isScrolledUp) {
      ref
          .read(scrollControllerNotifierProvider.notifier)
          .scrollUp(scrollAmount: ref.read(defaultTimeSlotHeightProvider) / 2);
    } else if (isScrolled && !isScrolledUp) {
      ref
          .read(scrollControllerNotifierProvider.notifier)
          .scrollDown(scrollAmount: ref.read(defaultTimeSlotHeightProvider) / 2);
    }

    // Snap height to the nearest interval after dragging
    final double newSize =
        (localCurrentTimeSlotHeight / ref.read(snapIntervalHeightProvider))
                .round() *
            ref.read(snapIntervalHeightProvider);

    localCurrentTimeSlotHeightNotifier.state = newSize;

    // update local start time and end time with values from draggable box
    ref
        .read(tasksNotifierProvider.notifier)
        .updateTaskTimeStateFromDraggableBox(
          dy: ref.read(localDyProvider),
          currentTimeSlotHeight: ref.read(localCurrentTimeSlotHeightProvider),
        );
  }

  @override
  Widget build(BuildContext context) {
    final localDy = ref.watch(localDyProvider);
    final localCurrentTimeSlotHeight =
        ref.watch(localCurrentTimeSlotHeightProvider);
    final localDyBottom = ref.watch(localDyBottomProvider);
    final isTaskNotOverlapping = ref
        .read(tasksNotifierProvider.notifier)
        .checkAddTaskValidity(dyTop: localDy, dyBottom: localDyBottom);

    return Positioned(
      left: ref.watch(slotStartXProvider) +
          ref.watch(slotWidthProvider) * 0.75 -
          ref.watch(draggableBoxIndicatorWidthProvider) *
              0.5, // Center horizontally
      top: localDy +
          localCurrentTimeSlotHeight -
          ref.watch(draggableBoxIndicatorHeightProvider) /
              2, // Below the bottom edge
      child: GestureDetector(
        onVerticalDragStart: (details) => HapticFeedback.lightImpact(),
        onVerticalDragUpdate: (details) {
          _handleBottomDrag(details: details);
        },
        onVerticalDragEnd: (_) {
          _handleBottomDragEnd();
          HapticFeedback.lightImpact();
        },
        child: Container(
          width: ref.watch(draggableBoxIndicatorWidthProvider),
          height: ref.watch(draggableBoxIndicatorHeightProvider),
          decoration: BoxDecoration(
            color: isTaskNotOverlapping ? AppColors.primaryAccent : Colors.red,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Center(
            child: Icon(
              Icons.drag_handle,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
