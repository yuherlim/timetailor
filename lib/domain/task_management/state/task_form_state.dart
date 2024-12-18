class TaskFormState {
  final String name;
  final String? nameError;
  final String description;

  TaskFormState({
    required this.name,
    this.nameError,
    required this.description,
  });

  TaskFormState copyWith({
    String? name,
    String? nameError,
    String? description,
  }) {
    return TaskFormState(
      name: name ?? this.name,
      nameError: nameError,
      description: description ?? this.description,
    );
  }
}
