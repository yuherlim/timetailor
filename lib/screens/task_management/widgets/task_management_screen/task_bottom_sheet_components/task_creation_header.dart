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

class TaskCreationHeader extends ConsumerStatefulWidget {
  const TaskCreationHeader({super.key});

  @override
  ConsumerState<TaskCreationHeader> createState() => _TaskCreationHeaderState();
}

class _TaskCreationHeaderState extends ConsumerState<TaskCreationHeader> {
  void addTask(Task taskToAdd) {
    final taskNotifier = ref.read(tasksNotifierProvider.notifier);

    taskNotifier.addTask(taskToAdd);

    CustomSnackbars.longDurationSnackBarWithAction(
      contentString: "Task created.",
      actionText: "Undo",
      onPressed: () => taskNotifier.undoTaskCreation(taskToAdd),
    );
  }

  void updateTask(Task taskToUpdate) {
    final taskNotifier = ref.read(tasksNotifierProvider.notifier);
    final taskToUndo = ref.read(selectedTaskProvider)!;
    final selectedTaskNotifier = ref.read(selectedTaskProvider.notifier);
    final editTaskSuccessNotifier =
        ref.read(isEditingTaskSuccessProvider.notifier);

    print("task to undo name: ${taskToUndo.name}");

    editTaskSuccessNotifier.state = true;
    // add the newly edited task
    taskNotifier.addTask(taskToUpdate);

    // reset current selected task to null
    selectedTaskNotifier.state = null;

    CustomSnackbars.longDurationSnackBarWithAction(
      contentString: "Task updated.",
      actionText: "Undo",
      onPressed: () => taskNotifier.undoTaskEdit(taskToUndo),
    );
  }

  @override
  Widget build(BuildContext context) {
final dyTop = ref.watch(localDyProvider);
    final dyBottom = ref.watch(localDyBottomProvider);
    final isEditingTask = ref.watch(isEditingTaskProvider);
    final selectedTask = ref.watch(selectedTaskProvider);

    final taskNotifier = ref.read(tasksNotifierProvider.notifier);
    final formNotifier = ref.read(taskFormNotifierProvider.notifier);
    final taskFormState = ref.watch(taskFormNotifierProvider);
    final startTimeEndTime = taskNotifier.getStartTimeEndTimeInDateTime();
    final id = isEditingTask && selectedTask != null ? selectedTask.id : uuid.v4();
    final name = taskFormState.name;
    final description = taskFormState.description;
    final date = ref.watch(currentDateNotifierProvider);
    final duration = taskNotifier.calculateDurationInMinutes();
    final startTime = startTimeEndTime["startTime"]!;
    final endTime = startTimeEndTime["endTime"]!;
    const isCompleted = false;
    final List<String> linkedNote = [];

    

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              // Close bottom sheet
              ref.read(tasksNotifierProvider.notifier).endTaskCreation();
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
                id: id,
                name: name,
                description: description,
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
                taskNotifier.endTaskCreation();
                return;
              }

              if (isEditingTask) {
                updateTask(taskToSave);
              } else {
                addTask(taskToSave);
              }

              taskNotifier.endTaskCreation();
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
