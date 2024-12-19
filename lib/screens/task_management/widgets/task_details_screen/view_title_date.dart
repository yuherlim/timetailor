import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/data/task_management/models/task.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';

class ViewTitleDate extends ConsumerWidget {
  final Task task;

  const ViewTitleDate({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startTime = ref
        .read(tasksNotifierProvider.notifier)
        .formatTime(task.startTime.hour, task.startTime.minute);
    final endTime = ref
        .read(tasksNotifierProvider.notifier)
        .formatTime(task.endTime.hour, task.endTime.minute);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 16),
              Flexible(
                child: StyledText(task.name),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 16),
              StyledText(DateFormat('d MMM').format(task.date)),
              const SizedBox(width: 16),
              StyledText("$startTime - $endTime"),
            ],
          ),
        ],
      ),
    );
  }
}
