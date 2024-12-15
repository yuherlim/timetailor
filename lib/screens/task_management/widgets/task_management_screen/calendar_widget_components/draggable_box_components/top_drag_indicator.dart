import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_read_only_provider.dart';
import 'package:timetailor/domain/task_management/providers/scroll_controller_provider.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';

class TopDragIndicator extends ConsumerStatefulWidget {
  const TopDragIndicator({
    super.key,
  });

  @override
  ConsumerState<TopDragIndicator> createState() => _TopDragIndicatorState();
}

class _TopDragIndicatorState extends ConsumerState<TopDragIndicator> {
  bool _hasTriggeredHapticFeedback = false;

  void topBoundaryHapticFeedback(double newDy) {
    const double tolerance = 3.0;
    final calendarTopBoundary = ref.read(calendarWidgetTopBoundaryYProvider);
    if ((newDy - calendarTopBoundary).abs() <= tolerance) {
      if (!_hasTriggeredHapticFeedback) {
        HapticFeedback.mediumImpact();
        _hasTriggeredHapticFeedback = true; // Trigger only once
      }
    } else {
      _hasTriggeredHapticFeedback = false; // Reset when moving away
    }
  }

  void _handleTopDrag({
    required DragUpdateDetails details,
  }) {
    final localDyNotifier = ref.read(localDyProvider.notifier);
    final localCurrentTimeSlotHeightNotifier =
        ref.read(localCurrentTimeSlotHeightProvider.notifier);
    final isScrolledNotifier = ref.read(isScrolledProvider.notifier);
    final localDy = ref.read(localDyProvider);
    final localCurrentTimeSlotHeight =
        ref.read(localCurrentTimeSlotHeightProvider);
    final scrollController = ref.read(scrollControllerNotifierProvider);
    final draggableBoxBottomBoundary = (localDy + localCurrentTimeSlotHeight);
    final minDraggableBoxSizeDy =
        draggableBoxBottomBoundary - ref.read(snapIntervalHeightProvider);

    // state updates
    ref.read(isResizingProvider.notifier).state = true;
    // hide bottom sheet while dragging
    ref.read(sheetExtentProvider.notifier).hideBottomSheet();

    // Adjust height and position for top resizing
    final newDy = localDy + details.delta.dy;
    final double newSize = (localCurrentTimeSlotHeight - details.delta.dy)
        .clamp(ref.read(snapIntervalHeightProvider), double.infinity);

    if (newDy >= ref.read(calendarWidgetTopBoundaryYProvider) &&
        newDy < minDraggableBoxSizeDy) {
      localDyNotifier.state = newDy;
      localCurrentTimeSlotHeightNotifier.state = newSize;
    }

    // Trigger haptic feedback when the top boundary is reached
    topBoundaryHapticFeedback(newDy);

    final scrollOffset = scrollController.offset;

    ref.read(maxTaskHeightProvider.notifier).state = localDy -
        ref.read(calendarWidgetTopBoundaryYProvider) +
        localCurrentTimeSlotHeight;

    if (localDy < scrollOffset) {
      ref
          .read(scrollControllerNotifierProvider.notifier)
          .startUpwardsAutoScroll();
      isScrolledNotifier.state = true;
    } else {
      ref.read(scrollControllerNotifierProvider.notifier).stopAutoScroll();
    }
  }

  void _handleTopDragEnd() {
    final localDyNotifier = ref.read(localDyProvider.notifier);
    final localCurrentTimeSlotHeightNotifier =
        ref.read(localCurrentTimeSlotHeightProvider.notifier);
    final localDy = ref.read(localDyProvider);
    final localCurrentTimeSlotHeight =
        ref.read(localCurrentTimeSlotHeightProvider);
    final isScrolled = ref.read(isScrolledProvider);

    ref.read(scrollControllerNotifierProvider.notifier).stopAutoScroll();

    // state updates
    ref.read(isResizingProvider.notifier).state = false;
    // display back bottom sheet when drag end
    ref.read(sheetExtentProvider.notifier).redisplayBottomSheet();

    // scroll extra if timeslot drag caused scrolling.
    if (isScrolled) {
      ref
          .read(scrollControllerNotifierProvider.notifier)
          .scrollUp(scrollAmount: ref.read(defaultTimeSlotHeightProvider));
    }

    // Adjust for padding before snapping
    final adjustedDy = localDy - ref.read(calendarWidgetTopBoundaryYProvider);

    // Snap position to the nearest interval
    double newDy = (adjustedDy / ref.read(snapIntervalHeightProvider)).round() *
        ref.read(snapIntervalHeightProvider);

    // Reapply the padding offset
    newDy += ref.read(calendarWidgetTopBoundaryYProvider);

    // Snap the height directly (no adjustment needed for height)
    final double newSize =
        (localCurrentTimeSlotHeight / ref.read(snapIntervalHeightProvider))
                .round() *
            ref.read(snapIntervalHeightProvider);

    // Update local state
    localDyNotifier.state = newDy;
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

    return Positioned(
      left: ref.watch(slotStartXProvider) +
          ref.watch(slotWidthProvider) * 0.25 -
          ref.watch(draggableBoxIndicatorWidthProvider) *
              0.5, // Center horizontally
      top: localDy -
          ref.watch(draggableBoxIndicatorHeightProvider) /
              2, // Above the top edge
      child: GestureDetector(
        onVerticalDragStart: (details) => HapticFeedback.lightImpact(),
        onVerticalDragUpdate: (details) {
          _handleTopDrag(details: details);
        },
        onVerticalDragEnd: (_) {
          _handleTopDragEnd();
          HapticFeedback.lightImpact();
        },
        child: Container(
          width: ref.watch(draggableBoxIndicatorWidthProvider),
          height: ref.watch(draggableBoxIndicatorHeightProvider),
          decoration: BoxDecoration(
            color: AppColors.primaryAccent,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Icon(
              Icons.drag_handle,
              size: ref.watch(draggableBoxIndicatorIconSizeProvider),
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}