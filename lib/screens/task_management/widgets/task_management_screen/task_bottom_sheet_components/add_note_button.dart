import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/core/shared/custom_snackbars.dart';
import 'package:timetailor/core/shared/widgets/styled_button.dart';
import 'package:timetailor/core/shared/widgets/styled_text.dart';
import 'package:timetailor/data/note_management/models/note.dart';
import 'package:timetailor/domain/note_management/providers/notes_provider.dart';
import 'package:timetailor/domain/task_management/providers/task_form_provider.dart';
import 'package:timetailor/domain/user_management/providers/user_provider.dart';

class AddNoteButton extends ConsumerStatefulWidget {
  const AddNoteButton({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddNoteButtonState();
}

class _AddNoteButtonState extends ConsumerState<AddNoteButton> {
  Future<List<Note>> filterOutLinkedNotes(
      List<String> noteIdsToFilterOut) async {
    final currentLoggedInUser = ref.read(currentUserProvider);
    final noteRepository = ref.read(noteRepositoryProvider);

    if (currentLoggedInUser == null) {
      throw Exception("No user is logged in.");
    }

    final allNotes =
        await noteRepository.getNotesByUserId(currentLoggedInUser.id);

    // Filter out the notes whose IDs are in the noteIdsToRemove list
    final filteredNotes = allNotes
        .where(
            (note) => !noteIdsToFilterOut.contains(note.id)) // Filter out notes
        .toList();

    return filteredNotes;
  }

  @override
  Widget build(BuildContext context) {
    final linkedNotesNotifier = ref.read(linkedNotesProvider.notifier);
    final linkedNotes = ref.watch(linkedNotesProvider);

    return StyledButton(
      onPressed: () async {
        try {
          final notesToChooseFrom = await filterOutLinkedNotes(linkedNotes);

          if (notesToChooseFrom.isEmpty) {
            CustomSnackbars.shortDurationSnackBar(
                contentString: "No notes available to link.");
            return;
          }

          showModalBottomSheet(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (context) {
              return ListView.builder(
                itemCount: notesToChooseFrom.length,
                itemBuilder: (context, index) {
                  final note = notesToChooseFrom[index];
                  return ListTile(
                    title: Text(note.title),
                    onTap: () {
                      linkedNotesNotifier.state = [
                        ...linkedNotesNotifier.state,
                        note.id
                      ];
                      CustomSnackbars.shortDurationSnackBar(
                          contentString: "${note.title} linked to this task.");
                      Navigator.pop(context); // Close the modal
                    },
                  );
                },
              );
            },
          );
        } catch (e) {
          CustomSnackbars.shortDurationSnackBar(
              contentString: "Failed to fetch notes: $e");
        }
      },
      child: const ButtonText("Add note"),
    );
  }
}
