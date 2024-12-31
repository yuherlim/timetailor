import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/custom_snackbars.dart';
import 'package:timetailor/core/shared/widgets/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/note_management/providers/note_state_provider.dart';
import 'package:timetailor/domain/note_management/providers/notes_provider.dart';
import 'package:timetailor/screens/note_management/widgets/note_list_item.dart';
import 'package:timetailor/screens/note_management/widgets/notes_search_delegate.dart';

class NoteManagementScreen extends StatefulHookConsumerWidget {
  const NoteManagementScreen({super.key});

  @override
  ConsumerState<NoteManagementScreen> createState() =>
      _NoteManagementScreenState();
}

class _NoteManagementScreenState extends ConsumerState<NoteManagementScreen> {
  void handleAdd() {
    CustomSnackbars.clearSnackBars();
    // reset all previous note state
    ref.read(notesNotifierProvider.notifier).resetAllNoteState();
    ref.read(isCreatingNoteProvider.notifier).state = true;
    context.go(RoutePath.noteCreationPath);
  }

  void openSearch() {
    showSearch(
      context: context,
      delegate: NotesSearchDelegate(),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    final notes = ref.watch(notesNotifierProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => handleAdd(),
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        title: const AppBarText("Notes"),
        titleSpacing: 72,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: IconButton(
              onPressed: openSearch,
              icon: const Icon(Icons.search),
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          notes.isEmpty
              ? const Expanded(
                  child: Center(
                    child: NoListItemTitle(
                      "There are currently no notes.",
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return NoteListItem(note: note);
                    },
                  ),
                ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
