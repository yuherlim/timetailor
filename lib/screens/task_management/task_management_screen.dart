import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timetailor/core/constants/route_paths.dart';
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
  bool resizingFromTop = false;
  DraggableBox draggableBox = DraggableBox(dx: 0, dy: 0);
  bool showDraggableBox = false;
  static const double calendarWidgetTopBoundaryY = 16;
  double calendarWidgetBottomBoundaryY = 0;
  late ScrollController _scrollController;
  List<double> timeSlotBoundaries = [];

  @override
  void initState() {
    _scrollController = ScrollController(); // Initialize the scroll controller
    super.initState();
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenHeight = MediaQuery.of(context).size.height;

      setState(() {
        defaultTimeSlotHeight =
            screenHeight <= 800 ? 80 : 100; // Initialize time slot height
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

  @override
  void dispose() {
    _scrollController.dispose(); // Clean up
    super.dispose();
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

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go(taskCreationPath); // Navigate to task creation
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
              context.go(taskHistoryPath);
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
                      // Get the scroll offset of the calendar
                      final scrollOffset = _scrollController.offset;
              
                      final tapPosition = scrollOffset + details.localPosition.dy;
              
                      // Binary search to find the correct time slot
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
              
                      print("slotIndex before handling: $slotIndex");
              
                      // Handle case where the tap is after the last slot
                      if (slotIndex == -1 &&
                          tapPosition >= timeSlotBoundaries.last) {
                        slotIndex = timeSlotBoundaries.length - 1;
                      }
              
                      print(
                          "timeSlotBoundaries: ${timeSlotBoundaries.toString()}");
                      print("relative calendar tap position: $tapPosition");
                      print("local tap position: ${details.localPosition.dy}");
                      print("slotIndex: $slotIndex");
                      print(
                          "timeSlotStartingY: ${timeSlotBoundaries[slotIndex]}");
                      print("scrollOffset: $scrollOffset");
              
                      // Snap to the correct time slot
                      if (slotIndex != -1) {
                        print("slot index != 1");
                        setState(() {
                          draggableBox = DraggableBox(
                            dx: TimeSlotInfo.slotStartX,
                            dy: timeSlotBoundaries[slotIndex],
                          );
                          currentTimeSlotHeight =
                              defaultTimeSlotHeight; // Reset height
                          showDraggableBox = true;
                          print("set state ran.");
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: calendarWidgetTopBoundaryY, horizontal: 8),
                      child: CalendarWidget(
                        context: this.context,
                        slotHeight: defaultTimeSlotHeight,
                      ),
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
                          TimeSlotInfo.slotWidth / 2 -
                          40, // Center horizontally
                      top: draggableBox.dy - 15, // Above the top edge
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            // Adjust height and position for top resizing
                            final newDy = draggableBox.dy + details.delta.dy;
                            final newSize =
                                (currentTimeSlotHeight - details.delta.dy).clamp(
                                    TimeSlotInfo.snapInterval, double.infinity);
              
                            if (newDy >= calendarWidgetTopBoundaryY &&
                                newSize >= TimeSlotInfo.snapInterval) {
                              draggableBox.dy = newDy;
                              currentTimeSlotHeight = newSize;
                            }
                          });
                        },
                        onPanEnd: (_) {
                          setState(() {
                            // Snap height and position to the nearest interval after dragging
                            draggableBox.dy =
                                (draggableBox.dy / TimeSlotInfo.snapInterval)
                                        .round() *
                                    TimeSlotInfo.snapInterval;
                            currentTimeSlotHeight = (currentTimeSlotHeight /
                                        TimeSlotInfo.snapInterval)
                                    .round() *
                                TimeSlotInfo.snapInterval;
                          });
                        },
                        child: Container(
                          width: 80,
                          height: 30,
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
                          TimeSlotInfo.slotWidth / 2 -
                          40, // Center horizontally
                      top: draggableBox.dy +
                          currentTimeSlotHeight -
                          15, // Below the bottom edge
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            // Get the scroll offset of the calendar
                            final scrollOffset = _scrollController.offset;
                            final remainingScrollableContentInView =
                                _scrollController.position.viewportDimension;
              
                            print("scrollOffset: $scrollOffset");
              
                            // Calculate the true position of the draggable box within the calendar
                            final relativeDy = draggableBox.dy + scrollOffset;
              
                            print("relativeDy: $relativeDy");
              
                            // Calculate the maximum height for the task to prevent exceeding the calendar boundary
                            final maxTaskHeight =
                                calendarWidgetBottomBoundaryY - relativeDy;
              
                            print("maxTaskHeight: $maxTaskHeight");
                            // Adjust height for bottom resizing
                            final newSize = (currentTimeSlotHeight +
                                    details.delta.dy)
                                .clamp(TimeSlotInfo.snapInterval, maxTaskHeight);
                            if (newSize >= TimeSlotInfo.snapInterval) {
                              currentTimeSlotHeight = newSize;
                            }
              
                            // Calculate the bottom position of the draggable box
                            final boxBottomPosition =
                                relativeDy + currentTimeSlotHeight;
              
                            // Calculate the visible bottom boundary of the viewport
                            final viewportBottom =
                                scrollOffset + remainingScrollableContentInView;
              
                            // Scroll if the bottom of the box goes beyond the viewport
                            if (boxBottomPosition > viewportBottom) {
                              _scrollController.animateTo(
                                scrollOffset +
                                    (boxBottomPosition - viewportBottom),
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                              );
                            }
                          });
                        },
                        onPanEnd: (_) {
                          setState(() {
                            // Snap height to the nearest interval after dragging
                            currentTimeSlotHeight = (currentTimeSlotHeight /
                                        TimeSlotInfo.snapInterval)
                                    .round() *
                                TimeSlotInfo.snapInterval;
                          });
                        },
                        child: Container(
                          width: 80,
                          height: 30,
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
    );
  }
}
