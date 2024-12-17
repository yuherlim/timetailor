import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/date_provider.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/middle_drag_handle.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/task_creation_header.dart';

class MiddleExtentContent extends StatefulHookConsumerWidget {
  const MiddleExtentContent({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MiddleExtentContentState();
}

class _MiddleExtentContentState extends ConsumerState<MiddleExtentContent> {
  @override
  Widget build(BuildContext context) {
    // Persist TextEditingController using flutter_hooks
    final titleController = useTextEditingController();

    // Local state for form validation/error handling
    final errorText = useState<String?>(null);
    final isTextEmpty = useState<bool>(true);
    final isFormValid = useState<bool>(false);
    final charCount = useState<int>(titleController.text.length);
    final taskName = useState<String>("");

    useEffect(() {
      void listener() {
        isTextEmpty.value = titleController.text.isEmpty;
        charCount.value = titleController.text.length;
        taskName.value = titleController.text.trim();
      }

      titleController.addListener(listener);
      return () => titleController.removeListener(listener); // Cleanup listener
    }, [titleController]);

    void validateTaskName(String value) {
      if (value.trim().isEmpty) {
        errorText.value = "Title cannot be empty";
        isFormValid.value = false;
      } else {
        errorText.value = null;
        isFormValid.value = true;
      }
    }

    void clearTaskNameTextField() {
      titleController.clear();
      isTextEmpty.value = true;
      errorText.value = "Title cannot be empty";
      charCount.value = 0; // Reset char count
    }

    return Column(
      children: [
        const MiddleDragHandle(),
        // Conditionally show Cancel and Save buttons
        const TaskCreationHeader(),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 32),
                  Flexible(
                      child: StyledText(taskName.value.isEmpty
                          ? "(No Title)"
                          : taskName.value)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(width: 32),
                  StyledText(DateFormat('d MMM')
                      .format(ref.watch(currentDateNotifierProvider))),
                  const SizedBox(width: 16),
                  StyledText(
                      "${ref.watch(startTimeProvider)} - ${ref.watch(endTimeProvider)}"),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: titleController,
                style: Theme.of(context).textTheme.bodyMedium,
                cursorColor: AppColors.textColor,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.task),
                  suffixIcon: !isTextEmpty.value
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: clearTaskNameTextField,
                        )
                      : null,
                  label: const StyledText("Title"),
                  helperText: '${charCount.value}/50', // Show character count
                  helperStyle: TextStyle(
                      color: titleController.text.length == 50
                          ? AppColors.highlightColor
                          : AppColors.textColor),
                  errorText: errorText.value,
                  errorStyle:
                      TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                cursorErrorColor: Theme.of(context).colorScheme.error,
                autofocus: true,
                onChanged: validateTaskName,
                onFieldSubmitted: validateTaskName,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(
                      50), // Enforce character limit
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
