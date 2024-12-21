import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/widgets/content_divider.dart';
import 'package:timetailor/core/shared/widgets/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/data/note_management/models/note.dart';
import 'package:timetailor/domain/note_management/providers/note_form_provider.dart';
import 'package:timetailor/domain/note_management/providers/note_state_provider.dart';

class NoteDetailsScreen extends StatefulHookConsumerWidget {
  final Note note;

  const NoteDetailsScreen({
    super.key,
    required this.note,
  });

  @override
  ConsumerState<NoteDetailsScreen> createState() => _NoteDetailsScreenState();
}

class _NoteDetailsScreenState extends ConsumerState<NoteDetailsScreen> {
  void handleEdit() {
    // update flag
    ref.read(isEditingNoteProvider.notifier).state = true;

    // populate selected data
    ref.read(selectedNoteProvider.notifier).state = widget.note;
    final selectedNote = ref.read(selectedNoteProvider)!;
    final noteFormNotifier = ref.read(noteFormNotifierProvider.notifier);
    noteFormNotifier.updateTitle(selectedNote.title);
    noteFormNotifier.updateContent(selectedNote.content);

    print("note name: ${ref.read(noteFormNotifierProvider).title}");
    print("note content: ${ref.read(noteFormNotifierProvider).content}");

    // navigate to start edit note.
    context.go(RoutePath.noteCreationPath);
  }

  @override
  Widget build(BuildContext context) {
    final noteScrollController = useScrollController();
    ref.watch(noteFormNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        title: const AppBarText("Note Details"),
        actions: [
          PopupMenuButton<String>(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NoteTitleText(widget.note.title),
            const ContentDivider(),
            NoteContentText(widget.note.content),
          ],
        ),
      ),
    );
  }
}
