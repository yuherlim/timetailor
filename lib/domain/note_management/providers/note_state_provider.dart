import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/data/note_management/models/note.dart';

final isCreatingNoteProvider= StateProvider<bool>((ref) => false);
final isEditingNoteProvider = StateProvider<bool>((ref) => false);
final isUndoEditingNoteProvider = StateProvider<bool>((ref) => false);
final selectedNoteProvider = StateProvider<Note?>((ref) => null);