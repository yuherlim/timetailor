import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/custom_snackbars.dart';
import 'package:timetailor/data/note_management/models/note.dart';
import 'package:timetailor/domain/note_management/providers/note_form_provider.dart';
import 'package:timetailor/domain/note_management/providers/note_state_provider.dart';
import 'package:timetailor/domain/note_management/providers/notes_provider.dart';
import 'package:timetailor/domain/note_management/state/note_form_state.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => viewNoteDetails(context, ref),
      child: Card(
        child: ListTile(
          title: Text(
            note.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          subtitle: Text(
            note.content.isEmpty ? "(No content)" : note.content,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              // Handle menu item selection
              if (value == 'Edit') {
                // Example action: Clear history logic
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
        ),
      ),
    );
  }
}
