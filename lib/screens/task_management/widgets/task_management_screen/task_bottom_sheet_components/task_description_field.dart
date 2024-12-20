import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/core/shared/utils.dart';
import 'package:timetailor/core/shared/widgets/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/task_management/providers/task_form_provider.dart';

class TaskDescriptionField extends HookConsumerWidget {
  const TaskDescriptionField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read the form state
    final formState = ref.watch(taskFormNotifierProvider);
    final formNotifier = ref.read(taskFormNotifierProvider.notifier);

    // Persist TextEditingController using flutter_hooks
    final descriptionController = useTextEditingController();

    // Keep Riverpod state in sync with the controller
    useEffect(() {
      Future.microtask(() {
        if (descriptionController.text != formState.description) {
          descriptionController.text = formState.description;
        }
      });

      void listener() {
        formNotifier.updateDescription(descriptionController.text);
      }

      descriptionController.addListener(listener);
      return () =>
          descriptionController.removeListener(listener); // Cleanup listener
    }, [formState.description]);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: descriptionController,
                style: Theme.of(context).textTheme.bodyMedium,
                cursorColor: AppColors.textColor,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 20, // Set maximum lines for a larger field
                minLines: 10, // Set minimum lines to ensure it starts bigger
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(48, 12, 36, 12),
                  label: StyledText("Description"),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                cursorErrorColor: Theme.of(context).colorScheme.error,
                onFieldSubmitted: (value) {
                  Utils.clearAllFormFieldFocus();
                },
                inputFormatters: [
                  LengthLimitingTextInputFormatter(
                      500), // Enforce character limit
                ],
              ),
              // Place the helper text below the TextFormField explicitly
              Padding(
                padding: const EdgeInsets.only(
                    top: 4.0), // Add spacing between input and helper text
                child: Text(
                  '${descriptionController.text.length}/500',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: descriptionController.text.length == 500
                        ? AppColors.highlightColor
                        : AppColors.textColor,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 10,
            left: 12,
            child: Icon(
              Icons.description,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
            ),
          ),
          if (descriptionController.text.isNotEmpty)
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  formNotifier.clearDescription();
                  descriptionController.clear();
                },
              ),
            ),
        ],
      ),
    );
  }
}
