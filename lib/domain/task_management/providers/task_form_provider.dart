import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timetailor/domain/task_management/state/task_form_state.dart';

part 'task_form_provider.g.dart';

@riverpod
class TaskFormNotifier extends _$TaskFormNotifier {
  @override
  TaskFormState build() {
    return TaskFormState();
  }

  void updateTaskName(String value) {
    if (value.trim().isEmpty) {
      state = state.copyWith(
        taskName: value,
        errorText: "Title cannot be empty",
        isFormValid: false,
      );
    } else {
      state = state.copyWith(
        taskName: value.trim(),
        errorText: null,
        isFormValid: true,
      );
    }
  }

  void clearTaskName() {
    state = TaskFormState(
      taskName: "",
      errorText: "Title cannot be empty",
      isFormValid: false,
    );
  }
}
