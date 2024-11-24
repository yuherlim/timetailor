import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timetailor/core/constants/route_paths.dart';
import 'package:timetailor/core/shared/styled_text.dart';

class TaskManagementScreen extends ConsumerStatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  ConsumerState<TaskManagementScreen> createState() =>
      _TaskManagementScreenState();
}

class _TaskManagementScreenState extends ConsumerState<TaskManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const StyledHeading("September 2024"),
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
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7, // Example for a week
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Update the selected date
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: index == 0
                          ? Colors.blue // Highlight the selected date
                          : Colors.grey[300],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Mon", // Day of the week
                          style: TextStyle(
                            color: index == 0 ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          "23", // Date
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: index == 0 ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
                        title: Text("Task ${index + 1}"),
                        subtitle: Text("9:00 AM - 10:00 AM"),
                        trailing: IconButton(
                          icon: const Icon(Icons.check_circle_outline),
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
