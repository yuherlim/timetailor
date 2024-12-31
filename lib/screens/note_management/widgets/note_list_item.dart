import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/custom_snackbars.dart';
import 'package:timetailor/core/shared/widgets/styled_text.dart';
import 'package:timetailor/data/note_management/models/note.dart';
import 'package:timetailor/domain/note_management/providers/note_form_provider.dart';
import 'package:timetailor/domain/note_management/providers/note_state_provider.dart';
import 'package:timetailor/domain/note_management/providers/notes_provider.dart';

class NoteListItem extends ConsumerWidget {
  final Note note;

  const NoteListItem({
    super.key,
    required this.note,
  });

  void viewNoteDetails(BuildContext context, WidgetRef ref) {
    CustomSnackbars.clearSnackBars();
    updateNoteDetailsState(ref);
    context.go(RoutePath.noteCreationPath);
  }

  void updateNoteDetailsState(WidgetRef ref) {
    final notesNotifier = ref.read(notesNotifierProvider.notifier);
    final noteFormNotifier = ref.read(noteFormNotifierProvider.notifier);
    final selectedNoteNotifier = ref.read(selectedNoteProvider.notifier);

    // reset note form state and state variables before viewing details.
    notesNotifier.resetAllNoteState();

    // populate state with current selected note
    selectedNoteNotifier.state = note;
    noteFormNotifier.updateTitle(note.title);
    noteFormNotifier.updateContent(note.content);
  }

  void handleEdit(BuildContext context, WidgetRef ref) {
    final isEditingNoteNotifier = ref.read(isEditingNoteProvider.notifier);

    CustomSnackbars.clearSnackBars();
    updateNoteDetailsState(ref);
    // enable editing mode
    isEditingNoteNotifier.state = true;
    context.go(RoutePath.noteCreationPath);
  }

  void handleDelete(WidgetRef ref) {
    final noteNotifier = ref.read(notesNotifierProvider.notifier);

    noteNotifier.removeNote(note);
    CustomSnackbars.longDurationSnackBarWithAction(
      contentString: "Note successfully deleted!",
      actionText: "Undo",
      onPressed: () {
        noteNotifier.undoNoteDeletion(note, showSnackBarWithMessage);
      },
    );
  }

  void showSnackBarWithMessage(String message) {
    CustomSnackbars.shortDurationSnackBar(contentString: message);
  }

  void showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                handleDelete(ref); // Execute the confirmation action
              },
              child: Text('Delete',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => viewNoteDetails(context, ref),
      child: Card(
        child: ListTile(
          title: NoteListItemTitleText(note.title),
          subtitle: NoteListItemSubtitleText(
              note.content.isEmpty ? "(No content)" : note.content),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              // Handle menu item selection
              if (value == 'Edit') {
                handleEdit(context, ref);
              } else if (value == 'Delete') {
                showDeleteConfirmation(context, ref);
              }
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
        ),
      ),
    );
  }
}
