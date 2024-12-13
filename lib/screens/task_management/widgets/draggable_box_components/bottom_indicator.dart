import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_read_only_provider.dart';
import 'package:timetailor/domain/task_management/providers/scroll_controller_provider.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';

class BottomIndicator extends ConsumerStatefulWidget {
  const BottomIndicator({
    super.key,
  });

  @override
  ConsumerState<BottomIndicator> createState() => _BottomIndicatorState();
}

class _BottomIndicatorState extends ConsumerState<BottomIndicator> {
  void _handleBottomDrag({
    required DragUpdateDetails details,
  }) {
    final localCurrentTimeSlotHeightNotifier =
        ref.read(localCurrentTimeSlotHeightProvider.notifier);
    final isScrolledNotifier = ref.read(isScrolledProvider.notifier);
    final localDy = ref.read(localDyProvider);
    final localCurrentTimeSlotHeight =
        ref.read(localCurrentTimeSlotHeightProvider);
    final scrollController = ref.read(scrollControllerNotifierProvider);

    // Get the scroll offset of the calendar
    final scrollOffset = scrollController.offset;
    final remainingScrollableContentInView =
        scrollController.position.viewportDimension;

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
    final localCurrentTimeSlotHeightNotifier =
        ref.read(localCurrentTimeSlotHeightProvider.notifier);
    final isScrolled = ref.read(isScrolledProvider);
    final localCurrentTimeSlotHeight =
        ref.read(localCurrentTimeSlotHeightProvider);

    ref.read(scrollControllerNotifierProvider.notifier).stopAutoScroll();

    // display back bottom sheet when drag end
    ref.read(sheetExtentProvider.notifier).redisplayBottomSheet();

    // scroll extra if timeslot drag caused scrolling.
    if (isScrolled) {
      ref
          .read(scrollControllerNotifierProvider.notifier)
          .scrollDown(scrollAmount: ref.read(defaultTimeSlotHeightProvider));
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
        onVerticalDragUpdate: (details) {
          _handleBottomDrag(details: details);
        },
        onVerticalDragEnd: (_) {
          _handleBottomDragEnd();
        },
        child: Container(
          width: ref.watch(draggableBoxIndicatorWidthProvider),
          height: ref.watch(draggableBoxIndicatorHeightProvider),
          decoration: BoxDecoration(
            color: AppColors.primaryAccent,
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
