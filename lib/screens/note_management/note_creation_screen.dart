import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/core/config/routes.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/custom_snackbars.dart';
import 'package:timetailor/core/shared/utils.dart';
import 'package:timetailor/core/shared/widgets/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/data/note_management/models/note.dart';
import 'package:timetailor/domain/note_management/providers/note_form_provider.dart';
import 'package:timetailor/domain/note_management/providers/note_state_provider.dart';
import 'package:timetailor/domain/note_management/providers/notes_provider.dart';
import 'package:timetailor/screens/note_management/widgets/note_content_field.dart';
import 'package:timetailor/screens/note_management/widgets/note_title_field.dart';
import 'package:uuid/uuid.dart';

class NoteCreationScreen extends StatefulHookConsumerWidget {
  const NoteCreationScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NoteCreationScreenState();
}

class _NoteCreationScreenState extends ConsumerState<NoteCreationScreen> {
  void createNote() {
    final formState = ref.read(noteFormNotifierProvider);
    final formNotifier = ref.read(noteFormNotifierProvider.notifier);
    final noteNotifier = ref.read(notesNotifierProvider.notifier);
    final isEditingNote = ref.read(isEditingNoteProvider);
    final selectedNote = ref.read(selectedNoteProvider);

    if (formNotifier.validateTitle()) {
      final noteToUpdate = Note(
        id: isEditingNote ? selectedNote!.id : const Uuid().v4(),
        title: formState.title,
        content: formState.content,
      );

      if (isEditingNote && selectedNote != null) {
        noteNotifier.updateNote(noteToUpdate);
        CustomSnackbars.longDurationSnackBarWithAction(
          contentString: "Note successfully edited!",
          actionText: "Undo",
          onPressed: () => noteNotifier.updateNoteWithUndo(
              selectedNote, undoNoteEditSnackBar),
        );

        context.go(RoutePath.noteDetailsPath, extra: noteToUpdate);
      } else {
        noteNotifier.addNote(noteToUpdate);
        CustomSnackbars.longDurationSnackBarWithAction(
          contentString: "Note successfully saved!",
          actionText: "Undo",
          onPressed: () => noteNotifier.removeNoteWithUndo(
            noteToUpdate,
            undoNoteCreateSnackBar,
          ),
        );

        context.go(RoutePath.noteManagementPath);
      }

      noteNotifier.endNoteCreation();
    }
  }

  void undoNoteEditSnackBar(String message, Note noteToUndo) {
    CustomSnackbars.shortDurationSnackBar(contentString: message);
    context.go(RoutePath.noteDetailsPath, extra: noteToUndo);
  }

  void undoNoteCreateSnackBar(String message) {
    CustomSnackbars.shortDurationSnackBar(contentString: message);
  }

  @override
  Widget build(BuildContext context) {
    final noteScrollController = useScrollController();
    final isEditingNote = ref.read(isEditingNoteProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        title: AppBarText(isEditingNote ? "Edit Note" : "Create Note"),
        actions: [
          IconButton(
            onPressed: () {
              createNote();
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: noteScrollController,
        child: const Column(
          children: [
            NoteTitleField(),
            NoteContentField(),
          ],
        ),
      ),
    );
  }
}
