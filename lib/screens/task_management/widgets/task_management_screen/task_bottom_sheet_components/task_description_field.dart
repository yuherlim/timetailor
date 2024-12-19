import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/core/shared/styled_text.dart';
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
      child: Column(
        children: [
          TextFormField(
            controller: descriptionController,
            style: Theme.of(context).textTheme.bodyMedium,
            cursorColor: AppColors.textColor,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.description),
              suffixIcon: descriptionController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        formNotifier.clearDescription();
                        descriptionController.clear();
                      },
                    )
                  : null,
              label: const StyledText("Description"),
              helperText:
                  '${descriptionController.text.length}/500', // Show character count
              helperStyle: TextStyle(
                  color: descriptionController.text.length == 500
                      ? AppColors.highlightColor
                      : AppColors.textColor),
            ),
            cursorErrorColor: Theme.of(context).colorScheme.error,
            onFieldSubmitted: (value) {
              FocusScope.of(context).unfocus();
            },
            inputFormatters: [
              LengthLimitingTextInputFormatter(500), // Enforce character limit
            ],
          ),
        ],
      ),
    );
  }
}
