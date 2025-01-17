import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/core/shared/utils.dart';
import 'package:timetailor/core/shared/widgets/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/task_management/providers/task_form_provider.dart';

class TaskNameField extends HookConsumerWidget {
  const TaskNameField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read the form state
    final formState = ref.watch(taskFormNotifierProvider);
    final formNotifier = ref.read(taskFormNotifierProvider.notifier);

    // Persist TextEditingController using flutter_hooks
    final titleController = useTextEditingController();

    // Keep Riverpod state in sync with the controller
    useEffect(() {
      Future.microtask(() {
        if (titleController.text != formState.name) {
          titleController.text = formState.name;
        }
      });

      void listener() {
        if (titleController.text != formState.name) {
          formNotifier.updateName(titleController.text);
        }
      }

      titleController.addListener(listener);
      return () {
        titleController.removeListener(listener);
      }; // Cleanup listener
    }, [formState.name]);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          TextFormField(
            controller: titleController,
            style: Theme.of(context).textTheme.bodyMedium,
            cursorColor: AppColors.textColor,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.task),
              suffixIcon: titleController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        formNotifier.clearName();
                        titleController.clear();
                      },
                    )
                  : null,
              label: const StyledText("Title"),
              helperText:
                  '${titleController.text.length}/50', // Show character count
              helperStyle: TextStyle(
                  color: titleController.text.length == 50
                      ? AppColors.highlightColor
                      : AppColors.textColor),
              errorText: formState.nameError,
              errorStyle: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            cursorErrorColor: Theme.of(context).colorScheme.error,
            onChanged: (value) {
              if (formNotifier.validate()) {
                formNotifier.updateName(value);
              }
            },
            onFieldSubmitted: (value) {
              Utils.clearAllFormFieldFocus();

              if (formNotifier.validate()) {
                formNotifier.updateName(value);
              }
            },
            inputFormatters: [
              LengthLimitingTextInputFormatter(50), // Enforce character limit
            ],
          ),
        ],
      ),
    );
  }
}
