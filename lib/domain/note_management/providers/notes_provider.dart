import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timetailor/data/note_management/models/note.dart';
import 'package:timetailor/domain/note_management/providers/note_form_provider.dart';
import 'package:timetailor/domain/note_management/providers/note_state_provider.dart';

part 'notes_provider.g.dart';

@riverpod
class NotesNotifier extends _$NotesNotifier {
  @override
  List<Note> build() {
    return notes;
  }

  List<Note> getAllNotes() {
    return state;
  }

  void addNote(Note note) {
    state = [...state, note];
  }

  void updateNote(Note updatedNote) {
    state = state
        .map((currentNote) =>
            currentNote.id == updatedNote.id ? updatedNote : currentNote)
        .toList();
  }

  void undoNoteUpdate(
      Note updatedNote, Function(String) snackBarAfterUndo) {
    final noteFormStateNotifier = ref.read(noteFormNotifierProvider.notifier);

    updateNote(updatedNote);
    // update the note form state with the previous note data.
    noteFormStateNotifier.updateContent(updatedNote.content); 
    noteFormStateNotifier.updateTitle(updatedNote.title);

    snackBarAfterUndo("Note changes is reverted.");
  }

  void removeNote(Note note) {
    state = state.where((currentNote) => currentNote != note).toList();
  }

  void undoNoteAddition(Note note, Function(String) snackBarAfterUndo) {
    removeNote(note);
    snackBarAfterUndo("Note is removed.");
  }

  void resetAllNoteState() {
    ref.read(noteFormNotifierProvider.notifier).resetState();
    ref.read(isCreatingNoteProvider.notifier).state = false;
    ref.read(isEditingNoteProvider.notifier).state = false;
    ref.read(isUndoEditingNoteProvider.notifier).state = false;
    ref.read(selectedNoteProvider.notifier).state = null;
  }
}

// to be removed in production
final notes = [
  Note(
    id: 'note1',
    title: 'My Vacation Plans',
    content: "Places to visit:\n- Malaysia's beach\n- Japan's cherry blossoms",
  ),
  Note(
    id: 'note2',
    title: 'Grocery List',
    content: "Items to buy:\n- Milk\n- Bread\n- Eggs\n- Coffee",
  ),
  Note(
    id: 'note3',
    title: 'Meeting Notes',
    content:
        "Project discussion:\n- Milestone 1 deadline: Jan 15\n- Assign tasks to team",
  ),
  Note(
    id: 'note4',
    title: 'Workout Plan',
    content:
        "Daily schedule:\n- Monday: Cardio\n- Tuesday: Strength Training\n- Wednesday: Yoga",
  ),
  Note(
    id: 'note5',
    title: 'Recipe: Pancakes',
    content:
        "Ingredients:\n- 1 cup flour\n- 2 tbsp sugar\n- 1 egg\n- 1 cup milk\nSteps:\n1. Mix ingredients\n2. Cook on a hot griddle",
  ),
];
