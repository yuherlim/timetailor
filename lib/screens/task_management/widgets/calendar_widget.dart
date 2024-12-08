import 'dart:async';
import 'dart:math';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/state/calendar_state.dart';
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
  bool isScrolled = false;
  late ScrollController _scrollController;
  double localDy = 0;
  double localCurrentTimeSlotHeight = 0;

  @override
  void initState() {
    _scrollController = ScrollController(); // Initialize the scroll controller
    BackButtonInterceptor.add(_backButtonInterceptor);
    _initializeCalendarState();
    super.initState();
  }

  void _initializeCalendarState() {
    // calculations of these elements need to wait for the widget build to complete, hence placed in this scope.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenHeight = MediaQuery.of(context).size.height;

      // Calculate first
      final double defaultTimeSlotHeight = screenHeight <= 800 ? 120 : 144;
      final double pixelsPerMinute = defaultTimeSlotHeight / 60;
      final double snapIntervalHeight = 5 * pixelsPerMinute;
      final double calendarHeight = defaultTimeSlotHeight * 24;
      final double calendarWidgetBottomBoundaryY =
          CalendarState.calendarWidgetTopBoundaryY + calendarHeight;
      // Generate time slot boundaries
      final List<double> timeSlotBoundaries = List.generate(
        24,
        (i) =>
            CalendarState.calendarWidgetTopBoundaryY +
            (defaultTimeSlotHeight * i),
      );

      // update state
      ref.read(calendarStateNotifierProvider.notifier)
        ..updateDefaultTimeSlotHeight(defaultTimeSlotHeight)
        ..updatePixelsPerMinute(pixelsPerMinute)
        ..updateSnapIntervalHeight(snapIntervalHeight)
        ..updateCalendarHeight(calendarHeight)
        ..updateCalendarWidgetBottomBoundaryY(calendarWidgetBottomBoundaryY)
        ..updateTimeSlotBoundaries(timeSlotBoundaries);
    });
  }

  void scrollToCurrentTimeIndicator({required double position}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenHeight = MediaQuery.of(context).size.height;
      _scrollController.animateTo(
        position - screenHeight * 0.3,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    });
  }

  bool _backButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    final showDraggableBox =
        ref.read(calendarStateNotifierProvider).showDraggableBox;
    final location = GoRouter.of(context).state!.path;

    // only intercept back gesture when the current nav branch is task management
    if (location == RoutePath.taskManagementPath && showDraggableBox) {
      ref
          .read(calendarStateNotifierProvider.notifier)
          .toggleDraggableBox(false);

      return true; // Prevents the default back button behavior
    }
    return false; // Allows the default back button behavior
  }


  @override
  void dispose() {
    // Clean up
    _scrollController.dispose();
    BackButtonInterceptor.remove(_backButtonInterceptor);
    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
    final currentCalendarState = ref.watch(calendarStateNotifierProvider);

    // indicator dimensions
    const double indicatorWidth = 80;
    const double indicatorHeight = 30;

    return SingleChildScrollView(
      controller: _scrollController,
      child: Stack(
        children: [
          CalendarWidgetBackground(
            context: this.context,
            slotHeight: currentCalendarState.defaultTimeSlotHeight,
            snapInterval: currentCalendarState.snapIntervalHeight,
            topPadding: CalendarState.calendarWidgetTopBoundaryY,
            bottomPadding: CalendarState.calendarBottomPadding,
            updateParentState: ({
              double? localDy,
              double? localCurrentTimeSlotHeight,
              bool? isScrolled,
            }) {
              updateLocalState(
                  localDy: localDy,
                  localCurrentTimeSlotHeight: localCurrentTimeSlotHeight);
            },
          ),
          // draggable box
          if (currentCalendarState.showDraggableBox)
            DraggableBox(
              localDy: localDy,
              localCurrentTimeSlotHeight: localCurrentTimeSlotHeight,
            ),
          // Top Indicator
          if (currentCalendarState.showDraggableBox)
            TopIndicator(
              indicatorWidth: indicatorWidth,
              indicatorHeight: indicatorHeight,
              localDy: localDy,
              localCurrentTimeSlotHeight: localCurrentTimeSlotHeight,
              isScrolled: isScrolled,
              scrollController: _scrollController,
              updateParentState: ({
                double? localDy,
                double? localCurrentTimeSlotHeight,
                bool? isScrolled,
              }) {
                updateLocalState(
                  localDy: localDy,
                  localCurrentTimeSlotHeight: localCurrentTimeSlotHeight,
                  isScrolled: isScrolled,
                );
              },
            ),
          // Bottom Indicator
          if (currentCalendarState.showDraggableBox)
            BottomIndicator(
              indicatorWidth: indicatorWidth,
              indicatorHeight: indicatorHeight,
              localDy: localDy,
              localCurrentTimeSlotHeight: localCurrentTimeSlotHeight,
              isScrolled: isScrolled,
              scrollController: _scrollController,
              updateParentState: ({
                double? localDy,
                double? localCurrentTimeSlotHeight,
                bool? isScrolled,
              }) {
                updateLocalState(
                  localDy: localDy,
                  localCurrentTimeSlotHeight: localCurrentTimeSlotHeight,
                  isScrolled: isScrolled,
                );
              },
            ),
          // Current Time Indicator
          CurrentTimeIndicator(
            scrollToCurrentTimeIndicator: scrollToCurrentTimeIndicator,
          ),
        ],
      ),
    );
  }

  void updateLocalState({
    double? localDy,
    double? localCurrentTimeSlotHeight,
    bool? isScrolled,
  }) {
    setState(() {
      this.localDy = localDy ?? this.localDy;
      this.localCurrentTimeSlotHeight =
          localCurrentTimeSlotHeight ?? this.localCurrentTimeSlotHeight;
      this.isScrolled = isScrolled ?? this.isScrolled;
    });
  }
}
