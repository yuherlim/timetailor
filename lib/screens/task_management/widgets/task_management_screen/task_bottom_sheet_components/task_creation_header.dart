import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/shared/custom_snackbars.dart';
import 'package:timetailor/data/task_management/models/task.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/date_provider.dart';
import 'package:timetailor/domain/task_management/providers/task_form_provider.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class TaskCreationHeader extends ConsumerWidget {
  const TaskCreationHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskNotifier = ref.read(tasksNotifierProvider.notifier);
    final formNotifier = ref.read(taskFormNotifierProvider.notifier);
    final taskFormState = ref.watch(taskFormNotifierProvider);
    final startTimeEndTime = taskNotifier.getStartTimeEndTimeInDateTime();
    final name = taskFormState.name;
    final date = ref.watch(currentDateNotifierProvider);
    final duration = taskNotifier.calculateDurationInMinutes();
    final startTime = startTimeEndTime["startTime"]!;
    final endTime = startTimeEndTime["endTime"]!;
    const isCompleted = false;
    final List<String> linkedNote = [];

    final dyTop = ref.watch(localDyProvider);
    final dyBottom = ref.watch(localDyBottomProvider);

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
              // add validation
              FocusScope.of(context).unfocus();
              if (!formNotifier.validate()) {
                return;
              }
              final taskToSave = Task(
                id: uuid.v4(),
                name: name,
                date: date,
                startTime: startTime,
                duration: duration,
                endTime: endTime,
                isCompleted: isCompleted,
                linkedNote: linkedNote,
              );

              if (!taskNotifier.checkAddTaskValidity(
                  dyTop: dyTop, dyBottom: dyBottom)) {
                CustomSnackbars.shortDurationSnackBar(
                    contentString: "Task overlap detected. Task not created.");
                taskNotifier.cancelTaskCreation();
                return;
              }

              taskNotifier.addTask(taskToSave);
              CustomSnackbars.shortDurationSnackBar(contentString: "Task created.");
              taskNotifier.cancelTaskCreation();
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
