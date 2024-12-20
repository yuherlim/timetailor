import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/widgets/styled_text.dart';
import 'package:timetailor/core/theme/custom_theme.dart';

class NoteManagementScreen extends ConsumerStatefulWidget {
  const NoteManagementScreen({super.key});

  @override
  ConsumerState<NoteManagementScreen> createState() =>
      _NoteManagementScreenState();
}

class _NoteManagementScreenState extends ConsumerState<NoteManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go(RoutePath.noteCreationPath);
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        title: const AppBarText("Notes"),
        titleSpacing: 72,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Center(
              child: TitleTextInHistory(
                "There are currently no notes.",
              ),
            ),
          )

          // completedTasks.isEmpty
          //     ? const Expanded(
          //         child: Center(
          //           child: TitleTextInHistory(
          //             "There are currently no notes.",
          //           ),
          //         ),
          //       )
          //     : Expanded(
          //         child: ListView.builder(
          //           itemCount: completedTasks.length,
          //           itemBuilder: (context, index) {
          //             final task = completedTasks[index];
          //             return CompletedTaskListItem(task: task);
          //           },
          //         ),
          //       ),
        ],
      ),
    );
  }
}
