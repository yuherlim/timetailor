import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/widgets/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/data/task_management/models/task.dart';
import 'package:timetailor/data/note_management/models/note.dart';
import 'package:timetailor/domain/note_management/providers/note_form_provider.dart';
import 'package:timetailor/domain/note_management/providers/note_state_provider.dart';
import 'package:timetailor/domain/note_management/providers/notes_provider.dart';

class ViewNotesSection extends ConsumerWidget {
  final Task task;

  const ViewNotesSection({super.key, required this.task});

  Future<List<Note>> fetchNotesFromTaskIds(
      WidgetRef ref, List<String> noteIds) async {
    final noteRepository = ref.read(noteRepositoryProvider);
    List<Note> notes = [];

    for (String noteId in noteIds) {
      final note = await noteRepository.getNoteById(noteId);
      if (note != null) {
        notes.add(note);
      }
    }

    return notes;
  }

  void viewNoteDetails(BuildContext context, WidgetRef ref, Note note) {
    final notesNotifier = ref.read(notesNotifierProvider.notifier);
    final noteFormNotifier = ref.read(noteFormNotifierProvider.notifier);
    final selectedNoteNotifier = ref.read(selectedNoteProvider.notifier);

    // Reset note state and set selected note
    notesNotifier.resetAllNoteState();
    selectedNoteNotifier.state = note;
    noteFormNotifier.updateTitle(note.title);
    noteFormNotifier.updateContent(note.content);

    // Navigate to note details
    context.push(RoutePath.noteCreationPath);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder<List<Note>>(
      future: fetchNotesFromTaskIds(ref, task.linkedNotes),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Failed to load notes.'));
        }

        final notes = snapshot.data ?? [];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 32, right: 16, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StyledTitle("Notes"),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                width: screenWidth, // Container takes 80% of screen width
                height: 300, // Fixed height for the notes section
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onInverseSurface,
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
                            onTap: () => viewNoteDetails(context, ref, note),
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: StyledText(note.title)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
