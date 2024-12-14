import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';

class EndTimeWidget extends ConsumerStatefulWidget {
  const EndTimeWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EndTimeWidgetState();
}

class _EndTimeWidgetState extends ConsumerState<EndTimeWidget> {

  @override
  Widget build(BuildContext context) {
    final currentEndTime = ref.watch(endTimeProvider);
    return StyledTitle("End: $currentEndTime");
  }
}