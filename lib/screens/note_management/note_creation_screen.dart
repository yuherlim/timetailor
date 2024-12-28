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
    final isEditingNoteNotifier = ref.read(isEditingNoteProvider.notifier);
    final isCreatingNoteNotifier = ref.read(isCreatingNoteProvider.notifier);
    final isEditingNote = ref.read(isEditingNoteProvider);
    final isCreatingNote = ref.read(isCreatingNoteProvider);
    final selectedNote = ref.read(selectedNoteProvider);

    if (formNotifier.validateTitle()) {
      final noteToUpdate = Note(
        id: isCreatingNote ? const Uuid().v4() : selectedNote!.id,
        title: formState.title,
        content: formState.content,
      );

      if (isEditingNote && selectedNote != null) {
        noteNotifier.updateNote(noteToUpdate);
        isEditingNoteNotifier.state = false;
        CustomSnackbars.longDurationSnackBarWithAction(
          contentString: "Note successfully edited!",
          actionText: "Undo",
          onPressed: () =>
              noteNotifier.undoNoteUpdate(selectedNote, snackBarAfterUndo),
        );
      } else {
        noteNotifier.addNote(noteToUpdate);
        isCreatingNoteNotifier.state = false;
        CustomSnackbars.longDurationSnackBarWithAction(
          contentString: "Note successfully saved!",
          actionText: "Undo",
          onPressed: () {
            noteNotifier.undoNoteAddition(noteToUpdate, snackBarAfterUndo);
            if (mounted) {
              context.go(RoutePath.noteManagementPath);
            }
          },
        );
      }
    }
  }

  void snackBarAfterUndo(String message) {
    CustomSnackbars.shortDurationSnackBar(contentString: message);
  }

  void handleEdit() {
    // update flag
    ref.read(isEditingNoteProvider.notifier).state = true;

    print("note name: ${ref.read(noteFormNotifierProvider).title}");
    print("note content: ${ref.read(noteFormNotifierProvider).content}");

    // navigate to start edit note.
    context.go(RoutePath.noteCreationPath);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(notesNotifierProvider);
    final noteScrollController = useScrollController();
    final isEditingNote = ref.watch(isEditingNoteProvider);
    final isCreatingNote = ref.watch(isCreatingNoteProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        title: AppBarText(isCreatingNote
            ? "Create Note"
            : isEditingNote
                ? "Editing Note"
                : "Note Details"),
        actions: [
          isEditingNote || isCreatingNote
              ? IconButton(
                  onPressed: () {
                    createNote();
                  },
                  icon: const Icon(Icons.save),
                )
              : PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    // Handle menu item selection
                    if (value == 'Edit') {
                      handleEdit();
                    } else if (value == 'Delete') {}
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'Edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Delete',
                        child: Text('Delete'),
                      ),
                    ];
                  },
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
