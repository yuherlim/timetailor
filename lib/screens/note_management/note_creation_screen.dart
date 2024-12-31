import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/custom_snackbars.dart';
import 'package:timetailor/core/shared/widgets/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/data/note_management/models/note.dart';
import 'package:timetailor/domain/note_management/providers/note_form_provider.dart';
import 'package:timetailor/domain/note_management/providers/note_state_provider.dart';
import 'package:timetailor/domain/note_management/providers/notes_provider.dart';
import 'package:timetailor/domain/ocr/providers/ocr_provider.dart';
import 'package:timetailor/domain/user_management/providers/user_provider.dart';
import 'package:timetailor/screens/note_management/widgets/display_image.dart';
import 'package:timetailor/screens/note_management/widgets/note_content_field.dart';
import 'package:timetailor/screens/note_management/widgets/note_pdf_card.dart';
import 'package:timetailor/screens/note_management/widgets/note_title_field.dart';
import 'package:uuid/uuid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NoteCreationScreen extends StatefulHookConsumerWidget {
  const NoteCreationScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NoteCreationScreenState();
}

class _NoteCreationScreenState extends ConsumerState<NoteCreationScreen> {
  final connectivityStream = Connectivity()
      .onConnectivityChanged
      .map((connectivityResults) => connectivityResults.first);

  void createNote() {
    final currentLoggedInUser = ref.read(currentUserProvider);
    final formState = ref.read(noteFormNotifierProvider);
    final formNotifier = ref.read(noteFormNotifierProvider.notifier);
    final noteNotifier = ref.read(notesNotifierProvider.notifier);
    final isEditingNoteNotifier = ref.read(isEditingNoteProvider.notifier);
    final isCreatingNoteNotifier = ref.read(isCreatingNoteProvider.notifier);
    final isEditingNote = ref.read(isEditingNoteProvider);
    final isCreatingNote = ref.read(isCreatingNoteProvider);
    final selectedNote = ref.read(selectedNoteProvider);

    if (formNotifier.validateTitle()) {
      final noteToUpdate = Note(
        id: isCreatingNote ? const Uuid().v4() : selectedNote!.id,
        title: formState.title.trim(),
        content: formState.content.trim(),
        userId: currentLoggedInUser!.id,
      );

      formNotifier.updateTitle(formState.title.trim());
      formNotifier.updateContent(formState.content.trim());

      if (isEditingNote && selectedNote != null) {
        noteNotifier.updateNote(noteToUpdate);
        loadCurrentSelectedNoteData(noteToUpdate);
        isEditingNoteNotifier.state = false;
        CustomSnackbars.longDurationSnackBarWithAction(
          contentString: "Note successfully edited!",
          actionText: "Undo",
          onPressed: () => noteNotifier.undoNoteUpdate(
              selectedNote, showSnackBarWithMessage),
        );
      } else {
        noteNotifier.addNote(noteToUpdate);
        loadCurrentSelectedNoteData(noteToUpdate);
        isCreatingNoteNotifier.state = false;
        CustomSnackbars.longDurationSnackBarWithAction(
          contentString: "Note successfully saved!",
          actionText: "Undo",
          onPressed: () {
            noteNotifier.undoNoteAddition(
                noteToUpdate, showSnackBarWithMessage);
            if (mounted) {
              context.go(RoutePath.noteManagementPath);
            }
          },
        );
      }
    }
  }

  void loadCurrentSelectedNoteData(Note selectedNote) {
    final noteFormNotifier = ref.read(noteFormNotifierProvider.notifier);
    final selectedNoteNotifier = ref.read(selectedNoteProvider.notifier);

    selectedNoteNotifier.state = selectedNote;
    noteFormNotifier.updateTitle(selectedNote.title);
    noteFormNotifier.updateContent(selectedNote.content);
  }

  void handleEdit() {
    showSnackBarWithMessage("Editing note...");
    ref.read(isEditingNoteProvider.notifier).state = true;
  }

  void handleDelete() {
    final noteNotifier = ref.read(notesNotifierProvider.notifier);
    final selectedNote = ref.read(selectedNoteProvider)!;
    noteNotifier.removeNote(selectedNote);
    CustomSnackbars.longDurationSnackBarWithAction(
      contentString: "Note successfully deleted!",
      actionText: "Undo",
      onPressed: () {
        noteNotifier.undoNoteDeletion(selectedNote, showSnackBarWithMessage);
      },
    );
    if (mounted) {
      context.go(RoutePath.noteManagementPath);
    }
  }

  void showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                handleDelete();
              },
              child: Text('Delete',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          ],
        );
      },
    );
  }

  void showSnackBarWithMessage(String message) {
    CustomSnackbars.shortDurationSnackBar(contentString: message);
  }

  void cancelEdit() {
    final isEditingNoteNotifier = ref.read(isEditingNoteProvider.notifier);
    final selectedNote = ref.read(selectedNoteProvider);

    isEditingNoteNotifier.state = false;
    loadCurrentSelectedNoteData(selectedNote!);
    showSnackBarWithMessage("Note editing cancelled.");
  }

  @override
  Widget build(BuildContext context) {
    bool backButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
      final isEditingNote = ref.read(isEditingNoteProvider);
      final isEditingNoteNotifier = ref.read(isEditingNoteProvider.notifier);
      final selectedNote = ref.read(selectedNoteProvider);
      if (isEditingNote) {
        isEditingNoteNotifier.state = false;
        loadCurrentSelectedNoteData(selectedNote!);
        showSnackBarWithMessage("Note editing cancelled.");
        return true;
      }
      return false;
    }

    useEffect(() {
      BackButtonInterceptor.add(backButtonInterceptor);
      return () => BackButtonInterceptor.remove(backButtonInterceptor);
    }, []);

    ref.watch(notesNotifierProvider);
    final noteScrollController = useScrollController();

    final isEditingNote = ref.watch(isEditingNoteProvider);
    final isCreatingNote = ref.watch(isCreatingNoteProvider);
    final isViewingNote = ref.watch(isViewingNoteProvider);
    final ocrService = ref.read(ocrServiceProvider);

    return StreamBuilder<ConnectivityResult>(
      stream: connectivityStream,
      builder: (context, snapshot) {
        final isOnline =
            snapshot.hasData && snapshot.data != ConnectivityResult.none;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.appBarColor,
            leading: isEditingNote
                ? IconButton(
                    onPressed: () => cancelEdit(),
                    icon: const Icon(Icons.close),
                  )
                : null,
            title: AppBarText(isCreatingNote
                ? "Create Note"
                : isEditingNote
                    ? "Editing Note"
                    : "Note Details"),
            actions: [
              if (isOnline && !isViewingNote)
                isEditingNote || isCreatingNote
                    ? IconButton(
                        onPressed: () {
                          createNote();
                        },
                        icon: const Icon(Icons.save),
                      )
                    : PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'Edit') {
                            handleEdit();
                          } else if (value == 'Delete') {
                            showDeleteConfirmation(context);
                          }
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
          body: GestureDetector(
            onDoubleTap:
                isEditingNote || isViewingNote ? null : () => handleEdit(),
            child: LayoutBuilder(builder: (context, constraints) {
              return SingleChildScrollView(
                controller: noteScrollController,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: const IntrinsicHeight(
                    child: Column(
                      children: [
                        DisplayImage(imagePath: "golden.jpg"),
                        NotePDFCard(pdfPath: "test.pdf"),
                        NoteTitleField(),
                        NoteContentField(),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          floatingActionButton: !isViewingNote
              ? FloatingActionButton(
                  onPressed: () {
                    isEditingNote || isCreatingNote
                        ? createNote()
                        : handleEdit();
                  },
                  child: isEditingNote || isCreatingNote
                      ? const Icon(Icons.save)
                      : const Icon(Icons.edit),
                )
              : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.endContained,
          bottomNavigationBar: isOnline && !isViewingNote &&isEditingNote
              ? BottomAppBar(
                  notchMargin: 8.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.image),
                        onPressed: () {
                          // upload image file
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf),
                        onPressed: () {
                          // upload pdf file
                        },
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Symbols.network_intelligence),
                        onSelected: (value) {
                          if (value == 'Summarise') {
                          } else if (value == 'Translate') {
                          } else if (value == 'Improve Content') {
                          } else if (value == 'OCR') {
                            ocrService.onOCRSelected(context, ref);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem<String>(
                              value: 'Summarise',
                              child: Text('Summarise'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'Translate',
                              child: Text('Translate'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'Improve Content',
                              child: Text('Improve Content'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'OCR',
                              child: Text('OCR'),
                            ),
                          ];
                        },
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}
