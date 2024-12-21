import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/custom_snackbars.dart';
import 'package:timetailor/data/note_management/models/note.dart';

class NoteListItem extends ConsumerWidget {
  final Note note;

  const NoteListItem({
    super.key,
    required this.note,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        CustomSnackbars.clearSnackBars();
        context.go(RoutePath.noteDetailsPath, extra: note);
      },
      child: Card(
        child: ListTile(
          title: Text(
            note.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            note.content,
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
