import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/domain/task_management/providers/calendar_local_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/scroll_controller_provider.dart';
import 'package:timetailor/screens/task_management/widgets/calendar_widget_background.dart';
import 'package:timetailor/screens/task_management/widgets/current_time_indicator.dart';
import 'package:timetailor/screens/task_management/widgets/draggable_box_components/bottom_indicator.dart';
import 'package:timetailor/screens/task_management/widgets/draggable_box_components/draggable_box.dart';
import 'package:timetailor/screens/task_management/widgets/draggable_box_components/top_indicator.dart';

class CalendarWidget extends ConsumerStatefulWidget {
  const CalendarWidget({super.key});

  @override
  ConsumerState<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends ConsumerState<CalendarWidget> {
  @override
  void initState() {
    BackButtonInterceptor.add(_backButtonInterceptor);
    super.initState();
  }

  bool _backButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    final location = GoRouter.of(context).state!.path;

    // only intercept back gesture when the current nav branch is task management
    if (location == RoutePath.taskManagementPath &&
        ref.read(showDraggableBoxProvider)) {
      ref.read(showDraggableBoxProvider.notifier).state = false;

      return true; // Prevents the default back button behavior
    }
    return false; // Allows the default back button behavior
  }

  @override
  void dispose() {
    // Clean up
    BackButtonInterceptor.remove(_backButtonInterceptor);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // initialize screen height after screen finish rendering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(screenHeightProvider.notifier).state =
          MediaQuery.of(context).size.height;
    });

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
          // Current Time Indicator
          const CurrentTimeIndicator(),
        ],
      ),
    );
  }
}
