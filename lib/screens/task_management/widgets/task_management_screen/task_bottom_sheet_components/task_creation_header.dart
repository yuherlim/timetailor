import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';

class TaskCreationHeader extends ConsumerWidget {
  const TaskCreationHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              // Close bottom sheet
              ref.read(tasksNotifierProvider.notifier).cancelTaskCreation();
            },
          ),
          FilledButton.tonal(
            onPressed: () {
              // Save action
              FocusScope.of(context).unfocus();
              debugPrint('Save button pressed');
            },
            child: const Text(
              'Save',
              
            ),
          ),
        ],
      ),
    );
  }
}
