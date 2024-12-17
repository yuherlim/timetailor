import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/chevron_down_drag_handle.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/task_creation_header.dart';

class MaxExtentContent extends ConsumerStatefulWidget {
  const MaxExtentContent({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MaxExtentContentState();
}

class _MaxExtentContentState extends ConsumerState<MaxExtentContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ChevronDownDragHandle(),
        const TaskCreationHeader(),
      ],
    );
  }
}
