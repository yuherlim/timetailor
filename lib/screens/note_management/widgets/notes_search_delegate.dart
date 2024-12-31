import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/shared/widgets/styled_text.dart';
import 'package:timetailor/domain/note_management/providers/notes_provider.dart';
import 'package:timetailor/screens/note_management/widgets/note_list_item.dart';

// SearchDelegate Implementation
class NotesSearchDelegate extends SearchDelegate {
  NotesSearchDelegate();

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.only(right: 24.0),
        child: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = ''; // Clear the search query
          },
        ),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Close the search view
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final notes = ref.watch(notesNotifierProvider);
        final results = notes.where((note) {
          final titleMatch =
              note.title.toLowerCase().contains(query.toLowerCase());
          final contentMatch =
              note.content.toLowerCase().contains(query.toLowerCase());
          return titleMatch || contentMatch;
        }).toList();

        if (results.isEmpty) {
          return const Center(
            child: Text("No notes match your search."),
          );
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final note = results[index];
            return NoteListItem(note: note);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final notes = ref.watch(notesNotifierProvider);
        final suggestions = notes.where((note) {
          final titleMatch =
              note.title.toLowerCase().contains(query.toLowerCase());
          final contentMatch =
              note.content.toLowerCase().contains(query.toLowerCase());
          return titleMatch || contentMatch;
        }).toList();

        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final note = suggestions[index];
            return ListTile(
              title: NoteListItemTitleText(note.title),
              subtitle: NoteListItemSubtitleText(
                  note.content.isEmpty ? "(No content)" : note.content),
              onTap: () {
                query = note.title; // Update query with selected suggestion
                showResults(context); // Show results based on suggestion
              },
            );
          },
        );
      },
    );
  }
}
