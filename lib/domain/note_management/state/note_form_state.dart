class NoteFormState {
  final String title;
  final String? titleError;
  final String content;


  NoteFormState(
    {
      required this.title,
      this.titleError,
      required this.content,
    }
  );

  NoteFormState copyWith({
    String? title,
    String? titleError,
    String? content,
  }) {
    return NoteFormState(
      title: title ?? this.title,
      titleError: titleError,
      content: content ?? this.content,
    );
  }
}