import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:timetailor/core/constants/route_paths.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/task_management/providers/datebox_animation_provider.dart';
import 'package:timetailor/domain/task_management/providers/task_management_provider.dart';
import 'package:timetailor/screens/task_management/widgets/calendar_header.dart';

class TaskManagementScreen extends ConsumerStatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  ConsumerState<TaskManagementScreen> createState() =>
      _TaskManagementScreenState();
}

class _TaskManagementScreenState extends ConsumerState<TaskManagementScreen> {
  // Timer? midnightTimer;
  // late String currentMonth;
  // late List<DateTime> weekDates;
  // DateTime currentSelectedDate = todayDate();

  // static DateTime todayDate() {
  //   return DateTime(
  //       DateTime.now().year, DateTime.now().month, DateTime.now().day);
  // }

  // @override
  // void initState() {
  //   // updateCurrentMonth();
  //   // scheduleMidnightUpdate();
  //   // updateWeekDates();
  //   super.initState();
  // }

  // @override
  // void dispose() {
  //   midnightTimer?.cancel();
  //   super.dispose();
  // }

  // void updateCurrentMonth({DateTime? date}) {
  //   setState(() {
  //     currentMonth = date != null
  //         ? DateFormat('MMMM yyyy').format(date)
  //         : DateFormat('MMMM yyyy').format(DateTime.now());
  //   });
  // }

  // void scheduleMidnightUpdate() {
  //   final now = DateTime.now();
  //   final nextMidnight = DateTime(now.year, now.month, now.day + 1);
  //   final durationUntilMidnight = nextMidnight.difference(now);

  //   midnightTimer = Timer(durationUntilMidnight, () {
  //     updateCurrentMonth();
  //     scheduleMidnightUpdate(); // Reschedule for the next day
  //   });
  // }

  // void updateWeekDates({DateTime? date}) {
  //   // Get the current date
  //   final currentDate = date ?? DateTime.now();

  //   // Calculate the start of the current week (Monday)
  //   final startOfWeek =
  //       currentDate.subtract(Duration(days: currentDate.weekday - 1));

  //   // Generate a list of dates for the current week
  //   setState(() {
  //     weekDates = List.generate(7, (index) {
  //       final date = startOfWeek.add(Duration(days: index));
  //       return DateTime(date.year, date.month, date.day);
  //     });
  //   });
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
      ref.read(currentDateNotifierProvider.notifier).updateDate(date: selectedDate);
      triggerDateBoxRipple(date: ref.watch(currentDateNotifierProvider));
    }
  }

  // void updateCurrentSelectedDate({required DateTime date}) {
  //   setState(() {
  //     currentSelectedDate = DateTime(date.year, date.month, date.day);
  //   });
  // }

  // void updateUIToToday() {
  //   final today = todayDate();

  //   // Update UI to today
  //   updateCurrentMonth();
  //   updateWeekDates();
  //   updateCurrentSelectedDate(date: today);
  // }

  void triggerDateBoxRipple({required DateTime date}) {
    final weekDates = ref.watch(currentWeekDatesNotifierProvider);

    //initialize global keys for dateboxes.
    ref
        .read(dateboxAnimationNotifierProvider.notifier)
        .initializeKeys(weekDates);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Trigger the ripple effect for today's date after widget rebuild.
      ref
          .read(dateboxAnimationNotifierProvider.notifier)
          .triggerRipple(date, context);
    });
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
            calendarButtonOnTap(date: );
          },
        ),
        title: AppBarText(currentMonth),
        centerTitle: true,
        actions: [
          if (!ref.read(currentDateNotifierProvider.notifier).currentDateIsToday())
            IconButton(
              icon: const Icon(Icons.today),
              onPressed: () {
                updateUIToToday();
                triggerDateBoxRipple();
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
          CalendarHeader(
            weekDates: weekDates,
            currentSelectedDate: currentSelectedDate,
            onDateSelected: (date) {
              // Update selected date and trigger ripple
              updateCurrentSelectedDate(date: date);
            },
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
}
