import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/custom_snackbars.dart';
import 'package:timetailor/core/shared/widgets/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/note_management/providers/note_form_provider.dart';
import 'package:timetailor/domain/note_management/providers/note_state_provider.dart';
import 'package:timetailor/domain/note_management/providers/notes_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/task_form_provider.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/add_note_button.dart';

class NotesContainer extends ConsumerStatefulWidget {
  const NotesContainer({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NotesContainerState();
}

class _NotesContainerState extends ConsumerState<NotesContainer> {
  @override
  void initState() {
    super.initState();
    final selectedTask = ref.read(selectedTaskProvider);
    if (selectedTask != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(linkedNotesProvider.notifier).state = selectedTask.linkedNotes;
      });
    }
  }

  Future<List<Map<String, String>>> fetchNoteTitles(List<String> noteIds) async {
    final noteRepository = ref.read(noteRepositoryProvider);
    List<Map<String, String>> notes = [];

    for (String noteId in noteIds) {
      final note = await noteRepository.getNoteById(noteId);
      if (note != null) {
        notes.add({"id": noteId, "title": note.title});
      }
    }

    return notes;
  }

  void viewNoteDetails(BuildContext context, String noteId) {
    CustomSnackbars.clearSnackBars();
    updateNoteDetailsState(noteId);
    context.push(RoutePath.noteCreationPath);
  }

  void updateNoteDetailsState(String noteId) async {
    final notesNotifier = ref.read(notesNotifierProvider.notifier);
    final noteFormNotifier = ref.read(noteFormNotifierProvider.notifier);
    final selectedNoteNotifier = ref.read(selectedNoteProvider.notifier);
    final noteRepository = ref.read(noteRepositoryProvider);
    final currentNote = await noteRepository.getNoteById(noteId);

    // reset note form state and state variables before viewing details.
    notesNotifier.resetAllNoteState();

    // populate state with current selected note
    selectedNoteNotifier.state = currentNote;
    noteFormNotifier.updateTitle(currentNote!.title);
    noteFormNotifier.updateContent(currentNote.content);
  }

  void handleRemoveLinkedNoteFromTask(String noteId) {
    final linkedNotesNotifier = ref.read(linkedNotesProvider.notifier);
    linkedNotesNotifier.state =
        linkedNotesNotifier.state.where((id) => id != noteId).toList();
    CustomSnackbars.shortDurationSnackBar(
        contentString: "Linked note removed.");
  }

  void showRemoveLinkedNoteConfirmation(BuildContext context, String noteId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Unlink'),
          content: const Text('Are you sure you want to unlink this note?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                handleRemoveLinkedNoteFromTask(noteId);
              },
              child: Text('Unlink',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final noteIds = ref.watch(linkedNotesProvider);
    final isViewingNoteNotifier = ref.read(isViewingNoteProvider.notifier);

    return FutureBuilder<List<Map<String, String>>>(
      future: fetchNoteTitles(noteIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Failed to load notes.'),
          );
        }

        final notes = snapshot.data ?? [];

        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 32, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StyledTitle("Notes"),
                  AddNoteButton(),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              width: screenWidth, // Container takes 80% of screen width
              height: 200, // Fixed height for the notes section
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSecondary,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey),
              ),
              child: notes.isEmpty
                  ? const Center(
                      child: Text(
                        'No notes linked to this task',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return InkWell(
                          onTap: () {
                            isViewingNoteNotifier.state = true;
                            viewNoteDetails(context, note["id"]!);
                          },
                          child: Card(
                            color: AppColors.primaryColor,
                            margin: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            elevation: 2, // Adds a shadow
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: StyledText(note["title"]!)),
                                  IconButton(
                                    icon: const Icon(Icons.cancel),
                                    onPressed: () {
                                      showRemoveLinkedNoteConfirmation(
                                          context, note["id"]!);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
