import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timetailor/core/shared/custom_snackbars.dart';
import 'package:timetailor/data/note_management/models/note.dart';
import 'package:timetailor/data/note_management/repositories/note_repository.dart';
import 'package:timetailor/data/task_management/models/task.dart';
import 'package:timetailor/domain/note_management/providers/note_form_provider.dart';
import 'package:timetailor/domain/note_management/providers/note_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';
import 'package:timetailor/domain/user_management/providers/user_provider.dart';

part 'notes_provider.g.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository();
});

@riverpod
class NotesNotifier extends _$NotesNotifier {
  NoteRepository get _noteRepository => ref.read(noteRepositoryProvider);
  String get _currentUserId => ref.read(currentUserProvider)!.id;

  bool isLoading = false; // Add loading state

  @override
  List<Note> build() {
    return [];
  }

  Future<void> fetchNotesFromFirestore() async {
    isLoading = true; // Start loading
    try {
      final notes = await _noteRepository.getNotesByUserId(_currentUserId);
      state = notes;
    } catch (e) {
      CustomSnackbars.shortDurationSnackBar(
          contentString: "Failed to fetch notes: $e");
    } finally {
      isLoading = false; // End loading
    }
  }

  Future<void> addNote(Note note) async {
    // Optimistically update local state
    final previousState = state;
    state = [...state, note];

    try {
      await _noteRepository.addNote(note); // Sync to Firestore
    } catch (e) {
      // Roll back local state if Firebase operation fails
      state = previousState;
      CustomSnackbars.shortDurationSnackBar(
          contentString: "Failed to add note: $e");
    }
  }

  Future<void> undoNoteDeletion(
      Note note, Function(String) snackBarAfterUndo) async {
    final taskRepository = ref.read(taskRepositoryProvider);

    try {
      // Restore the note
      addNote(note);

      // Retrieve cached tasks that referenced the note before deletion
      final tasksWithNote =
          ref.read(deletedNoteTasksProvider.notifier).state[note.id] ?? [];

      // Restore the note ID in the linkedNotes of each task concurrently
      await Future.wait(tasksWithNote.map((task) async {
        final updatedLinkedNotes = {...task.linkedNotes, note.id}.toList();
        await taskRepository
            .updateTask(task.copyWith(linkedNotes: updatedLinkedNotes));
      }));

      // Clear cached tasks
      ref.read(deletedNoteTasksProvider.notifier).update((state) {
        state.remove(note.id);
        return state;
      });

      // Notify the user
      snackBarAfterUndo("Note is restored and linked to relevant tasks.");
    } catch (e) {
      snackBarAfterUndo(
          "Failed to fully restore the note: ${e.toString()}");
    }
  }

  Future<void> updateNote(Note updatedNote) async {
    // Optimistically update local state
    final previousState = state;
    state = state
        .map((note) => note.id == updatedNote.id ? updatedNote : note)
        .toList();

    try {
      await _noteRepository.updateNote(updatedNote); // Sync to Firestore
    } catch (e) {
      // Roll back local state if Firebase operation fails
      state = previousState;
      CustomSnackbars.shortDurationSnackBar(
          contentString: "Failed to update note: $e");
    }
  }

  Future<void> undoNoteUpdate(
      Note updatedNote, Function(String) snackBarAfterUndo) async {
    final noteFormStateNotifier = ref.read(noteFormNotifierProvider.notifier);
    final selectedNoteNotifier = ref.read(selectedNoteProvider.notifier);

    await updateNote(updatedNote);

    // Update the current selected note state back to the previous note data.
    selectedNoteNotifier.state = updatedNote;

    // Update the note form state with the previous note data.
    noteFormStateNotifier.updateContent(updatedNote.content);
    noteFormStateNotifier.updateTitle(updatedNote.title);

    snackBarAfterUndo("Note changes are reverted.");
  }

  Future<void> removeNote(Note note) async {
    // Optimistically update local state
    final previousState = state;
    state = state.where((currentNote) => currentNote.id != note.id).toList();

    final taskRepository = ref.read(taskRepositoryProvider);
    List<Task> tasksWithNote = [];

    try {
      // Fetch tasks that reference the note
      final allTasks = await taskRepository.getTasksOnce();
      tasksWithNote = allTasks.docs
          .map((doc) => doc.data())
          .where((task) => task.linkedNotes.contains(note.id))
          .toList();

      // Remove the note ID from the linkedNotes of affected tasks concurrently
      await Future.wait(tasksWithNote.map((task) async {
        final updatedLinkedNotes =
            task.linkedNotes.where((noteId) => noteId != note.id).toList();
        await taskRepository
            .updateTask(task.copyWith(linkedNotes: updatedLinkedNotes));
      }));

      // Delete the note from Firestore
      await _noteRepository.deleteNote(note.id);

      // Cache the affected tasks for undo functionality
      ref.read(deletedNoteTasksProvider.notifier).state[note.id] =
          tasksWithNote;

      // Show success message
      CustomSnackbars.shortDurationSnackBar(
          contentString: "Note deleted successfully.");
    } catch (e) {
      // Roll back local state if any operation fails
      state = previousState;
      CustomSnackbars.shortDurationSnackBar(
          contentString: "Failed to remove note: ${e.toString()}");
    }
  }

  Future<void> undoNoteAddition(
      Note noteToUndo, Function(String) snackBarAfterUndo) async {
    await removeNote(noteToUndo);
    snackBarAfterUndo("Note is removed.");
  }

  Future<void> undoNoteEdit(Note noteToUndo) async {
    await updateNote(noteToUndo);
    CustomSnackbars.shortDurationSnackBar(
        contentString: "Note changes reverted!");
  }

  void resetAllNoteState() {
    ref.read(noteFormNotifierProvider.notifier).resetState();
    ref.read(isCreatingNoteProvider.notifier).state = false;
    ref.read(isEditingNoteProvider.notifier).state = false;
    ref.read(isUndoEditingNoteProvider.notifier).state = false;
    ref.read(selectedNoteProvider.notifier).state = null;
  }
}

final deletedNoteTasksProvider = StateProvider<Map<String, List<Task>>>((ref) {
  return {};
});

// to be removed in production
// final notes = [
//   Note(
//     id: 'note1',
//     title: 'My Vacation Plans',
//     content: "Places to visit:\n- Malaysia's beach\n- Japan's cherry blossoms",
//   ),
//   Note(
//     id: 'note2',
//     title: 'Grocery List',
//     content: "Items to buy:\n- Milk\n- Bread\n- Eggs\n- Coffee",
//   ),
//   Note(
//     id: 'note3',
//     title: 'Meeting Notes',
//     content:
//         "Project discussion:\n- Milestone 1 deadline: Jan 15\n- Assign tasks to team",
//   ),
//   Note(
//     id: 'note4',
//     title: 'Workout Plan',
//     content:
//         "Daily schedule:\n- Monday: Cardio\n- Tuesday: Strength Training\n- Wednesday: Yoga",
//   ),
//   Note(
//     id: 'note5',
//     title: 'Recipe: Pancakes',
//     content:
//         "Ingredients:\n- 1 cup flour\n- 2 tbsp sugar\n- 1 egg\n- 1 cup milk\nSteps:\n1. Mix ingredients\n2. Cook on a hot griddle",
//   ),
// ];
