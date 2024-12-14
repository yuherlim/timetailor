import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';

class InitialExtentContent extends ConsumerWidget {
  const InitialExtentContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StyledTitle("Start: ${ref.read(startTimeProvider)}"),
            const SizedBox(width: 16),
            StyledTitle("End: ${ref.read(endTimeProvider)}"),
          ],
        ),
        const SizedBox(height: 4),
        Center(
          child: BottomSheetDurationText(ref.read(tasksNotifierProvider.notifier).formattedDurationString()),
        ),
      ],
    );
  }
}
