import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';
import 'package:timetailor/domain/task_management/task_manager.dart';

class StartTimeWidget extends ConsumerStatefulWidget {
  const StartTimeWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StartTimeWidgetState();
}

class _StartTimeWidgetState extends ConsumerState<StartTimeWidget> {
  void openStartTimePicker() {
    debugPrint("on tap triggered.");

    final tasksNotifier = ref.read(tasksNotifierProvider.notifier);
    final currentStartTimeInDateTimeFormat =
        tasksNotifier.parseTimeToDateTime(ref.read(startTimeProvider));

    if (currentStartTimeInDateTimeFormat == null) {
      debugPrint("incorrect string format for start time.");
      return;
    }

    final currentStartTime = currentStartTimeInDateTimeFormat;

    EasyDateTimeLinePicker(
      focusedDate: currentStartTime,
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime(2100, 12, 31),
      onDateChange: (date) {
        // Handle the selected date.
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStartTime = ref.watch(startTimeProvider);

    return GestureDetector(
      onTap: openStartTimePicker,
      child: StyledTitle("Start: $currentStartTime"),
    );
  }
}
