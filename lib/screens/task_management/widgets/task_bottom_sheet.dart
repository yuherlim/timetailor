import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/domain/task_management/providers/calendar_read_only_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';
import 'package:timetailor/screens/task_management/widgets/task_bottom_sheet_components/chevron_down_drag_handle.dart';
import 'package:timetailor/screens/task_management/widgets/task_bottom_sheet_components/chevron_up_drag_handle.dart';

class TaskBottomSheet extends ConsumerStatefulWidget {
  const TaskBottomSheet({super.key});

  @override
  ConsumerState<TaskBottomSheet> createState() => _TaskBottomSheetState();
}

class _TaskBottomSheetState extends ConsumerState<TaskBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double maxExtent =
        (MediaQuery.of(context).size.height - statusBarHeight) /
            MediaQuery.of(context).size.height;
    final double currentExtent = ref.watch(sheetExtentProvider);
    final double initialBottomSheetExtent = ref.watch(initialBottomSheetExtentProvider);
    final double middleBottomSheetExtent = ref.watch(middleBottomSheetExtentProvider);
    const double tolerance =
        0.01; // Allowable tolerance for floating-point comparison

    return Positioned.fill(
      child: NotificationListener<DraggableScrollableNotification>(
        onNotification: (notification) {
          final notificationExtent = notification.extent;
          final sheetExtentNotifier = ref.read(sheetExtentProvider.notifier);
          print("notificationExtent: $notificationExtent");

          // Check for snap sizes with tolerance
          if ((notificationExtent - initialBottomSheetExtent).abs() < tolerance) {
            print("notificationExtent after adjust: ${(notificationExtent - initialBottomSheetExtent).abs()}");
            sheetExtentNotifier.state = initialBottomSheetExtent;
          } else if ((notificationExtent - middleBottomSheetExtent).abs() < tolerance) {
            sheetExtentNotifier.state = middleBottomSheetExtent;
          } else if ((notificationExtent - maxExtent).abs() < tolerance) {
            sheetExtentNotifier.state = maxExtent;
          }

          return true;
        },
        child: DraggableScrollableSheet(
          initialChildSize: initialBottomSheetExtent,
          minChildSize: initialBottomSheetExtent,
          maxChildSize: maxExtent,
          snap: true,
          snapSizes: [middleBottomSheetExtent],
          builder: (BuildContext context, ScrollController scrollController) {
            return Material(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              color: Theme.of(context).colorScheme.surface,
              elevation: 4,
              child: SafeArea(
                top:
                    false, // Prevent SafeArea from adding unnecessary top padding
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (currentExtent == initialBottomSheetExtent) const ChevronUpDragHandle(),

                      // normal drag handle
                      if (currentExtent == middleBottomSheetExtent)
                        Center(
                          child: Container(
                            height: 4,
                            width: 40,
                            margin: const EdgeInsets.only(top: 12, bottom: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withOpacity(0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                      if (currentExtent == maxExtent)
                        const ChevronDownDragHandle(),

                      // Conditionally show Cancel and Save buttons
                      if (currentExtent >= middleBottomSheetExtent)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  // Close bottom sheet
                                  ref.read(tasksNotifierProvider.notifier).cancelTaskCreation();
                                },
                              ),
                              TextButton(
                                onPressed: () {
                                  // Save action
                                  debugPrint('Save button pressed');
                                },
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Bottom Sheet Content
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 16),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Text(
                      //         'Task Details',
                      //         style: Theme.of(context)
                      //             .textTheme
                      //             .titleLarge
                      //             ?.copyWith(
                      //               color: Theme.of(context)
                      //                   .colorScheme
                      //                   .onSurface,
                      //             ),
                      //       ),
                      //       const SizedBox(height: 8),
                      //       Text(
                      //         'Details about the task selected...',
                      //         style: Theme.of(context)
                      //             .textTheme
                      //             .bodyMedium
                      //             ?.copyWith(
                      //               color: Theme.of(context)
                      //                   .colorScheme
                      //                   .onSurfaceVariant,
                      //             ),
                      //       ),
                      //       const SizedBox(height: 16),
                      //       // Example of additional content
                      //       ListView.builder(
                      //         shrinkWrap: true,
                      //         physics: const NeverScrollableScrollPhysics(),
                      //         padding: const EdgeInsets.symmetric(
                      //             horizontal: 16),
                      //         itemCount: 100,
                      //         itemBuilder:
                      //             (BuildContext context, int index) {
                      //           return ListTile(
                      //             leading: Icon(
                      //               Icons.task_alt,
                      //               color: Theme.of(context)
                      //                   .colorScheme
                      //                   .primary,
                      //             ),
                      //             title: Text('Task Detail $index'),
                      //           );
                      //         },
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
