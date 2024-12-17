import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/date_provider.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/middle_drag_handle.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/task_creation_header.dart';

class MiddleExtentContent extends ConsumerStatefulWidget {
  const MiddleExtentContent({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MiddleExtentContentState();
}

class _MiddleExtentContentState extends ConsumerState<MiddleExtentContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const MiddleDragHandle(),
        // Conditionally show Cancel and Save buttons
        const TaskCreationHeader(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Row(
                children: [
                  SizedBox(width: 32),
                  StyledText("Title"),
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
            ],
          ),
        ),
      ],
    );
  }
}
