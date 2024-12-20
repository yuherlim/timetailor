import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/middle_drag_handle.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/task_creation_header.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/task_name_field.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/title_date_display.dart';

class MiddleExtentContent extends StatefulHookConsumerWidget {
  const MiddleExtentContent({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MiddleExtentContentState();
}

class _MiddleExtentContentState extends ConsumerState<MiddleExtentContent> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        MiddleDragHandle(),
        TaskCreationHeader(),
        SizedBox(height: 8),
        TitleDateDisplay(),
        TaskNameField(),
      ],
    );
  }
}
