import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:timetailor/core/constants/route_paths.dart';
import 'package:timetailor/core/shared/styled_button.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/core/theme/theme.dart';

class TaskManagementScreen extends ConsumerStatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  ConsumerState<TaskManagementScreen> createState() =>
      _TaskManagementScreenState();
}

class _TaskManagementScreenState extends ConsumerState<TaskManagementScreen> {
  late String currentMonth;
  Timer? midnightTimer;
  late List<DateTime> weekDates;
  DateTime currentSelectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    updateCurrentMonth();
    scheduleMidnightUpdate();
    updateWeekDates();
    super.initState();
  }

  @override
  void dispose() {
    midnightTimer?.cancel();
    super.dispose();
  }

  void updateCurrentMonth({DateTime? date}) {
    setState(() {
      currentMonth = date != null
          ? DateFormat('MMMM yyyy').format(date)
          : DateFormat('MMMM yyyy').format(DateTime.now());
    });
  }

  void scheduleMidnightUpdate() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = nextMidnight.difference(now);

    midnightTimer = Timer(durationUntilMidnight, () {
      updateCurrentMonth();
      scheduleMidnightUpdate(); // Reschedule for the next day
    });
  }

  void updateWeekDates({DateTime? date}) {
    // Get the current date
    final currentDate = date ?? DateTime.now();

    // Calculate the start of the current week (Monday)
    final startOfWeek =
        currentDate.subtract(Duration(days: currentDate.weekday - 1));

    // Generate a list of dates for the current week
    setState(() {
      weekDates = List.generate(7, (index) {
        final date = startOfWeek.add(Duration(days: index));
        return DateTime(date.year, date.month, date.day);
      });
    });
  }

  // void calendarButtonOnTap() {
  //   showDialog(
  //       context: context,
  //       builder: (ctx) {
  //         return AlertDialog(
  //           title: const StyledHeading("Choose a date."),
  //           content: const StyledText(
  //               "Every good RPG character needs a great name..."),
  //           actions: [
  //             StyledButton(
  //               onPressed: () {
  //                 context.pop();
  //               },
  //               child: const StyledHeading("CLOSE"),
  //             ),
  //           ],
  //           actionsAlignment: MainAxisAlignment.center,
  //         );
  //       });
  // }

  void calendarButtonOnTap({required DateTime date}) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      // Handle the selected date
      updateCurrentSelectedDate(date: selectedDate);
      updateCurrentMonth(date: selectedDate);
      updateWeekDates(date: currentSelectedDate);
    }
  }

  void updateCurrentSelectedDate({required DateTime date}) {
    setState(() {
      currentSelectedDate = DateTime(date.year, date.month, date.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go(taskCreationPath);
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
        title: StyledTitle(currentMonth),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              updateUIToToday();
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: weekDates.map((date) {
                return GestureDetector(
                  onTap: () {
                    updateCurrentSelectedDate(date: date);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: currentSelectedDate == date
                          ? AppColors.primaryColor
                          : AppColors.secondaryColor,
                    ),
                    child: Column(
                      children: [
                        StyledHeading(
                          DateFormat('EEE').format(date), // Day of the week
                        ),
                        StyledHeading(
                          date.day.toString(), // Date
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Task List with Time Indicator
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 10, // Example number of tasks
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: StyledText("Task ${index + 1}"),
                        subtitle: const StyledText("9:00 AM - 10:00 AM"),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.check_circle_outline,
                            color: AppColors.textColor,
                          ),
                          onPressed: () {
                            // Mark task as completed
                          },
                        ),
                        onTap: () {
                          // Navigate to Task Details Screen
                          Navigator.pushNamed(context, '/details');
                        },
                      ),
                    );
                  },
                ),
                // Current Time Indicator
                const Positioned(
                  top: 100, // Dynamically calculate this position
                  left: 0,
                  right: 0,
                  child: Row(
                    children: [
                      SizedBox(width: 10),
                      Icon(Icons.access_time, color: Colors.red),
                      SizedBox(width: 10),
                      Expanded(
                        child: Divider(
                          color: Colors.red,
                          thickness: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void updateUIToToday() {
    updateWeekDates();
    updateCurrentMonth();
    updateCurrentSelectedDate(date: DateTime.now());
  }
}
