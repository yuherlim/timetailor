import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/data/task_management/models/task.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';

class ViewDescription extends ConsumerWidget {
  final Task task;

  const ViewDescription({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StyledTitle("Description"),
          Text(task.description.isEmpty ? "(No Description)" : task.description),
        ],
      ),
    );
  }
}