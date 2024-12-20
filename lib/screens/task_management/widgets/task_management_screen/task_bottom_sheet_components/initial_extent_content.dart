import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/shared/widgets/styled_text.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/chevron_up_drag_handle.dart';

class InitialExtentContent extends ConsumerWidget {
  const InitialExtentContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const ChevronUpDragHandle(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StyledTitle("Start: ${ref.watch(startTimeProvider)}"),
            const SizedBox(width: 16),
            StyledTitle("End: ${ref.watch(endTimeProvider)}"),
          ],
        ),
        const SizedBox(height: 4),
        Center(
          child: BottomSheetDurationText(ref
              .read(tasksNotifierProvider.notifier)
              .formattedDurationString()),
        ),
      ],
    );
  }
}
