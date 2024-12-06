import 'dart:async';
import 'dart:math';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/task_management/state/calendar_state.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/date_provider.dart';
import 'package:timetailor/screens/task_management/widgets/calendar_header.dart';
import 'package:timetailor/screens/task_management/widgets/calendar_widget_background.dart';

class TaskManagementScreen extends ConsumerStatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  ConsumerState<TaskManagementScreen> createState() =>
      _TaskManagementScreenState();
}

class _TaskManagementScreenState extends ConsumerState<TaskManagementScreen> {
  bool isScrolled = false;
  late ScrollController _scrollController;
  Timer? _scrollTimer;

  @override
  void initState() {
    _scrollController = ScrollController(); // Initialize the scroll controller

    BackButtonInterceptor.add(_backButtonInterceptor);

    print("init state running...");
    // calculations of these elements need to wait for the widget build to complete, hence placed in this scope.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenHeight = MediaQuery.of(context).size.height;

      // Calculate first
      final double defaultTimeSlotHeight = screenHeight <= 800 ? 120 : 144;
      final double pixelsPerMinute = defaultTimeSlotHeight / 60;
      final double snapInterval = 5 * pixelsPerMinute;
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
        ..updateSnapInterval(snapInterval)
        ..updateCalendarHeight(calendarHeight)
        ..updateCalendarWidgetBottomBoundaryY(calendarWidgetBottomBoundaryY)
        ..updateTimeSlotBoundaries(timeSlotBoundaries);

      print("");
      print("===============================");
      print("DEBUGGING initState");
      print("===============================");
    });
    super.initState();
  }

  void _startDownwardsAutoScroll() {
    const double scrollAmount = 20;

    final currentCalendarState = ref.read(calendarStateNotifierProvider);
    final calendarStateNotifier =
        ref.read(calendarStateNotifierProvider.notifier);

    _stopAutoScroll(); // Stop any ongoing scroll
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final currentOffset = _scrollController.offset;
      final maxScrollExtent = _scrollController.position.maxScrollExtent;

      if (currentOffset < maxScrollExtent) {
        print("currentOffset: $currentOffset");
        print("maxScrollExtent: $maxScrollExtent");
        _scrollController.jumpTo(
          (currentOffset + scrollAmount)
              .clamp(0, maxScrollExtent), // Scroll down
        );
        final newSize =
            (currentCalendarState.currentTimeSlotHeight + scrollAmount).clamp(
                currentCalendarState.snapInterval,
                currentCalendarState.maxTaskHeight);
        calendarStateNotifier.updateCurrentTimeSlotHeight(newSize);
      } else {
        _stopAutoScroll(); // Stop scrolling if we reach the end
      }
    });
  }

  void _startUpwardsAutoScroll() {
    const double scrollAmount = 20;

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
        final newDy = max(CalendarState.calendarWidgetTopBoundaryY,
            (currentCalendarState.draggableBox.dy - scrollAmount));
        print("newDy: $newDy");
        print(
            "TimeSlotInfo.snapInterval: ${currentCalendarState.snapInterval}");
        print("maxTaskHeight: ${currentCalendarState.maxTaskHeight}");
        final newSize =
            (currentCalendarState.currentTimeSlotHeight + scrollAmount).clamp(
                currentCalendarState.snapInterval,
                currentCalendarState.maxTaskHeight);
        print("ran clamp");

        print("dy: ${currentCalendarState.draggableBox.dy}");
        print(
            "currentTimeSlotHeight: ${currentCalendarState.currentTimeSlotHeight}");
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

  bool _backButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    final showDraggableBox =
        ref.read(calendarStateNotifierProvider).showDraggableBox;
    final location = GoRouter.of(context).state!.path;
    // print(location);
    // print(location == RoutePath.taskManagementPath);

    // only intercept back gesture when the current nav branch is task management
    if (location == RoutePath.taskManagementPath && showDraggableBox) {
      ref
          .read(calendarStateNotifierProvider.notifier)
          .toggleDraggableBox(false);

      return true; // Prevents the default back button behavior
    }
    return false; // Allows the default back button behavior
  }

  void calendarButtonOnTap({required DateTime date}) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      ref
          .read(currentDateNotifierProvider.notifier)
          .updateDate(date: selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSelectedDate = ref.watch(currentDateNotifierProvider);
    final currentMonth = ref.watch(currentMonthNotifierProvider);
    final currentCalendarState = ref.watch(calendarStateNotifierProvider);
    final calendarStateNotifier =
        ref.read(calendarStateNotifierProvider.notifier);

    // indicator dimensions
    const double indicatorWidth = 80;
    const double indicatorHeight = 30;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go(RoutePath.taskCreationPath); // Navigate to task creation
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.calendar_month),
          onPressed: () {
            calendarButtonOnTap(date: currentSelectedDate);
          },
        ),
        title: AppBarText(currentMonth),
        centerTitle: true,
        actions: [
          if (!ref
              .read(currentDateNotifierProvider.notifier)
              .currentDateIsToday())
            IconButton(
              icon: const Icon(Icons.today),
              onPressed: () {
                ref.read(currentDateNotifierProvider.notifier).updateToToday();
              },
            ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              context.go(RoutePath.taskHistoryPath);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar Header
          const CalendarHeader(),

          // Task List with Time Indicator
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Stack(
                children: [
                  GestureDetector(
                    onTapUp: (details) {
                      // if draggable box already created, do nothing
                      if (currentCalendarState.showDraggableBox) {
                        calendarStateNotifier.toggleDraggableBox(
                            !currentCalendarState.showDraggableBox);
                        return;
                      }

                      final tapPosition = details.localPosition.dy;

                      // Binary search to find the correct time slot
                      int slotIndex = binarySearchSlotIndex(
                          tapPosition, currentCalendarState.timeSlotBoundaries);

                      print("slotIndex before handling: $slotIndex");

                      // Handle case where the tap is after the last slot
                      if (slotIndex == -1 &&
                          tapPosition >=
                              currentCalendarState.timeSlotBoundaries.last) {
                        slotIndex =
                            currentCalendarState.timeSlotBoundaries.length - 1;
                      }

                      print(
                          "timeSlotBoundaries: ${currentCalendarState.timeSlotBoundaries.toString()}");
                      print("relative calendar tap position: $tapPosition");
                      print("local tap position: ${details.localPosition.dy}");
                      print("slotIndex: $slotIndex");
                      print(
                          "timeSlotStartingY: ${currentCalendarState.timeSlotBoundaries[slotIndex]}");

                      // Snap to the correct time slot
                      if (slotIndex != -1) {
                        calendarStateNotifier.updateDraggableBoxPosition(
                          dx: currentCalendarState.slotStartX,
                          dy: currentCalendarState
                              .timeSlotBoundaries[slotIndex],
                        );
                        calendarStateNotifier.updateCurrentTimeSlotHeight(
                            currentCalendarState
                                .defaultTimeSlotHeight); // Reset height
                        calendarStateNotifier.updateCurrentSlotIndex(
                            slotIndex); // current slot index
                        calendarStateNotifier.toggleDraggableBox(true);
                      }
                    },
                    child: CalendarWidgetBackground(
                      context: this.context,
                      slotHeight: currentCalendarState.defaultTimeSlotHeight,
                      snapInterval: currentCalendarState.snapInterval,
                      topPadding: CalendarState.calendarWidgetTopBoundaryY,
                      bottomPadding: CalendarState.calendarBottomPadding,
                    ),
                  ),
                  if (currentCalendarState.showDraggableBox)
                    Positioned(
                      left: currentCalendarState.draggableBox.dx,
                      top: currentCalendarState.draggableBox.dy,
                      child: Container(
                        width: currentCalendarState.slotWidth, // Fixed width
                        height: currentCalendarState
                            .currentTimeSlotHeight, // Dynamically adjusted height.
                        decoration: BoxDecoration(
                          color: Colors.transparent, // Transparent background
                          border: Border.all(
                            color: AppColors.primaryAccent, // Border color
                            width: 2.0, // Border thickness
                          ),
                        ),
                      ),
                    ),
                  // Top Indicator
                  if (currentCalendarState.showDraggableBox)
                    Positioned(
                      left: currentCalendarState.draggableBox.dx +
                          currentCalendarState.slotWidth * 0.25 -
                          indicatorWidth * 0.5, // Center horizontally
                      top: currentCalendarState.draggableBox.dy -
                          indicatorHeight / 2, // Above the top edge
                      child: GestureDetector(
                        onVerticalDragUpdate: (details) {
                          print("");
                          print("onVerticalDragUpdate triggered");
                          final draggableBoxBottomBoundary =
                              (currentCalendarState.draggableBox.dy +
                                  currentCalendarState.currentTimeSlotHeight);

                          final minDraggableBoxSizeDy =
                              draggableBoxBottomBoundary -
                                  currentCalendarState.snapInterval;

                          print("");
                          print("debugging draggable box initial values:");
                          print(
                              "draggableBoxBottomBoundary: $draggableBoxBottomBoundary");
                          print(
                              "currentTimeSlotHeight: ${currentCalendarState.currentTimeSlotHeight}");
                          print(
                              "TimeSlotInfo.snapInterval: ${currentCalendarState.snapInterval}");
                          print(
                              "minDraggableBoxSizeDy: $minDraggableBoxSizeDy");
                          print("");

                          // Adjust height and position for top resizing
                          final newDy = currentCalendarState.draggableBox.dy +
                              details.delta.dy;
                          final newSize =
                              (currentCalendarState.currentTimeSlotHeight -
                                      details.delta.dy)
                                  .clamp(currentCalendarState.snapInterval,
                                      double.infinity);

                          print(
                              "current position: ${currentCalendarState.draggableBox.dy}");
                          print("moved by: ${details.delta.dy}");
                          print("new position: $newDy");
                          print("new size: $newSize");

                          if (newDy >=
                                  CalendarState.calendarWidgetTopBoundaryY &&
                              newDy < minDraggableBoxSizeDy) {
                            calendarStateNotifier.updateDraggableBoxPosition(
                                dy: newDy);
                            calendarStateNotifier
                                .updateCurrentTimeSlotHeight(newSize);
                          }

                          // print(
                          //     "currentTimeSlotHeight: $currentTimeSlotHeight");

                          final scrollOffset = _scrollController.offset;

                          // print(
                          //     "draggableBoxTopBoundary: ${draggableBox.dy}");
                          // print("scrollOffset: $scrollOffset");

                          calendarStateNotifier.updateMaxTaskHeight(
                              currentCalendarState.draggableBox.dy -
                                  CalendarState.calendarWidgetTopBoundaryY +
                                  currentCalendarState.currentTimeSlotHeight);

                          // print(
                          //     "maxTaskHeight before auto scroll: $maxTaskHeight");

                          if (currentCalendarState.draggableBox.dy <
                              scrollOffset) {
                            print("");
                            print("start upwards scroll");
                            print("");
                            _startUpwardsAutoScroll();
                            isScrolled = true;
                          } else {
                            _stopAutoScroll();
                          }

                          // print(
                          //     "maxTaskHeight after auto scroll: $maxTaskHeight");
                        },
                        onVerticalDragEnd: (_) {
                          _stopAutoScroll();

                          // scroll extra if timeslot drag caused scrolling.
                          if (isScrolled) {
                            scrollUp(
                                scrollAmount:
                                    currentCalendarState.defaultTimeSlotHeight);
                          }

                          // print("");
                          // print(
                          //     "before update Height: $currentTimeSlotHeight");
                          // print("current dy: ${draggableBox.dy}");

                          // Adjust for padding before snapping
                          final adjustedDy =
                              currentCalendarState.draggableBox.dy -
                                  CalendarState.calendarWidgetTopBoundaryY;

                          // Snap position to the nearest interval
                          currentCalendarState.draggableBox.dy =
                              (adjustedDy / currentCalendarState.snapInterval)
                                      .round() *
                                  currentCalendarState.snapInterval;

                          // Reapply the padding offset
                          currentCalendarState.draggableBox.dy +=
                              CalendarState.calendarWidgetTopBoundaryY;

                          // Snap the height directly (no adjustment needed for height)
                          calendarStateNotifier.updateCurrentTimeSlotHeight(
                              (currentCalendarState.currentTimeSlotHeight /
                                          currentCalendarState.snapInterval)
                                      .round() *
                                  currentCalendarState.snapInterval);
                        },
                        child: Container(
                          width: indicatorWidth,
                          height: indicatorHeight,
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
                    ),
                  // Bottom Indicator

                  if (currentCalendarState.showDraggableBox)
                    Positioned(
                      left: currentCalendarState.draggableBox.dx +
                          currentCalendarState.slotWidth * 0.75 -
                          indicatorWidth * 0.5, // Center horizontally
                      top: currentCalendarState.draggableBox.dy +
                          currentCalendarState.currentTimeSlotHeight -
                          indicatorHeight / 2, // Below the bottom edge
                      child: GestureDetector(
                        onVerticalDragUpdate: (details) {
                          // Get the scroll offset of the calendar
                          final scrollOffset = _scrollController.offset;
                          final remainingScrollableContentInView =
                              _scrollController.position.viewportDimension;

                          // Calculate the maximum height for the task to prevent exceeding the calendar boundary
                          calendarStateNotifier.updateMaxTaskHeight(max(
                              (currentCalendarState
                                      .calendarWidgetBottomBoundaryY -
                                  currentCalendarState.draggableBox.dy),
                              currentCalendarState.snapInterval));

                          print(
                              "calendarWidgetBottomBoundaryY: ${currentCalendarState.calendarWidgetBottomBoundaryY}");
                          print("scrollOffset: $scrollOffset");
                          print(
                              "remainingScrollableContentInView: $remainingScrollableContentInView");
                          print(
                              "maxTaskHeight: ${currentCalendarState.maxTaskHeight}");
                          print(
                              "currentTimeSlotHeight: ${currentCalendarState.currentTimeSlotHeight}");
                          print(
                              "current position: ${currentCalendarState.draggableBox.dy}");
                          print("moved by: ${details.delta.dy}");
                          print(
                              "TimeSlotInfo.snapInterval: ${currentCalendarState.snapInterval}");

                          // Adjust height for bottom resizing
                          final newSize =
                              (currentCalendarState.currentTimeSlotHeight +
                                      details.delta.dy)
                                  .clamp(currentCalendarState.snapInterval,
                                      currentCalendarState.maxTaskHeight);
                          if (newSize >= currentCalendarState.snapInterval) {
                            calendarStateNotifier
                                .updateCurrentTimeSlotHeight(newSize);
                          }

                          // Calculate the bottom position of the draggable box
                          final draggableBoxBottomBoundary =
                              currentCalendarState.draggableBox.dy +
                                  currentCalendarState.currentTimeSlotHeight;

                          // Calculate the visible bottom boundary of the viewport
                          final viewportBottom =
                              scrollOffset + remainingScrollableContentInView;

                          // print("");
                          // print("current position: ${draggableBox.dy}");
                          // print("moved by: ${details.delta.dy}");
                          // print("scrollOffset: $scrollOffset");
                          // print("maxTaskHeight: $maxTaskHeight");
                          // print("new size: $newSize");
                          // print(
                          //     "draggableBoxBottomBoundary: $draggableBoxBottomBoundary");
                          // print("viewportBottom: $viewportBottom");

                          // Scroll if the bottom of the box goes beyond the viewport
                          if (draggableBoxBottomBoundary > viewportBottom) {
                            _startDownwardsAutoScroll();
                            isScrolled = true;
                          } else {
                            _stopAutoScroll();
                          }
                        },
                        onVerticalDragEnd: (_) {
                          _stopAutoScroll();

                          // scroll extra if timeslot drag caused scrolling.
                          if (isScrolled) {
                            scrollDown(
                                scrollAmount:
                                    currentCalendarState.defaultTimeSlotHeight);
                          }

                          // Snap height to the nearest interval after dragging
                          calendarStateNotifier.updateCurrentTimeSlotHeight(
                              (currentCalendarState.currentTimeSlotHeight /
                                          currentCalendarState.snapInterval)
                                      .round() *
                                  currentCalendarState.snapInterval);
                        },
                        child: Container(
                          width: indicatorWidth,
                          height: indicatorHeight,
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
                    ),
                  // Current Time Indicator
                  // const Positioned(
                  //   top: 100, // Dynamically calculate this position
                  //   left: 0,
                  //   right: 0,
                  //   child: Row(
                  //     children: [
                  //       SizedBox(width: 10),
                  //       Icon(Icons.access_time, color: Colors.red),
                  //       SizedBox(width: 10),
                  //       Expanded(
                  //         child: Divider(
                  //           color: Colors.red,
                  //           thickness: 1.5,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
      double tapPosition, List<double> timeSlotBoundaries) {
    int low = 0;
    int high = timeSlotBoundaries.length - 1;
    int slotIndex = -1;

    while (low <= high) {
      int mid = (low + high) ~/ 2;

      print("low: $low");
      print("mid: $mid");
      print("high: $high");

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
}
