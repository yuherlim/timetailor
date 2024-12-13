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

    // hide bottom sheet while dragging
    ref.read(sheetExtentProvider.notifier).hideBottomSheet();

    final newDy = localDy + details.delta.dy;
    // Calculate the bottom position of the draggable box
    final draggableBoxBottomBoundary = newDy + localCurrentTimeSlotHeight;

    if (newDy >= ref.read(calendarWidgetTopBoundaryYProvider) &&
        draggableBoxBottomBoundary <=
            ref.read(calendarWidgetBottomBoundaryYProvider)) {
      localDyNotifier.state = newDy;
    }

    // Calculate the visible bottom boundary of the viewport
    final viewportBottom = ref.read(scrollControllerNotifierProvider).offset +
        ref.read(scrollControllerNotifierProvider).position.viewportDimension;

    // scroll behaviour
    if (localDy < ref.read(scrollControllerNotifierProvider).offset) {
      // auto scroll up if exceed top boundary
      ref
          .read(scrollControllerNotifierProvider.notifier)
          .startUpwardsAutoDrag();
      isScrolledNotifier.state = true;
      isScrolledUpNotifier.state = true;
    } else if (draggableBoxBottomBoundary > viewportBottom) {
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
    return Positioned(
      left: ref.watch(slotStartXProvider) -
          ref.watch(dragIndicatorWidthProvider) * 0.5 +
          ref.watch(slotWidthProvider) * 0.5,
      top: ref.watch(localDyProvider) -
          ref.watch(dragIndicatorHeightProvider) * 0.5 +
          ref.watch(localCurrentTimeSlotHeightProvider) * 0.5,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          _handleDrag(details: details);
        },
        onVerticalDragEnd: (_) {
          _handleDragEnd();
        },
        child: Container(
          width: ref.watch(dragIndicatorWidthProvider),
          height: ref.watch(dragIndicatorHeightProvider),
          decoration: BoxDecoration(
            color: AppColors.primaryAccent,
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
