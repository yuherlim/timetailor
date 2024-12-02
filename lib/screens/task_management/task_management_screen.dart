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
  TimeSlotInfo timeSlotInfo = TimeSlotInfo(slotHeight: 0);
  double defaultTimeSlotHeight = 0;
  DraggableBox draggableBox = DraggableBox(dx: 0, dy: 0);
  bool showDraggableBox = false;
  static const double calendarWidgetBoundaryY = 8;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenHeight = MediaQuery.of(context).size.height;

      setState(() {
        defaultTimeSlotHeight =
            screenHeight <= 800 ? 80 : 100; // Initialize time slot height
        timeSlotInfo = TimeSlotInfo(slotHeight: defaultTimeSlotHeight);
        TimeSlotInfo.slotWidth = CalendarPainter.slotWidth;
        TimeSlotInfo.pixelsPerMinute = defaultTimeSlotHeight / 60;
        TimeSlotInfo.snapInterval =
            5 * TimeSlotInfo.pixelsPerMinute; // Snap every 5 minutes
      });
    });
    super.initState();
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
    bool resizingFromTop = true;

    // if (timeSlotInfo == null) {
    //   // Return a loading spinner or placeholder until the dimensions are initialized
    //   return const Center(child: CircularProgressIndicator());
    // }

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
            child: Stack(
              children: [
                GestureDetector(
                  onTapDown: (details) {
                    final tapPosition = details.localPosition;
                    print(tapPosition);
                    if (tapPosition.dy >= calendarWidgetBoundaryY) {
                      setState(() {
                        draggableBox = DraggableBox(
                            dx: tapPosition.dx, dy: tapPosition.dy);
                        timeSlotInfo.slotHeight = defaultTimeSlotHeight;
                        showDraggableBox = true;
                      });
                    }

                    print(
                        "DraggableBox: dx = ${draggableBox.dx} dy = ${draggableBox.dy}");
                    print("showDraggableBox: $showDraggableBox");
                  },
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CalendarWidget(
                        context: this.context,
                        slotHeight: defaultTimeSlotHeight,
                      ),
                    ),
                  ),
                ),
                if (showDraggableBox)
                  Positioned(
                    left: draggableBox.dx,
                    top: draggableBox.dy,
                    child: GestureDetector(
                      onPanStart: (details) {
                        final localTapPosition = details.localPosition.dy;

                        setState(() {
                          final topThreshold = timeSlotInfo.slotHeight *
                              0.2; // Top 20% of the box
                          final bottomThreshold = timeSlotInfo.slotHeight *
                              0.8; // Bottom 20% of the box

                          if (localTapPosition <= topThreshold) {
                            // User tapped near the top border
                            resizingFromTop = true;
                            print("resizingFromTop: $resizingFromTop");
                          } else if (localTapPosition >= bottomThreshold) {
                            // User tapped near the bottom border
                            resizingFromTop = false;
                            print("resizingFromTop: $resizingFromTop");
                          } else {
                            // User tapped in the middle, do not resize
                            resizingFromTop = false;
                            print("resizingFromTop: $resizingFromTop");
                          }
                        });
                      },
                      onPanUpdate: (details) {
                        setState(() {
                          final snapInterval = TimeSlotInfo.snapInterval;

                          if (resizingFromTop) {
                            // Resizing from top
                            final newDy = draggableBox.dy + details.delta.dy;
                            final snappedDy =
                                (newDy / snapInterval).round() * snapInterval;

                            final newSize =
                                (timeSlotInfo.slotHeight - details.delta.dy)
                                    .clamp(snapInterval, double.infinity);
                            final snappedSize =
                                (newSize / snapInterval).round() * snapInterval;

                            if (snappedDy >= calendarWidgetBoundaryY &&
                                snappedSize >= snapInterval) {
                              draggableBox.dy = snappedDy;
                              timeSlotInfo = timeSlotInfo.copyWith(
                                  slotHeight: snappedSize);
                            }
                          } else {
                            // Resizing from bottom
                            final newSize =
                                (timeSlotInfo.slotHeight + details.delta.dy)
                                    .clamp(snapInterval, double.infinity);
                            final snappedSize =
                                (newSize / snapInterval).round() * snapInterval;

                            if (snappedSize >= snapInterval) {
                              // Only update the size; position remains unchanged
                              timeSlotInfo = timeSlotInfo.copyWith(
                                  slotHeight: snappedSize);
                            }
                          }
                        });
                      },
                      child: Container(
                        width: TimeSlotInfo.slotWidth, // Fixed width
                        height: timeSlotInfo
                            .slotHeight, // Dynamically adjusted height.
                        color: AppColors
                            .primaryAccent, // Semi-transparent for visibility.
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
        ],
      ),
    );
  }
}
