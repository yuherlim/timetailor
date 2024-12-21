import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/note_management/providers/note_form_provider.dart';

class NoteContentField extends HookConsumerWidget {
  const NoteContentField({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read the form state
    final formState = ref.watch(noteFormNotifierProvider);
    final formNotifier = ref.read(noteFormNotifierProvider.notifier);

    // Persist TextEditingController using flutter_hooks
    final contentController = useTextEditingController();

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
    }, [formState.title]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Text Field Design
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8),
          child: TextField(
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
            maxLength: 2000, // Enforce title character limit
            onChanged: (value) {
              formNotifier.updateContent(value);
            },
            onSubmitted: (value) {
              formNotifier.updateContent(value);
            },
          ),
        ),
      ],
    );
  }
}
