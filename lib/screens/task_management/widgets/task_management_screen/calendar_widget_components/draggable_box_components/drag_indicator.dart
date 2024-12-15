import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_read_only_provider.dart';
import 'package:timetailor/domain/task_management/providers/scroll_controller_provider.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';

class DragIndicator extends ConsumerStatefulWidget {
  const DragIndicator({super.key});

  @override
  ConsumerState<DragIndicator> createState() => _DragIndicatorState();
}

class _DragIndicatorState extends ConsumerState<DragIndicator> {
  bool _hasTriggeredTopHapticFeedback = false;
  bool _hasTriggeredBottomHapticFeedback = false;

  void topBoundaryHapticFeedback(double newDy) {
    const double tolerance = 3.0;
    final calendarTopBoundary = ref.read(calendarWidgetTopBoundaryYProvider);
    if ((newDy - calendarTopBoundary).abs() <= tolerance) {
      if (!_hasTriggeredTopHapticFeedback) {
        HapticFeedback.mediumImpact();
        _hasTriggeredTopHapticFeedback = true; // Trigger only once
      }
    } else {
      _hasTriggeredTopHapticFeedback = false; // Reset when moving away
    }
  }

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

  void _handleDrag({required Offset delta}) {
    final localDyNotifier = ref.read(localDyProvider.notifier);
    final isScrolledNotifier = ref.read(isScrolledProvider.notifier);
    final isScrolledUpNotifier = ref.read(isScrolledUpProvider.notifier);
    final localDy = ref.read(localDyProvider);
    final localCurrentTimeSlotHeight =
        ref.read(localCurrentTimeSlotHeightProvider);
    final calendarWidgetTopBoundaryY =
        ref.read(calendarWidgetTopBoundaryYProvider);
    final calendarWidgetBottomBoundaryY =
        ref.read(calendarWidgetBottomBoundaryYProvider);
    final scrollController = ref.read(scrollControllerNotifierProvider);
    final scrollOffset = scrollController.offset;

    // hide bottom sheet while dragging
    ref.read(sheetExtentProvider.notifier).hideBottomSheet();

    final newDy = localDy + delta.dy;

    final draggableBoxBottomBoundary = newDy + localCurrentTimeSlotHeight;
    final draggableBoxTopBoundary = newDy;

    if (newDy >= calendarWidgetTopBoundaryY &&
        draggableBoxBottomBoundary <= calendarWidgetBottomBoundaryY) {
      localDyNotifier.state = newDy;
    }

    // trigger haptic feedback on topmost and bottommost
    topBoundaryHapticFeedback(draggableBoxTopBoundary);
    bottomBoundaryHapticFeedback(draggableBoxBottomBoundary);

    // the viewport bottom relative to the current screen without accounting for scroll offset.
    final screenViewportBottom = scrollController.position.viewportDimension;
    // Calculate the visible bottom boundary of the viewport considering scroll offset
    final contentViewportBottom = scrollOffset + screenViewportBottom;

    final contentOffsetFromTop = scrollOffset + screenViewportBottom * 0.3;
    final contentOffsetFromBottom = scrollOffset + screenViewportBottom * 0.7;
    final boxBottomBoundaryExceedOffsetFromBottom =
        draggableBoxBottomBoundary < contentOffsetFromBottom;
    final boxTopBoundaryExceedOffsetFromTop =
        draggableBoxTopBoundary > contentOffsetFromTop;
    final exceedContentTopBoundary = draggableBoxTopBoundary < scrollOffset;
    final exceedContentBottomBoundary =
        draggableBoxBottomBoundary > contentViewportBottom;
    // final bigTimeSlot = localCurrentTimeSlotHeight > defaultTimeSlotHeight * 3;

    if (exceedContentTopBoundary && boxBottomBoundaryExceedOffsetFromBottom) {
      // auto scroll up if exceed top boundary
      ref
          .read(scrollControllerNotifierProvider.notifier)
          .startUpwardsAutoDrag();
      isScrolledNotifier.state = true;
      isScrolledUpNotifier.state = true;
    } else if (exceedContentBottomBoundary &&
        boxTopBoundaryExceedOffsetFromTop) {
      // auto scroll down if exceed bottom boundary
      ref
          .read(scrollControllerNotifierProvider.notifier)
          .startDownwardsAutoDrag();
      isScrolledNotifier.state = true;
      isScrolledUpNotifier.state = false;
    } else {
      ref.read(scrollControllerNotifierProvider.notifier).stopAutoScroll();
    }
  }

  void autoScrollWhenBoundariesExceed(DragUpdateDetails details) {
    if (details.delta.dy < 0) {
      // auto scroll up if user is dragging upwards.
      ref
          .read(scrollControllerNotifierProvider.notifier)
          .startUpwardsAutoDrag();
      ref.read(isScrolledProvider.notifier).state = true;
      ref.read(isScrolledUpProvider.notifier).state = true;
    } else if (details.delta.dy > 0) {
      // auto scroll down if user is dragging downards.
      ref
          .read(scrollControllerNotifierProvider.notifier)
          .startDownwardsAutoDrag();
      ref.read(isScrolledProvider.notifier).state = true;
      ref.read(isScrolledUpProvider.notifier).state = false;
    } else {
      ref.read(scrollControllerNotifierProvider.notifier).stopAutoScroll();
    }
  }

  void _handleDragEnd() {
    final localDyNotifier = ref.read(localDyProvider.notifier);
    final localDy = ref.read(localDyProvider);
    final isScrolled = ref.read(isScrolledProvider);
    final isScrolledUp = ref.read(isScrolledUpProvider);

    ref.read(scrollControllerNotifierProvider.notifier).stopAutoScroll();

    // display back bottom sheet when drag end
    ref.read(sheetExtentProvider.notifier).redisplayBottomSheet();

    // scroll extra if timeslot drag caused scrolling.
    if (isScrolled && isScrolledUp) {
      ref
          .read(scrollControllerNotifierProvider.notifier)
          .scrollUp(scrollAmount: ref.read(defaultTimeSlotHeightProvider) / 2);
    } else if (isScrolled && !isScrolledUp) {
      ref.read(scrollControllerNotifierProvider.notifier).scrollDown(
          scrollAmount: ref.read(defaultTimeSlotHeightProvider) / 2);
    }

    // adjust for padding before snapping
    final adjustedDy = localDy - ref.read(calendarWidgetTopBoundaryYProvider);

    // snap position to the nearest interval
    double newDy = (adjustedDy / ref.read(snapIntervalHeightProvider)).round() *
        ref.read(snapIntervalHeightProvider);

    // Reapply the padding offset
    newDy += ref.read(calendarWidgetTopBoundaryYProvider);

    // Update local state
    localDyNotifier.state = newDy;

    // update local start time and end time with values from draggable box
    ref
        .read(tasksNotifierProvider.notifier)
        .updateTaskTimeStateFromDraggableBox(
          dy: ref.read(localDyProvider),
          currentTimeSlotHeight: ref.read(localCurrentTimeSlotHeightProvider),
        );
  }

  Offset computeDelta({required LongPressMoveUpdateDetails details}) {
    // Read the last known offset
    final lastOffset = ref.read(lastLongPressOffsetProvider);

    // Current offsetFromOrigin provided by the gesture
    final currentOffset = details.offsetFromOrigin;

    // Update the stored offset to the current one,
    // so next move update can compute a new delta
    ref.read(lastLongPressOffsetProvider.notifier).state = currentOffset;

    // Compute delta as difference from last offset
    return currentOffset - lastOffset;
  }

  @override
  Widget build(BuildContext context) {
    final dragIndicatorWidth = ref.watch(dragIndicatorWidthProvider);
    final defaultDragIndicatorWidth =
        ref.watch(defaultDragIndicatorWidthProvider);
    final dragIndicatorHeight = ref.watch(dragIndicatorHeightProvider);
    final defaultDragIndicatorHeight =
        ref.watch(defaultDragIndicatorHeightProvider);
    final snapIntervalHeight = ref.read(snapIntervalHeightProvider);

    final leftPosition = ref.watch(slotStartXProvider) -
        dragIndicatorWidth * 0.5 +
        ref.watch(slotWidthProvider) * 0.5;
    final defaultLeftPosition = ref.watch(slotStartXProvider) -
        defaultDragIndicatorWidth * 0.5 +
        ref.watch(slotWidthProvider) * 0.5;
    final topPosition = ref.watch(localDyProvider) -
        dragIndicatorHeight * 0.5 +
        ref.watch(localCurrentTimeSlotHeightProvider) * 0.5;
    final defaultTopPosition = ref.watch(localDyProvider) -
        defaultDragIndicatorHeight * 0.5 +
        ref.watch(localCurrentTimeSlotHeightProvider) * 0.5;

    final draggableBoxSizeIsSmall =
        dragIndicatorHeight <= snapIntervalHeight * 3;

    final isLongPressed = ref.watch(isDraggableBoxLongPressedProvider);

    return Positioned(
      left: !draggableBoxSizeIsSmall ? leftPosition : defaultLeftPosition,
      top: !draggableBoxSizeIsSmall ? topPosition : defaultTopPosition,
      child: GestureDetector(
        onLongPressStart: (details) {
          HapticFeedback.mediumImpact();
          // Reset the last offset to zero at the start of a long press
          ref.read(isDraggableBoxLongPressedProvider.notifier).state = true;
          ref.read(lastLongPressOffsetProvider.notifier).state = Offset.zero;
        },
        onLongPressMoveUpdate: (details) {
          _handleDrag(delta: computeDelta(details: details));
        },
        onLongPressEnd: (_) {
          HapticFeedback.mediumImpact();
          _handleDragEnd();
          ref.read(isDraggableBoxLongPressedProvider.notifier).state = false;
        },
        child: Container(
          width: !draggableBoxSizeIsSmall
              ? dragIndicatorWidth
              : defaultDragIndicatorWidth,
          height: !draggableBoxSizeIsSmall
              ? dragIndicatorHeight
              : defaultDragIndicatorHeight,
          decoration: BoxDecoration(
            color: !draggableBoxSizeIsSmall
                ? AppColors.primaryAccent.withOpacity(0.2)
                : AppColors.primaryAccent,
            // color: Colors.transparent,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Icon(
              isLongPressed
                  ? Symbols.expand_all_rounded
                  : Symbols.touch_long_rounded,
              size: ref.watch(dragIndicatorIconSizeProvider),
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
