import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timetailor/domain/task_management/state/task_form_state.dart';

part 'task_form_provider.g.dart';

@riverpod
class TaskFormNotifier extends _$TaskFormNotifier {
  @override
  TaskFormState build() {
    return TaskFormState(name: '', description: '');
  }

  void clearName() {
    state = state.copyWith(name: '');
  }

  void clearDescription() {
    state = state.copyWith(description: '');
  }

  // Update title value and validate
  void updateName(String value) {
    state = state.copyWith(name: value, nameError: null);
  }

  // Update description value and validate
  void updateDescription(String value) {
    state = state.copyWith(description: value);
  }

  // Validate form fields
  bool validate() {
    bool isValid = true;

    isValid = validateTaskName();

    return isValid;
  }

  bool validateTaskName() {
    if (state.name.trim().isEmpty) {
      print("validate task name ran.");
      state = state.copyWith(nameError: 'Title cannot be empty');
      return false;
    }
    return true;
  }
}
