import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timetailor/data/task_management/models/task.dart';

part 'tasks_provider.g.dart'; // Generated file

@riverpod
class TasksNotifier extends _$TasksNotifier {
  @override
  List<Task> build() {
    return tasks;
  }

  void addTask(Task task) {
    state = [...state, task];
  }

  void updateTask(Task task) {
    state = state.map((currentTask) {
      // Replace the task with the updatedTask if the IDs match
      return task.id == currentTask.id ? task : currentTask;
    }).toList();
  }

  void removeTask(Task task) {
    state = state.where((currentTask) => currentTask != task).toList();
  }

  // these methods are to be converted to use firestore later.

  //fetchTasksOnce
}
