import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timetailor/core/constants/route_paths.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/data/task_management/models/draggable_box.dart';
import 'package:timetailor/domain/task_management/providers/task_management_provider.dart';
import 'package:timetailor/screens/task_management/widgets/calendar_header.dart';
import 'package:timetailor/screens/task_management/widgets/calendar_widget.dart';

class TaskManagementScreen extends ConsumerStatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  ConsumerState<TaskManagementScreen> createState() =>
      _TaskManagementScreenState();
}

class _TaskManagementScreenState extends ConsumerState<TaskManagementScreen> {
  double? draggableBoxSize;
  DraggableBox draggableBox = DraggableBox(dx: 0, dy: 0);
  bool showDraggableBox = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenHeight = MediaQuery.of(context).size.height;

      setState(() {
        draggableBoxSize =
            screenHeight <= 800 ? 40 : 50; // Initialize draggableBoxSize
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

    if (draggableBoxSize == null) {
      // Return a loading spinner or placeholder until the dimensions are initialized
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(builder: (context, constraints) {
      // Get the screen width
      double screenWidth = MediaQuery.of(context).size.width;
      double screenHeight = MediaQuery.of(context).size.height;

      // slot width
      final double slotWidth = screenWidth * 0.75;
      //slot height
      final double slotHeight = screenHeight <= 800 ? 40 : 50; 

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
                  ref
                      .read(currentDateNotifierProvider.notifier)
                      .updateToToday();
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
                      setState(() {
                        draggableBox = DraggableBox(
                            dx: tapPosition.dx, dy: tapPosition.dy);
                        draggableBoxSize = slotHeight;
                        showDraggableBox = true;
                      });
                      print(
                          "DraggableBox: dx = ${draggableBox.dx} dy = ${draggableBox.dy}");
                      print("showDraggableBox: $showDraggableBox");
                    },
                    child: const SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CalendarWidget(),
                      ),
                    ),
                  ),
                  if (showDraggableBox)
                    Positioned(
                      left: draggableBox.dx,
                      top: draggableBox.dy,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            print(
                                "DraggableBox: dx = ${draggableBox.dx} dy = ${draggableBox.dy}");
                            draggableBoxSize = (draggableBoxSize! + details.delta.dy).clamp(5.0, double.infinity);
                            // Adjust the box size dynamically.
                          });
                        },
                        child: Container(
                          width: slotWidth, // Fixed width
                          height:
                              draggableBoxSize, // Dynamically adjusted height.
                          color: AppColors.primaryAccent, // Semi-transparent for visibility.
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
    });
  }
}
