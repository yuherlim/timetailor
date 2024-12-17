import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/data/task_management/models/task.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/date_provider.dart';
import 'package:timetailor/domain/task_management/providers/scroll_controller_provider.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/calendar_widget_components/calendar_widget_background.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/calendar_widget_components/current_time_indicator.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/calendar_widget_components/draggable_box_components/bottom_drag_indicator.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/calendar_widget_components/draggable_box_components/bottom_duration_indicator.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/calendar_widget_components/draggable_box_components/bottom_time_indicator.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/calendar_widget_components/draggable_box_components/drag_indicator.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/calendar_widget_components/draggable_box_components/draggable_box.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/calendar_widget_components/draggable_box_components/dragging_status_indicator.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/calendar_widget_components/draggable_box_components/overlapping_status_indicator.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/calendar_widget_components/draggable_box_components/resizing_status_indicator.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/calendar_widget_components/draggable_box_components/top_duration_indicator.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/calendar_widget_components/draggable_box_components/top_drag_indicator.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/calendar_widget_components/draggable_box_components/top_time_indicator.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/calendar_widget_components/task_item.dart';

class CalendarWidget extends ConsumerStatefulWidget {
  const CalendarWidget({super.key});

  @override
  ConsumerState<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends ConsumerState<CalendarWidget> {
  @override
  Widget build(BuildContext context) {
    ref.watch(currentDateNotifierProvider);
    ref.watch(tasksNotifierProvider);
    final screenHeight = ref.watch(screenHeightProvider);

    // initialize screen height after screen finish rendering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(screenHeightProvider.notifier).state =
          MediaQuery.of(context).size.height;
    });

    // Check if the screenHeight is initialized
    if (screenHeight == 0.0) {
      return const CircularProgressIndicator(); // Show loading indicator
    }

    final scrollController = ref.watch(scrollControllerNotifierProvider);

    final alltasks =
        ref.read(tasksNotifierProvider.notifier).getAllTasksForCurrentDate();

    return SingleChildScrollView(
      controller: scrollController,
      child: Stack(
        children: [
          const CalendarWidgetBackground(),

          // current tasks
          if (alltasks != null) ...alltasks.map((task) => TaskItem(task: task)),

          if (ref.watch(showDraggableBoxProvider)) ...[
            const DraggableBox(),
            const TopDurationIndicator(),
            const BottomDurationIndicator(),
            const DragIndicator(),
            const DraggingStatusIndicator(isTopDraggingIndicator: true),
            const DraggingStatusIndicator(isTopDraggingIndicator: false),
            const ResizingStatusIndicator(isTopResizingIndicator: true),
            const ResizingStatusIndicator(isTopResizingIndicator: false),
            const OverlappingStatusIndicator(),

            // Top Indicator
            const TopDragIndicator(),
            const TopTimeIndicator(),

            // Bottom Indicator
            const BottomDragIndicator(),
            const BottomTimeIndicator(),
          ],

          // Current Time Indicator
          const CurrentTimeIndicator(),
        ],
      ),
    );
  }
}
