import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/widgets/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/note_management/providers/notes_provider.dart';
import 'package:timetailor/screens/note_management/widgets/note_list_item.dart';

class NoteManagementScreen extends ConsumerStatefulWidget {
  const NoteManagementScreen({super.key});

  @override
  ConsumerState<NoteManagementScreen> createState() =>
      _NoteManagementScreenState();
}

class _NoteManagementScreenState extends ConsumerState<NoteManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final allNotes = ref.watch(notesNotifierProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go(RoutePath.noteCreationPath);
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        title: const AppBarText("Notes"),
        titleSpacing: 72,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          allNotes.isEmpty
              ? const Expanded(
                  child: Center(
                    child: TitleTextInHistory(
                      "There are currently no notes.",
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: allNotes.length,
                    itemBuilder: (context, index) {
                      final note = allNotes[index];
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
