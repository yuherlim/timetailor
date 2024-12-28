import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timetailor/domain/note_management/state/note_form_state.dart';

part 'note_form_provider.g.dart';

@Riverpod(keepAlive: true)
class NoteFormNotifier extends _$NoteFormNotifier {
  @override
  NoteFormState build() {
    print("note form state is built");
    return NoteFormState(title: "", content: "");
  }

  void resetState() {
    state = state.copyWith(title: "", content: "");
  }

  void updateTitle(String value) {
    state = state.copyWith(title: value, titleError: null);
  }

  void updateContent(String value) {
    state = state.copyWith(content: value);
  }

  bool validateTitle() {
    if (state.title.trim().isEmpty) {
      state = state.copyWith(titleError: 'Title cannot be empty');
      return false;
    }
    return true;
  }
}
