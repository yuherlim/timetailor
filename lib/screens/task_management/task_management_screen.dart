import 'dart:async';
import 'dart:math';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/data/task_management/models/draggable_box.dart';
import 'package:timetailor/data/task_management/models/time_slot_info.dart';
import 'package:timetailor/domain/task_management/providers/task_management_provider.dart';
import 'package:timetailor/screens/task_management/widgets/calendar_header.dart';
import 'package:timetailor/screens/task_management/widgets/calendar_painter.dart';
import 'package:timetailor/screens/task_management/widgets/calendar_widget.dart';

class TaskManagementScreen extends ConsumerStatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  ConsumerState<TaskManagementScreen> createState() =>
      _TaskManagementScreenState();
}

class _TaskManagementScreenState extends ConsumerState<TaskManagementScreen> {
  TimeSlotInfo timeSlotInfo = TimeSlotInfo();
  double currentTimeSlotHeight = 0;
  double defaultTimeSlotHeight = 0;
  DraggableBox draggableBox = DraggableBox(dx: 0, dy: 0);
  int currentSlotIndex = 0;
  bool showDraggableBox = false;
  static const double calendarWidgetTopBoundaryY = 16;
  static const double calendarBottomPadding = 120;
  double calendarWidgetBottomBoundaryY = 0;
  late ScrollController _scrollController;
  List<double> timeSlotBoundaries = [];
  Timer? _scrollTimer;
  double maxTaskHeight = 0;
  bool isScrolled = false;

  @override
  void initState() {
    _scrollController = ScrollController(); // Initialize the scroll controller

    BackButtonInterceptor.add(_backButtonInterceptor);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // calculations of these elements need to wait for the widget build to complete, hence placed in this scope.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenHeight = MediaQuery.of(context).size.height;

      setState(() {
        defaultTimeSlotHeight =
            screenHeight <= 800 ? 120 : 144; // Initialize time slot height
        TimeSlotInfo.slotWidth = CalendarPainter
            .slotWidth; //Need wait for calendar painter to finish building first.
        TimeSlotInfo.slotStartX = CalendarPainter.slotStartX;
        TimeSlotInfo.pixelsPerMinute = defaultTimeSlotHeight / 60;
        TimeSlotInfo.snapInterval =
            5 * TimeSlotInfo.pixelsPerMinute; // Snap every 5 minutes
        final calendarHeight = defaultTimeSlotHeight * 24;
        calendarWidgetBottomBoundaryY =
            calendarWidgetTopBoundaryY + calendarHeight;

        // Generate time slot boundaries
        timeSlotBoundaries = List.generate(
          24,
          (i) => calendarWidgetTopBoundaryY + (defaultTimeSlotHeight * i),
        );
      });
      super.didChangeDependencies();
    });
  }

  void _startDownwardsAutoScroll() {
    const double scrollAmount = 20;

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
        setState(() {
          final newSize = (currentTimeSlotHeight + scrollAmount)
              .clamp(TimeSlotInfo.snapInterval, maxTaskHeight);
          currentTimeSlotHeight = newSize;
        });
      } else {
        _stopAutoScroll(); // Stop scrolling if we reach the end
      }
    });
  }

  void _startUpwardsAutoScroll() {
    const double scrollAmount = 20;

    _stopAutoScroll(); // Stop any ongoing scroll
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final currentOffset = _scrollController.offset;

      if (currentOffset > 0.0) {
        _scrollController.jumpTo(
          max(0.0, (currentOffset - scrollAmount)), // Scroll up
        );
        setState(() {
          final newDy =
              max(calendarWidgetTopBoundaryY, (draggableBox.dy - scrollAmount));
          print("newDy: $newDy");
          print("TimeSlotInfo.snapInterval: ${TimeSlotInfo.snapInterval}");
          print("maxTaskHeight: $maxTaskHeight");
          final newSize = (currentTimeSlotHeight + scrollAmount)
              .clamp(TimeSlotInfo.snapInterval, maxTaskHeight);
          print("ran clamp");

          print("dy: ${draggableBox.dy}");
          print("currentTimeSlotHeight: $currentTimeSlotHeight");
          draggableBox.dy = newDy;
          currentTimeSlotHeight = newSize;
        });
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
    final location = GoRouter.of(context).state!.path;
    // print(location);
    // print(location == RoutePath.taskManagementPath);

    // only intercept back gesture when the current nav branch is task management
    if (location == RoutePath.taskManagementPath && showDraggableBox) {
      setState(() {
        showDraggableBox = false;
      });
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

    // indicator dimensions
    const double indicatorWidth = 80;
    const double indicatorHeight = 30;

    return PopScope(
      canPop: !showDraggableBox,
      onPopInvokedWithResult: (didPop, result) {
        print("didPop: $didPop");
        if (showDraggableBox && !didPop) {
          setState(() {
            showDraggableBox = false;
          });
        }
      },
      child: Scaffold(
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
                  ref
                      .read(currentDateNotifierProvider.notifier)
                      .updateToToday();
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
                        if (showDraggableBox) {
                          setState(() {
                            showDraggableBox = false;
                          });
                          return;
                        }

                        final tapPosition = details.localPosition.dy;

                        // Binary search to find the correct time slot
                        int slotIndex = binarySearchSlotIndex(tapPosition);

                        print("slotIndex before handling: $slotIndex");

                        // Handle case where the tap is after the last slot
                        if (slotIndex == -1 &&
                            tapPosition >= timeSlotBoundaries.last) {
                          slotIndex = timeSlotBoundaries.length - 1;
                        }

                        print(
                            "timeSlotBoundaries: ${timeSlotBoundaries.toString()}");
                        print("relative calendar tap position: $tapPosition");
                        print(
                            "local tap position: ${details.localPosition.dy}");
                        print("slotIndex: $slotIndex");
                        print(
                            "timeSlotStartingY: ${timeSlotBoundaries[slotIndex]}");

                        // Snap to the correct time slot
                        if (slotIndex != -1) {
                          setState(() {
                            draggableBox = DraggableBox(
                              dx: TimeSlotInfo.slotStartX,
                              dy: timeSlotBoundaries[slotIndex],
                            );
                            currentTimeSlotHeight =
                                defaultTimeSlotHeight; // Reset height
                            currentSlotIndex = slotIndex; // current slot index
                            showDraggableBox = true;
                          });
                        }
                      },
                      child: CalendarWidget(
                        context: this.context,
                        slotHeight: defaultTimeSlotHeight,
                        snapInterval: TimeSlotInfo.snapInterval,
                        bottomPadding: calendarBottomPadding,
                      ),
                    ),
                    if (showDraggableBox)
                      Positioned(
                        left: draggableBox.dx,
                        top: draggableBox.dy,
                        child: Container(
                          width: TimeSlotInfo.slotWidth, // Fixed width
                          height:
                              currentTimeSlotHeight, // Dynamically adjusted height.
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
                    if (showDraggableBox)
                      Positioned(
                        left: draggableBox.dx +
                            TimeSlotInfo.slotWidth * 0.25 -
                            indicatorWidth * 0.5, // Center horizontally
                        top: draggableBox.dy -
                            indicatorHeight / 2, // Above the top edge
                        child: GestureDetector(
                          onVerticalDragUpdate: (details) {
                            print("");
                            print("onPanUpdate triggered");
                            setState(() {
                              // Adjust height and position for top resizing
                              final newDy = draggableBox.dy + details.delta.dy;
                              final newSize =
                                  (currentTimeSlotHeight - details.delta.dy)
                                      .clamp(TimeSlotInfo.snapInterval,
                                          double.infinity);

                              print("current position: ${draggableBox.dy}");
                              print("moved by: ${details.delta.dy}");
                              print("new position: $newDy");
                              print("new size: $newSize");

                              final draggableBoxBottomBoundary =
                                  (newDy + newSize);

                              final minDraggableBoxSizeDy =
                                  draggableBoxBottomBoundary -
                                      TimeSlotInfo.snapInterval;

                              print(
                                  "draggableBoxBottomBoundary: $draggableBoxBottomBoundary");
                              print(
                                  "TimeSlotInfo.snapInterval: ${TimeSlotInfo.snapInterval}");
                              print(
                                  "minDraggableBoxSizeDy: $minDraggableBoxSizeDy");

                              if (newDy >= calendarWidgetTopBoundaryY &&
                                  newDy < minDraggableBoxSizeDy) {
                                draggableBox.dy = newDy;
                                currentTimeSlotHeight = newSize;
                              }

                              print(
                                  "currentTimeSlotHeight: $currentTimeSlotHeight");

                              final scrollOffset = _scrollController.offset;

                              print(
                                  "draggableBoxTopBoundary: ${draggableBox.dy}");
                              print("scrollOffset: $scrollOffset");

                              maxTaskHeight = draggableBox.dy -
                                  calendarWidgetTopBoundaryY +
                                  currentTimeSlotHeight;

                              print(
                                  "maxTaskHeight before auto scroll: $maxTaskHeight");

                              if (draggableBox.dy < scrollOffset) {
                                print("");
                                print("start upwards scroll");
                                print("");
                                _startUpwardsAutoScroll();
                                isScrolled = true;
                              } else {
                                _stopAutoScroll();
                              }

                              print(
                                  "maxTaskHeight after auto scroll: $maxTaskHeight");
                            });
                          },
                          onVerticalDragEnd: (_) {
                            _stopAutoScroll();

                            // scroll extra if timeslot drag caused scrolling.
                            if (isScrolled) {
                              scrollUp(scrollAmount: defaultTimeSlotHeight);
                            }

                            setState(() {
                              // Snap height and position to the nearest interval after dragging
                              // draggableBox.dy =
                              //     (draggableBox.dy / TimeSlotInfo.snapInterval)
                              //             .round() *
                              //         TimeSlotInfo.snapInterval;
                              // currentTimeSlotHeight = (currentTimeSlotHeight /
                              //             TimeSlotInfo.snapInterval)
                              //         .round() *
                              //     TimeSlotInfo.snapInterval;

                              // Snap draggableBox.dy to the nearest interval
                              draggableBox.dy =
                                  (draggableBox.dy / TimeSlotInfo.snapInterval)
                                          .round() *
                                      TimeSlotInfo.snapInterval;

                              // Calculate the nearest snapped bottom position of the draggable box
                              final snappedBottom =
                                  draggableBox.dy + currentTimeSlotHeight;

                              // Snap the bottom position to the nearest interval
                              final snappedBottomPosition =
                                  (snappedBottom / TimeSlotInfo.snapInterval)
                                          .round() *
                                      TimeSlotInfo.snapInterval;

                              // Update currentTimeSlotHeight based on the snapped positions
                              currentTimeSlotHeight =
                                  snappedBottomPosition - draggableBox.dy;

                              print(
                                  "scrollOffset after drag end: ${_scrollController.offset}");
                            });
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
                    if (showDraggableBox)
                      Positioned(
                        left: draggableBox.dx +
                            TimeSlotInfo.slotWidth * 0.75 -
                            indicatorWidth * 0.5, // Center horizontally
                        top: draggableBox.dy +
                            currentTimeSlotHeight -
                            indicatorHeight / 2, // Below the bottom edge
                        child: GestureDetector(
                          onVerticalDragUpdate: (details) {
                            setState(() {
                              // Get the scroll offset of the calendar
                              final scrollOffset = _scrollController.offset;
                              final remainingScrollableContentInView =
                                  _scrollController.position.viewportDimension;

                              // Calculate the maximum height for the task to prevent exceeding the calendar boundary
                              maxTaskHeight = max(
                                  (calendarWidgetBottomBoundaryY -
                                      draggableBox.dy),
                                  TimeSlotInfo.snapInterval);

                              print(
                                  "calendarWidgetBottomBoundaryY: $calendarWidgetBottomBoundaryY");
                              print("scrollOffset: $scrollOffset");
                              print(
                                  "remainingScrollableContentInView: $remainingScrollableContentInView");
                              print("maxTaskHeight: $maxTaskHeight");
                              print(
                                  "currentTimeSlotHeight: $currentTimeSlotHeight");
                              print("current position: ${draggableBox.dy}");
                              print("moved by: ${details.delta.dy}");
                              print(
                                  "TimeSlotInfo.snapInterval: ${TimeSlotInfo.snapInterval}");

                              // Adjust height for bottom resizing
                              final newSize = (currentTimeSlotHeight +
                                      details.delta.dy)
                                  .clamp(
                                      TimeSlotInfo.snapInterval, maxTaskHeight);
                              if (newSize >= TimeSlotInfo.snapInterval) {
                                currentTimeSlotHeight = newSize;
                              }

                              // Calculate the bottom position of the draggable box
                              final draggableBoxBottomBoundary =
                                  draggableBox.dy + currentTimeSlotHeight;

                              // Calculate the visible bottom boundary of the viewport
                              final viewportBottom = scrollOffset +
                                  remainingScrollableContentInView;

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
                            });
                          },
                          onVerticalDragEnd: (_) {
                            _stopAutoScroll();

                            // scroll extra if timeslot drag caused scrolling.
                            if (isScrolled) {
                              scrollDown(scrollAmount: defaultTimeSlotHeight);
                            }

                            setState(() {
                              // Snap height to the nearest interval after dragging
                              currentTimeSlotHeight = (currentTimeSlotHeight /
                                          TimeSlotInfo.snapInterval)
                                      .round() *
                                  TimeSlotInfo.snapInterval;
                            });
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
                    // ListView.builder(
                    //   padding: const EdgeInsets.all(16),
                    //   itemCount: 10, // Example number of tasks
                    //   itemBuilder: (context, index) {
                    //     return Card(
                    //       margin: const EdgeInsets.symmetric(vertical: 8),
                    //       child: ListTile(
                    //         title: StyledText("Task ${index + 1}"),
                    //         subtitle: const StyledText("9:00 AM - 10:00 AM"),
                    //         trailing: IconButton(
                    //           icon: Icon(
                    //             Icons.check_circle_outline,
                    //             color: AppColors.textColor,
                    //           ),
                    //           onPressed: () {
                    //             // Mark task as completed
                    //           },
                    //         ),
                    //         onTap: () {
                    //           // Navigate to Task Details Screen
                    //           // context.go(taskCreationPath);
                    //         },
                    //       ),
                    //     );
                    //   },
                    // ),
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

  int binarySearchSlotIndex(double tapPosition) {
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
