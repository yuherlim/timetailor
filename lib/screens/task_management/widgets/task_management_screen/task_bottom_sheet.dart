import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/shared/utils.dart';
import 'package:timetailor/domain/task_management/providers/bottom_sheet_scroll_controller_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_read_only_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/initial_extent_content.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/max_extent_content.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/middle_extent_content.dart';

class TaskBottomSheet extends ConsumerStatefulWidget {
  const TaskBottomSheet({super.key});

  @override
  ConsumerState<TaskBottomSheet> createState() => _TaskBottomSheetState();
}

class _TaskBottomSheetState extends ConsumerState<TaskBottomSheet> {
  void initializeMaxExtent() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double bottomInset = MediaQuery.of(context).viewPadding.bottom;

    // Add a small buffer to ensure no bleeding into the notification bar
    const double buffer = 8.0; // Adjust as needed
    final double adjustedHeight =
        screenHeight - statusBarHeight - bottomInset - buffer;
    final double bottomSheetMaxExtent = adjustedHeight / screenHeight;

    // Initialize maxBottomSheetExtent after widget tree finishes building
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(maxBottomSheetExtentProvider.notifier).state =
          bottomSheetMaxExtent;
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxExtent = ref.watch(maxBottomSheetExtentProvider);

    if (maxExtent == 0.0) {
      initializeMaxExtent();
      return const CircularProgressIndicator(); // Show loading indicator
    }

    print("bottom sheet is rebuilt.");

    final double currentExtent = ref.watch(sheetExtentProvider);
    final double initialBottomSheetExtent =
        ref.watch(initialBottomSheetExtentProvider);
    final double minBottomSheetExtent = ref.read(minBottomSheetExtentProvider);
    final double middleBottomSheetExtent =
        ref.watch(middleBottomSheetExtentProvider);
    const double tolerance =
        0.01; // Allowable tolerance for floating-point comparison
    final bottomSheetScrollController =
        ref.watch(bottomSheetScrollControllerNotifierProvider);
    final dyTop = ref.read(localDyProvider);
    final dyBottom = ref.read(localDyBottomProvider);
    final showDraggableBox = ref.watch(showDraggableBoxProvider);
    final showBottomSheet = ref.watch(showBottomSheetProvider);
    final isTaskNotOverlapping = ref
        .read(tasksNotifierProvider.notifier)
        .checkAddTaskValidity(dyTop: dyTop, dyBottom: dyBottom);

    return Positioned.fill(
      child: Offstage(
        offstage:
            !(showDraggableBox && showBottomSheet && isTaskNotOverlapping),
        child: NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            Utils.clearAllFormFieldFocus();

            final notificationExtent = notification.extent;
            final sheetExtentNotifier = ref.read(sheetExtentProvider.notifier);

            // Detect if swiped to the minimum extent, if yes, cancel task creation.
            if (notificationExtent == minBottomSheetExtent) {
              ref.read(tasksNotifierProvider.notifier).endTaskCreation();
              return true;
            }

            // Check for snap sizes with tolerance
            if ((notificationExtent - initialBottomSheetExtent).abs() <
                tolerance) {
              sheetExtentNotifier.update(initialBottomSheetExtent);
            } else if ((notificationExtent - middleBottomSheetExtent).abs() <
                tolerance) {
              sheetExtentNotifier.update(middleBottomSheetExtent);
            } else if ((notificationExtent - maxExtent).abs() < tolerance) {
              sheetExtentNotifier.update(maxExtent);
            }

            return true;
          },
          child: GestureDetector(
            onTap: () => Utils.clearAllFormFieldFocus(),
            child: DraggableScrollableSheet(
              controller: bottomSheetScrollController,
              initialChildSize: initialBottomSheetExtent,
              minChildSize: minBottomSheetExtent,
              maxChildSize: maxExtent,
              snap: true,
              snapSizes: [initialBottomSheetExtent, middleBottomSheetExtent],
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Material(
                  borderRadius: (currentExtent != maxExtent)
                      ? const BorderRadius.vertical(
                          top: Radius.circular(28),
                        )
                      : null,
                  color: Theme.of(context).colorScheme.onSecondary,
                  elevation: 4,
                  child: SafeArea(
                    top:
                        false, // Prevent SafeArea from adding unnecessary top padding
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: <Widget>[
                          Offstage(
                            offstage: currentExtent != initialBottomSheetExtent,
                            child: const InitialExtentContent(),
                          ),
                          Offstage(
                            offstage: currentExtent != middleBottomSheetExtent,
                            child: const MiddleExtentContent(),
                          ),
                          Offstage(
                            offstage: currentExtent != maxExtent,
                            child: const MaxExtentContent(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
