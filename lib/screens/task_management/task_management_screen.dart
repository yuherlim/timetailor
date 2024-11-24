import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:timetailor/core/constants/route_paths.dart';
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
  DateTime currentSelectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    _updateCurrentMonth();
    _scheduleMidnightUpdate();
    super.initState();
  }

  @override
  void dispose() {
    midnightTimer?.cancel();
    super.dispose();
  }

  void _updateCurrentMonth() {
    setState(() {
      currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());
    });
  }

  void _scheduleMidnightUpdate() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = nextMidnight.difference(now);

    midnightTimer = Timer(durationUntilMidnight, () {
      _updateCurrentMonth();
      _scheduleMidnightUpdate(); // Reschedule for the next day
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the current date
    final now = DateTime.now();

    // Calculate the start of the current week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    // Generate a list of dates for the current week
    final weekDates = List.generate(7, (index) {
      final date = startOfWeek.add(Duration(days: index));
      return DateTime(date.year, date.month, date.day);
    });

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go(taskCreationPath);
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: StyledTitle(currentMonth),
        centerTitle: true,
        actions: [
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
                    setState(() {
                      currentSelectedDate = date;
                    });
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
                          // style: TextStyle(
                          //   color: isSelected ? AppColors.titleColor : Colors.black,
                          // ),
                        ),
                        StyledHeading(
                          date.day.toString(), // Date
                          // style: TextStyle(
                          //   fontWeight: FontWeight.bold,
                          //   color: isSelected ? Colors.white : Colors.black,
                          // ),
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
                          icon: Icon(Icons.check_circle_outline, color: AppColors.textColor,),
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
}
