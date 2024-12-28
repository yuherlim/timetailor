import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/core/shared/widgets/content_divider.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/data/note_management/models/note.dart';
import 'package:timetailor/domain/note_management/providers/note_form_provider.dart';
import 'package:timetailor/domain/note_management/providers/note_state_provider.dart';
import 'package:timetailor/domain/note_management/providers/notes_provider.dart';

class NoteTitleField extends HookConsumerWidget {
  const NoteTitleField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditingNote = ref.watch(isEditingNoteProvider);
    final isCreatingNote = ref.watch(isCreatingNoteProvider);

    // Read the form state
    final formState = ref.watch(noteFormNotifierProvider);
    final formNotifier = ref.read(noteFormNotifierProvider.notifier);

    // Persist TextEditingController using flutter_hooks
    final titleController = useTextEditingController();

    // State to track max length notification
    const maxLength = 50;
    bool hasReachedMaxLength = formState.title.length == maxLength;

    print("hasReachedMaxLength: $hasReachedMaxLength");

    // Keep Riverpod state in sync with the controller
    useEffect(() {
      Future.microtask(() {
        if (titleController.text != formState.title) {
          titleController.text = formState.title;
        }
      });

      void listener() {
        if (titleController.text != formState.title) {
          formNotifier.updateTitle(titleController.text);
        }
      }

      titleController.addListener(listener);
      return () {
        titleController.removeListener(listener);
      }; // Cleanup listener
    }, [formState.title]);

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
            maxLines: null,
            minLines: 1,
            controller: titleController,
            style: CustomTextStyles.noteTitleStyle,
            cursorColor: AppColors.textColor,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Title",
              hintStyle: CustomTextStyles.noteTitleStyle,
              counterText: "",
            ),
            maxLength: maxLength, // Enforce title character limit
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\n')),
            ], // Block newline character
            textInputAction: TextInputAction.done,
            onChanged: (value) {
              formNotifier.updateTitle(value);
            },
            onSubmitted: (value) {
              if (formNotifier.validateTitle()) {
                formNotifier.updateTitle(value);
              }
            },
          ),
        ),
        const ContentDivider(),

        // Error Text (shown only when validation fails)
        if (formState.titleError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: sidePadding),
            child: Text(
              formState.titleError!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),

        // Max Length Notification
        if (hasReachedMaxLength && (isEditingNote || isCreatingNote))
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: sidePadding),
            child: Text(
              'Maximum character limit for title reached',
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
