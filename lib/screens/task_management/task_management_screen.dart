import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timetailor/core/constants/route_paths.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/task_management/providers/task_management_provider.dart';
import 'package:timetailor/screens/task_management/widgets/calendar_header.dart';

class TaskManagementScreen extends ConsumerStatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  ConsumerState<TaskManagementScreen> createState() =>
      _TaskManagementScreenState();
}

class _TaskManagementScreenState extends ConsumerState<TaskManagementScreen> {
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
