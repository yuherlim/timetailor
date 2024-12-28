import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/note_management/providers/note_form_provider.dart';
import 'package:timetailor/domain/note_management/providers/note_state_provider.dart';

class NoteContentField extends HookConsumerWidget {
  const NoteContentField({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditingNote = ref.watch(isEditingNoteProvider);
    final isCreatingNote = ref.watch(isCreatingNoteProvider);

    // Read the form state
    final formState = ref.watch(noteFormNotifierProvider);
    final formNotifier = ref.read(noteFormNotifierProvider.notifier);

    // Persist TextEditingController using flutter_hooks
    final contentController = useTextEditingController();

    // State to track max length notification
    const maxLength = 2000;
    final hasReachedMaxLength = formState.content.length == maxLength;

    // Keep Riverpod state in sync with the controller
    useEffect(() {
      Future.microtask(() {
        if (contentController.text != formState.content) {
          contentController.text = formState.content;
        }
      });

      void listener() {
        if (contentController.text != formState.content) {
          formNotifier.updateContent(contentController.text);
        }
      }

      contentController.addListener(listener);
      return () {
        contentController.removeListener(listener);
      }; // Cleanup listener
    }, [formState.content]);

    const double sidePadding = 32;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Text Field Design
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: sidePadding, vertical: 8),
          child: TextField(
            enabled: isEditingNote || isCreatingNote,
            controller: contentController,
            style: CustomTextStyles.noteContentStyle,
            cursorColor: AppColors.textColor,
            minLines: 10,
            maxLines: null,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Start writing your note...",
              hintStyle: CustomTextStyles.noteContentStyle,
              counterText: "",
            ),
            maxLength: maxLength, // Enforce title character limit
            onChanged: (value) {
              formNotifier.updateContent(value);
            },
            onSubmitted: (value) {
              formNotifier.updateContent(value);
            },
          ),
        ),

        // Max Length Notification
        if (hasReachedMaxLength && (isEditingNote || isCreatingNote))
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: sidePadding),
            child: Text(
              'Maximum character limit for content reached',
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
