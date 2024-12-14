import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  void _handleDrag({required DragUpdateDetails details}) {
    final localDyNotifier = ref.read(localDyProvider.notifier);
    final isScrolledNotifier = ref.read(isScrolledProvider.notifier);
    final isScrolledUpNotifier = ref.read(isScrolledUpProvider.notifier);
    final localDy = ref.read(localDyProvider);
    final localCurrentTimeSlotHeight =
        ref.read(localCurrentTimeSlotHeightProvider);
    final defaultTimeSlotHeight = ref.read(defaultTimeSlotHeightProvider);
    final calendarWidgetTopBoundaryY =
        ref.read(calendarWidgetTopBoundaryYProvider);

    // hide bottom sheet while dragging
    ref.read(sheetExtentProvider.notifier).hideBottomSheet();

    final newDy = localDy + details.delta.dy;
    // Calculate the bottom position of the draggable box
    final draggableBoxBottomBoundary = newDy + localCurrentTimeSlotHeight;

    if (newDy >= calendarWidgetTopBoundaryY &&
        draggableBoxBottomBoundary <=
            ref.read(calendarWidgetBottomBoundaryYProvider)) {
      localDyNotifier.state = newDy;
    }

    // Calculate the visible bottom boundary of the viewport
    final viewportBottom = ref.read(scrollControllerNotifierProvider).offset +
        ref.read(scrollControllerNotifierProvider).position.viewportDimension;

    debugPrint("==========================");
    debugPrint("debug start");
    debugPrint("==========================");
    
    debugPrint("viewPortBottom: $viewportBottom");

    // the viewport bottom relative to the current screen without accounting for scroll offset.
    final screenViewportBottom = ref.read(scrollControllerNotifierProvider).position.viewportDimension;

    debugPrint("screenViewportBottom: $screenViewportBottom");
    debugPrint("bottom boundary of box: $draggableBoxBottomBoundary");

    final boxBottomBoundaryExceedThirtyPercentFromBottom = draggableBoxBottomBoundary < viewportBottom * 0.7;
    final boxTopBoundaryExceedThirtyPercentFromTop = newDy > screenViewportBottom * 0.3;
    final exceedCalendarTopBoundary =
        newDy < ref.read(scrollControllerNotifierProvider).offset;
    final exceedCalendarBottomBoundary = draggableBoxBottomBoundary > viewportBottom;
    // final bigTimeSlot = localCurrentTimeSlotHeight > defaultTimeSlotHeight * 3;

    if (exceedCalendarTopBoundary && boxBottomBoundaryExceedThirtyPercentFromBottom) {
      // auto scroll up if exceed top boundary
      ref
          .read(scrollControllerNotifierProvider.notifier)
          .startUpwardsAutoDrag();
      isScrolledNotifier.state = true;
      isScrolledUpNotifier.state = true;
    } else if (exceedCalendarBottomBoundary && boxTopBoundaryExceedThirtyPercentFromTop) {
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

    return Positioned(
      left: !draggableBoxSizeIsSmall ? leftPosition : defaultLeftPosition,
      top: !draggableBoxSizeIsSmall ? topPosition : defaultTopPosition,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          _handleDrag(details: details);
        },
        onVerticalDragEnd: (_) {
          _handleDragEnd();
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
              Icons.pan_tool_outlined,
              size: ref.watch(dragIndicatorIconSizeProvider),
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
