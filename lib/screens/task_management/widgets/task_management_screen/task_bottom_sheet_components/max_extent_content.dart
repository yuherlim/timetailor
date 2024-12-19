import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/chevron_down_drag_handle.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/notes_container.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/task_creation_header.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/task_description_field.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/task_name_field.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/title_date_display.dart';

class MaxExtentContent extends ConsumerStatefulWidget {
  const MaxExtentContent({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MaxExtentContentState();
}

class _MaxExtentContentState extends ConsumerState<MaxExtentContent> {
  @override
  Widget build(BuildContext context) {
    // Read the form state
    return const Column(
      children: [
        ChevronDownDragHandle(),
        TaskCreationHeader(),
        SizedBox(height: 8),
        TitleDateDisplay(),
        TaskNameField(),
        SizedBox(height: 16),
        TaskDescriptionField(),
        SizedBox(height: 8),
        NotesContainer(),
        SizedBox(height: 32),
      ],
    );
  }
}
