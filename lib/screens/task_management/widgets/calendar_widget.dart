import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/scroll_controller_provider.dart';
import 'package:timetailor/screens/task_management/widgets/calendar_widget_background.dart';
import 'package:timetailor/screens/task_management/widgets/current_time_indicator.dart';
import 'package:timetailor/screens/task_management/widgets/draggable_box_components/bottom_indicator.dart';
import 'package:timetailor/screens/task_management/widgets/draggable_box_components/drag_indicator.dart';
import 'package:timetailor/screens/task_management/widgets/draggable_box_components/draggable_box.dart';
import 'package:timetailor/screens/task_management/widgets/draggable_box_components/top_indicator.dart';

class CalendarWidget extends ConsumerStatefulWidget {
  const CalendarWidget({super.key});

  @override
  ConsumerState<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends ConsumerState<CalendarWidget> {
  
  

  @override
  Widget build(BuildContext context) {
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

    return SingleChildScrollView(
      controller: scrollController,
      child: Stack(
        children: [
          const CalendarWidgetBackground(),
          // draggable box
          if (ref.watch(showDraggableBoxProvider)) const DraggableBox(),
          // Top Indicator
          if (ref.watch(showDraggableBoxProvider)) const TopIndicator(),
          // Bottom Indicator
          if (ref.watch(showDraggableBoxProvider)) const BottomIndicator(),
          // drag Indicator
          if (ref.watch(showDraggableBoxProvider)) const DragIndicator(),
          // Current Time Indicator
          const CurrentTimeIndicator(),
        ],
      ),
    );
  }
}
