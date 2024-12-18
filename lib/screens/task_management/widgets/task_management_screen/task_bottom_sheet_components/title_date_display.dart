import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/date_provider.dart';
import 'package:timetailor/domain/task_management/providers/task_form_provider.dart';

class TitleDateDisplay extends ConsumerWidget {
  const TitleDateDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(taskFormNotifierProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 32),
              Flexible(
                  child: StyledText(
                      formState.name.isEmpty ? "(No Title)" : formState.name)),
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
        ],
      ),
    );
  }
}