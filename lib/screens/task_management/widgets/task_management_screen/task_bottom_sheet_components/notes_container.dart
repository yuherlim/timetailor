import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/add_note_button.dart';

class NotesContainer extends ConsumerStatefulWidget {
  const NotesContainer({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NotesContainerState();
}

class _NotesContainerState extends ConsumerState<NotesContainer> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final selectedTask = ref.read(selectedTaskProvider);
    final List<String> noteIds = selectedTask?.linkedNote ??
        [
          "note 1",
          "note 2",
          "note 2",
          "note 2",
          "note 2",
          "note 2",
          "note 2",
          "note 2",
          "note 2",
          "note 2",
          "note 2",
          "note 2"
        ];

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
          child: noteIds.isEmpty
              ? const Center(
                  child: Text(
                    'No notes linked to this task',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: noteIds.length,
                  itemBuilder: (context, index) {
                    final noteId = noteIds[index];
                    return InkWell(
                      onTap: () {
                        // Handle note tap (e.g., navigate to note details)
                        debugPrint('Tapped on note: $noteId');
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
                              StyledText(noteId),
                              IconButton(
                                icon: const Icon(Icons.cancel),
                                onPressed: () {
                                  debugPrint('Remove tapped for note: $noteId');
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
  }
}
