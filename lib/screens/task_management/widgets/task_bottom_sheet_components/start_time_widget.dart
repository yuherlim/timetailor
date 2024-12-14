import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
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
    final currentEndTimeInDateTimeFormat =
        tasksNotifier.parseTimeToDateTime(ref.read(endTimeProvider));

    if (currentStartTimeInDateTimeFormat == null ||
        currentEndTimeInDateTimeFormat == null) {
      debugPrint("incorrect string format for start time and end time.");
      return;
    }

    final currentStartTime = Time(
      hours: currentStartTimeInDateTimeFormat.hour,
      minutes: currentStartTimeInDateTimeFormat.minute,
    );

    final maxTime = Time(
      hours: currentEndTimeInDateTimeFormat.hour,
      minutes: currentEndTimeInDateTimeFormat.minute - 5,
    );

    BottomPicker.time(
      pickerTitle: Text(
        'Set your next meeting time',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.orange,
        ),
      ),
      onSubmit: (selectedTime) {
        ref.read(startTimeProvider.notifier).state = TaskManager.formatTime(
          selectedTime.hour,
          selectedTime.minute,
        );
      },
      onClose: () {
        print('Picker closed');
      },
      bottomPickerTheme: BottomPickerTheme.orange,
      use24hFormat: false,
      initialTime: currentStartTime,
      maxTime: maxTime,
    ).show(context);
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
