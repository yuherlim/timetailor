import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/domain/task_management/providers/bottom_sheet_scroll_controller_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_read_only_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/date_provider.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/chevron_down_drag_handle.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/initial_extent_content.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/max_extent_content.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/middle_drag_handle.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/middle_extent_content.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet_components/task_creation_header.dart';

class TaskBottomSheet extends ConsumerStatefulWidget {
  const TaskBottomSheet({super.key});

  @override
  ConsumerState<TaskBottomSheet> createState() => _TaskBottomSheetState();
}

class _TaskBottomSheetState extends ConsumerState<TaskBottomSheet> {
  void initializeMaxExtent() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double bottomSheetMaxExtent =
        (MediaQuery.of(context).size.height - statusBarHeight) /
            MediaQuery.of(context).size.height;

    // initialize maxBottomSheetExtent after widget tree finish building
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

    final double currentExtent = ref.watch(sheetExtentProvider);
    final double initialBottomSheetExtent =
        ref.watch(initialBottomSheetExtentProvider);
    final double middleBottomSheetExtent =
        ref.watch(middleBottomSheetExtentProvider);
    const double tolerance =
        0.01; // Allowable tolerance for floating-point comparison
    final bottomSheetScrollController =
        ref.watch(bottomSheetScrollControllerNotifierProvider);

    return Positioned.fill(
      child: NotificationListener<DraggableScrollableNotification>(
        onNotification: (notification) {
          final notificationExtent = notification.extent;
          final sheetExtentNotifier = ref.read(sheetExtentProvider.notifier);

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
        child: DraggableScrollableSheet(
          controller: bottomSheetScrollController,
          initialChildSize: initialBottomSheetExtent,
          minChildSize: initialBottomSheetExtent,
          maxChildSize: maxExtent,
          snap: true,
          snapSizes: [middleBottomSheetExtent],
          builder: (BuildContext context, ScrollController scrollController) {
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
                      if (currentExtent == initialBottomSheetExtent)
                        const InitialExtentContent(),

                      if (currentExtent == middleBottomSheetExtent)
                        const MiddleExtentContent(),

                      if (currentExtent == maxExtent) const MaxExtentContent(),
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
