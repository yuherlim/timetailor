class TaskFormState {
  final String taskName;
  final String? errorText;
  final bool isFormValid;

  TaskFormState({
    this.taskName = "",
    this.errorText,
    this.isFormValid = false,
  });

  TaskFormState copyWith({
    String? taskName,
    String? errorText,
    bool? isFormValid,
  }) {
    return TaskFormState(
      taskName: taskName ?? this.taskName,
      errorText: errorText,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }
}
