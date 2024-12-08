import 'dart:async';
import 'dart:math';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/state/calendar_state.dart';
import 'package:timetailor/screens/task_management/widgets/calendar_widget_background.dart';
import 'package:timetailor/screens/task_management/widgets/current_time_indicator.dart';
import 'package:timetailor/screens/task_management/widgets/draggable_box_components/bottom_indicator.dart';
import 'package:timetailor/screens/task_management/widgets/draggable_box_components/draggable_box.dart';
import 'package:timetailor/screens/task_management/widgets/draggable_box_components/top_indicator.dart';

class CalendarWidget extends ConsumerStatefulWidget {
  const CalendarWidget({super.key});

  @override
  ConsumerState<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends ConsumerState<CalendarWidget> {
  bool isScrolled = false;
  late ScrollController _scrollController;
  Timer? _scrollTimer;
  double localDy = 0;
  double localCurrentTimeSlotHeight = 0;

  @override
  void initState() {
    _scrollController = ScrollController(); // Initialize the scroll controller
    BackButtonInterceptor.add(_backButtonInterceptor);
    _initializeCalendarState();
    super.initState();
  }

  void _initializeCalendarState() {
    // calculations of these elements need to wait for the widget build to complete, hence placed in this scope.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenHeight = MediaQuery.of(context).size.height;

      // Calculate first
      final double defaultTimeSlotHeight = screenHeight <= 800 ? 120 : 144;
      final double pixelsPerMinute = defaultTimeSlotHeight / 60;
      final double snapIntervalHeight = 5 * pixelsPerMinute;
      final double calendarHeight = defaultTimeSlotHeight * 24;
      final double calendarWidgetBottomBoundaryY =
          CalendarState.calendarWidgetTopBoundaryY + calendarHeight;
      // Generate time slot boundaries
      final List<double> timeSlotBoundaries = List.generate(
        24,
        (i) =>
            CalendarState.calendarWidgetTopBoundaryY +
            (defaultTimeSlotHeight * i),
      );

      // update state
      ref.read(calendarStateNotifierProvider.notifier)
        ..updateDefaultTimeSlotHeight(defaultTimeSlotHeight)
        ..updatePixelsPerMinute(pixelsPerMinute)
        ..updateSnapIntervalHeight(snapIntervalHeight)
        ..updateCalendarHeight(calendarHeight)
        ..updateCalendarWidgetBottomBoundaryY(calendarWidgetBottomBoundaryY)
        ..updateTimeSlotBoundaries(timeSlotBoundaries);
    });
  }

  void scrollDown({required double scrollAmount}) {
    // reset isScrolled state
    setState(() {
      isScrolled = false;
    });

    // perform extra scrolling
    final scrollOffset = _scrollController.offset;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    if (scrollOffset < maxScrollExtent) {
      _scrollController.animateTo(
        (scrollOffset + scrollAmount).clamp(0.0, maxScrollExtent),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void scrollUp({required double scrollAmount}) {
    // reset isScrolled state
    setState(() {
      isScrolled = false;
    });

    // perform extra scrolling
    final scrollOffset = _scrollController.offset;
    if (scrollOffset > 0) {
      _scrollController.animateTo(
        (scrollOffset - scrollAmount).clamp(0.0, double.infinity),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  int binarySearchSlotIndex(
    double tapPosition,
    List<double> timeSlotBoundaries,
  ) {
    int low = 0;
    int high = timeSlotBoundaries.length - 1;
    int slotIndex = -1;

    while (low <= high) {
      int mid = (low + high) ~/ 2;

      if (mid < timeSlotBoundaries.length - 1 &&
          tapPosition >= timeSlotBoundaries[mid] &&
          tapPosition < timeSlotBoundaries[mid + 1]) {
        slotIndex = mid; // Found the slot
        break;
      } else if (tapPosition < timeSlotBoundaries[mid]) {
        high = mid - 1; // Search in the left half
      } else {
        low = mid + 1; // Search in the right half
      }
    }
    return slotIndex;
  }

  void scrollToCurrentTimeIndicator({required double position}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenHeight = MediaQuery.of(context).size.height;
      _scrollController.animateTo(
        position - screenHeight * 0.3,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    });
  }

  bool _backButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    final showDraggableBox =
        ref.read(calendarStateNotifierProvider).showDraggableBox;
    final location = GoRouter.of(context).state!.path;

    // only intercept back gesture when the current nav branch is task management
    if (location == RoutePath.taskManagementPath && showDraggableBox) {
      ref
          .read(calendarStateNotifierProvider.notifier)
          .toggleDraggableBox(false);

      return true; // Prevents the default back button behavior
    }
    return false; // Allows the default back button behavior
  }

  void _startDownwardsAutoScroll() {
    const double scrollAmount = 15;

    final currentCalendarState = ref.read(calendarStateNotifierProvider);
    final calendarStateNotifier =
        ref.read(calendarStateNotifierProvider.notifier);

    _stopAutoScroll(); // Stop any ongoing scroll
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final currentOffset = _scrollController.offset;
      final maxScrollExtent = _scrollController.position.maxScrollExtent;

      if (currentOffset < maxScrollExtent) {
        _scrollController.jumpTo(
          (currentOffset + scrollAmount)
              .clamp(0, maxScrollExtent), // Scroll down
        );
        final newSize = (localCurrentTimeSlotHeight + scrollAmount).clamp(
            currentCalendarState.snapIntervalHeight,
            currentCalendarState.maxTaskHeight);

        // update local state
        setState(() {
          localCurrentTimeSlotHeight = newSize;
        });

        calendarStateNotifier.updateCurrentTimeSlotHeight(newSize);
      } else {
        _stopAutoScroll(); // Stop scrolling if we reach the end
      }
    });
  }

  void _startUpwardsAutoScroll() {
    const double scrollAmount = 15;

    final currentCalendarState = ref.read(calendarStateNotifierProvider);
    final calendarStateNotifier =
        ref.read(calendarStateNotifierProvider.notifier);

    _stopAutoScroll(); // Stop any ongoing scroll
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final currentOffset = _scrollController.offset;

      if (currentOffset > 0.0) {
        _scrollController.jumpTo(
          max(0.0, (currentOffset - scrollAmount)), // Scroll up
        );
        final newDy = max(
            CalendarState.calendarWidgetTopBoundaryY, (localDy - scrollAmount));
        final newSize = (localCurrentTimeSlotHeight + scrollAmount).clamp(
            currentCalendarState.snapIntervalHeight,
            currentCalendarState.maxTaskHeight);

        // update local state
        setState(() {
          localDy = newDy;
          localCurrentTimeSlotHeight = newSize;
        });

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
    _scrollController.dispose();
    BackButtonInterceptor.remove(_backButtonInterceptor);
    super.dispose();
  }

  void _handleCalendarOnTapUp({
    required TapUpDetails details,
  }) {
    final currentCalendarState = ref.read(calendarStateNotifierProvider);
    final calendarStateNotifier =
        ref.read(calendarStateNotifierProvider.notifier);

    // if draggable box already created, reset state
    if (currentCalendarState.showDraggableBox) {
      calendarStateNotifier
          .toggleDraggableBox(!currentCalendarState.showDraggableBox);

      setState(() {
        localDy = 0;
        localCurrentTimeSlotHeight = 0;
      });
      return;
    }

    final tapPosition = details.localPosition.dy;

    // Binary search to find the correct time slot
    int slotIndex = binarySearchSlotIndex(
        tapPosition, currentCalendarState.timeSlotBoundaries);

    // Handle case where the tap is after the last slot
    if (slotIndex == -1 &&
        tapPosition >= currentCalendarState.timeSlotBoundaries.last) {
      slotIndex = currentCalendarState.timeSlotBoundaries.length - 1;
    }

    // Snap to the correct time slot
    if (slotIndex != -1) {
      // update local state
      setState(() {
        localDy = currentCalendarState.timeSlotBoundaries[slotIndex];
        localCurrentTimeSlotHeight = currentCalendarState.defaultTimeSlotHeight;
      });

      calendarStateNotifier.updateDraggableBoxPosition(
        dx: currentCalendarState.slotStartX,
        dy: currentCalendarState.timeSlotBoundaries[slotIndex],
      );
      calendarStateNotifier.updateCurrentTimeSlotHeight(
          currentCalendarState.defaultTimeSlotHeight); // Reset height
      calendarStateNotifier.toggleDraggableBox(true);
    }
  }

  void _handleTopDrag({
    required DragUpdateDetails details,
  }) {
    final currentCalendarState = ref.read(calendarStateNotifierProvider);
    final calendarStateNotifier =
        ref.read(calendarStateNotifierProvider.notifier);

    final draggableBoxBottomBoundary = (localDy + localCurrentTimeSlotHeight);

    final minDraggableBoxSizeDy =
        draggableBoxBottomBoundary - currentCalendarState.snapIntervalHeight;

    // Adjust height and position for top resizing
    final newDy = localDy + details.delta.dy;
    final newSize = (localCurrentTimeSlotHeight - details.delta.dy)
        .clamp(currentCalendarState.snapIntervalHeight, double.infinity);

    if (newDy >= CalendarState.calendarWidgetTopBoundaryY &&
        newDy < minDraggableBoxSizeDy) {
      setState(() {
        localDy = newDy;
        localCurrentTimeSlotHeight = newSize;
      });
    }

    final scrollOffset = _scrollController.offset;

    calendarStateNotifier.updateMaxTaskHeight(localDy -
        CalendarState.calendarWidgetTopBoundaryY +
        localCurrentTimeSlotHeight);

    if (localDy < scrollOffset) {
      _startUpwardsAutoScroll();
      isScrolled = true;
    } else {
      _stopAutoScroll();
    }
  }

  void _handleTopDragEnd() {
    final currentCalendarState = ref.read(calendarStateNotifierProvider);
    final calendarStateNotifier =
        ref.read(calendarStateNotifierProvider.notifier);

    _stopAutoScroll();

    // scroll extra if timeslot drag caused scrolling.
    if (isScrolled) {
      scrollUp(scrollAmount: currentCalendarState.defaultTimeSlotHeight);
    }

    // Adjust for padding before snapping
    final adjustedDy = localDy - CalendarState.calendarWidgetTopBoundaryY;

    // Snap position to the nearest interval
    double newDy =
        (adjustedDy / currentCalendarState.snapIntervalHeight).round() *
            currentCalendarState.snapIntervalHeight;

    // Reapply the padding offset
    newDy += CalendarState.calendarWidgetTopBoundaryY;

    // Snap the height directly (no adjustment needed for height)
    final newSize =
        (localCurrentTimeSlotHeight / currentCalendarState.snapIntervalHeight)
                .round() *
            currentCalendarState.snapIntervalHeight;

    // Update local state
    setState(() {
      localDy = newDy;
      localCurrentTimeSlotHeight = newSize;
    });

    // Update the new position and timeslot height
    calendarStateNotifier.updateDraggableBoxPosition(dy: newDy);
    calendarStateNotifier.updateCurrentTimeSlotHeight(newSize);
  }

  void _handleBottomDrag({
    required DragUpdateDetails details,
  }) {
    final currentCalendarState = ref.read(calendarStateNotifierProvider);
    final calendarStateNotifier =
        ref.read(calendarStateNotifierProvider.notifier);

    // Get the scroll offset of the calendar
    final scrollOffset = _scrollController.offset;
    final remainingScrollableContentInView =
        _scrollController.position.viewportDimension;

    // Calculate the maximum height for the task to prevent exceeding the calendar boundary
    calendarStateNotifier.updateMaxTaskHeight(max(
        (currentCalendarState.calendarWidgetBottomBoundaryY - localDy),
        currentCalendarState.snapIntervalHeight));

    // Adjust height for bottom resizing
    final newSize = (localCurrentTimeSlotHeight + details.delta.dy).clamp(
        currentCalendarState.snapIntervalHeight,
        currentCalendarState.maxTaskHeight);
    if (newSize >= currentCalendarState.snapIntervalHeight) {
      setState(() {
        localCurrentTimeSlotHeight = newSize;
      });
    }

    // Calculate the bottom position of the draggable box
    final draggableBoxBottomBoundary = localDy + localCurrentTimeSlotHeight;

    // Calculate the visible bottom boundary of the viewport
    final viewportBottom = scrollOffset + remainingScrollableContentInView;

    // Scroll if the bottom of the box goes beyond the viewport
    if (draggableBoxBottomBoundary > viewportBottom) {
      _startDownwardsAutoScroll();
      isScrolled = true;
    } else {
      _stopAutoScroll();
    }
  }

  void _handleBottomDragEnd() {
    final currentCalendarState = ref.read(calendarStateNotifierProvider);
    final calendarStateNotifier =
        ref.read(calendarStateNotifierProvider.notifier);

    _stopAutoScroll();

    // scroll extra if timeslot drag caused scrolling.
    if (isScrolled) {
      scrollDown(scrollAmount: currentCalendarState.defaultTimeSlotHeight);
    }

    // Snap height to the nearest interval after dragging
    final newSize =
        (localCurrentTimeSlotHeight / currentCalendarState.snapIntervalHeight)
                .round() *
            currentCalendarState.snapIntervalHeight;

    setState(() {
      localCurrentTimeSlotHeight = newSize;
    });

    calendarStateNotifier.updateCurrentTimeSlotHeight(newSize);
  }

  @override
  Widget build(BuildContext context) {
    final currentCalendarState = ref.watch(calendarStateNotifierProvider);

    // indicator dimensions
    const double indicatorWidth = 80;
    const double indicatorHeight = 30;

    return SingleChildScrollView(
      controller: _scrollController,
      child: Stack(
        children: [
          GestureDetector(
            onTapUp: (details) {
              _handleCalendarOnTapUp(details: details);
            },
            child: CalendarWidgetBackground(
              context: this.context,
              slotHeight: currentCalendarState.defaultTimeSlotHeight,
              snapInterval: currentCalendarState.snapIntervalHeight,
              topPadding: CalendarState.calendarWidgetTopBoundaryY,
              bottomPadding: CalendarState.calendarBottomPadding,
            ),
          ),
          // draggable box
          if (currentCalendarState.showDraggableBox)
            Positioned(
              left: currentCalendarState.draggableBox.dx,
              top: localDy,
              child: DraggableBox(
                localCurrentTimeSlotHeight: localCurrentTimeSlotHeight,
              ),
            ),
          // Top Indicator
          if (currentCalendarState.showDraggableBox)
            Positioned(
              left: currentCalendarState.draggableBox.dx +
                  currentCalendarState.slotWidth * 0.25 -
                  indicatorWidth * 0.5, // Center horizontally
              top: localDy - indicatorHeight / 2, // Above the top edge
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  _handleTopDrag(details: details);
                },
                onVerticalDragEnd: (_) {
                  _handleTopDragEnd();
                },
                child: const TopIndicator(
                  indicatorWidth: indicatorWidth,
                  indicatorHeight: indicatorHeight,
                ),
              ),
            ),
          // Bottom Indicator
          if (currentCalendarState.showDraggableBox)
            Positioned(
              left: currentCalendarState.draggableBox.dx +
                  currentCalendarState.slotWidth * 0.75 -
                  indicatorWidth * 0.5, // Center horizontally
              top: localDy +
                  localCurrentTimeSlotHeight -
                  indicatorHeight / 2, // Below the bottom edge
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  _handleBottomDrag(details: details);
                },
                onVerticalDragEnd: (_) {
                  _handleBottomDragEnd();
                },
                child: const BottomIndicator(
                  indicatorWidth: indicatorWidth,
                  indicatorHeight: indicatorHeight,
                ),
              ),
            ),
          // Current Time Indicator
          CurrentTimeIndicator(
            scrollToCurrentTimeIndicator: scrollToCurrentTimeIndicator,
          ),
        ],
      ),
    );
  }
}
