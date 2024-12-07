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
  late ScrollController _scrollController;
  double localDy = 0;
  double localCurrentTimeSlotHeight = 0;

  @override
  void initState() {
    _scrollController = ScrollController(); // Initialize the scroll controller

    BackButtonInterceptor.add(_backButtonInterceptor);

    print("init state running...");
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
    super.initState();
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
    // print(location);
    // print(location == RoutePath.taskManagementPath);

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

  int binarySearchSlotIndex(
      double tapPosition, List<double> timeSlotBoundaries) {
    int low = 0;
    int high = timeSlotBoundaries.length - 1;
    int slotIndex = -1;

    while (low <= high) {
      int mid = (low + high) ~/ 2;

      print("low: $low");
      print("mid: $mid");
      print("high: $high");

      if (mid < timeSlotBoundaries.length - 1 &&
          tapPosition >= timeSlotBoundaries[mid] &&
          tapPosition < timeSlotBoundaries[mid + 1]) {
        slotIndex = mid; // Found the slot
        break;
      } else if (tapPosition < timeSlotBoundaries[mid]) {
        high = mid - 1; // Search in the left half
      } else {
        low = mid + 1; // Search in the right half
      }
    }
    return slotIndex;
  }

  @override
  Widget build(BuildContext context) {
    final currentCalendarState = ref.watch(calendarStateNotifierProvider);
    final calendarStateNotifier =
        ref.read(calendarStateNotifierProvider.notifier);

    return SingleChildScrollView(
      controller: _scrollController,
      child: Stack(
        children: [
          // Calendar widget
          GestureDetector(
            onTapUp: (details) {
              // if draggable box already created, reset state
              print("showBox: ${currentCalendarState.showDraggableBox}");
              if (currentCalendarState.showDraggableBox) {
                calendarStateNotifier
                    .toggleDraggableBox(!currentCalendarState.showDraggableBox);

                print("=================");
                print("enter reset state");
                print("=================");
                setState(() {
                  localDy = 0;
                  localCurrentTimeSlotHeight = 0;
                });
                return;
              }

              final tapPosition = details.localPosition.dy;

              // Binary search to find the correct time slot
              int slotIndex = binarySearchSlotIndex(
                  tapPosition, currentCalendarState.timeSlotBoundaries);

              print("slotIndex before handling: $slotIndex");

              // Handle case where the tap is after the last slot
              if (slotIndex == -1 &&
                  tapPosition >= currentCalendarState.timeSlotBoundaries.last) {
                slotIndex = currentCalendarState.timeSlotBoundaries.length - 1;
              }

              print(
                  "timeSlotBoundaries: ${currentCalendarState.timeSlotBoundaries.toString()}");
              print("relative calendar tap position: $tapPosition");
              print("local tap position: ${details.localPosition.dy}");
              print("slotIndex: $slotIndex");
              print(
                  "timeSlotStartingY: ${currentCalendarState.timeSlotBoundaries[slotIndex]}");

              // Snap to the correct time slot
              if (slotIndex != -1) {
                calendarStateNotifier.updateDraggableBoxPosition(
                  dx: currentCalendarState.slotStartX,
                  dy: currentCalendarState.timeSlotBoundaries[slotIndex],
                );
                calendarStateNotifier.updateCurrentTimeSlotHeight(
                    currentCalendarState.defaultTimeSlotHeight); // Reset height
                calendarStateNotifier.toggleDraggableBox(true);

                // update local state
                setState(() {
                  localDy = currentCalendarState.timeSlotBoundaries[slotIndex];
                  localCurrentTimeSlotHeight =
                      currentCalendarState.defaultTimeSlotHeight;
                });
              }
            },
            child: CalendarWidgetBackground(
              context: this.context,
              slotHeight: currentCalendarState.defaultTimeSlotHeight,
              snapInterval: currentCalendarState.snapIntervalHeight,
              topPadding: CalendarState.calendarWidgetTopBoundaryY,
              bottomPadding: CalendarState.calendarBottomPadding,
            ),
          ),
          if (currentCalendarState.showDraggableBox)
            DraggableBox(
              localDy: localDy,
              localCurrentTimeSlotHeight: localCurrentTimeSlotHeight,
            ),
          if (currentCalendarState.showDraggableBox)
            TopIndicator(
              scrollController: _scrollController,
              localDy: localDy,
              localCurrentTimeSlotHeight: localCurrentTimeSlotHeight,
              onDyOrCurrentTimeSlotHeightUpdate: (
                  {double? localCurrentTimeSlotHeight, double? localDy}) {
                setState(() {
                  localDy = localDy ?? this.localDy;
                  localCurrentTimeSlotHeight =
                      localCurrentTimeSlotHeight ?? this.localCurrentTimeSlotHeight;
                });
              },
            ),
          if (currentCalendarState.showDraggableBox)
            BottomIndicator(
              scrollController: _scrollController,
              localDy: localDy,
              localCurrentTimeSlotHeight: localCurrentTimeSlotHeight,
              onDyOrCurrentTimeSlotHeightUpdate: (
                  {double? localCurrentTimeSlotHeight, double? localDy}) {
                setState(() {
                  localDy = localDy ?? this.localDy;
                  localCurrentTimeSlotHeight =
                      localCurrentTimeSlotHeight ?? this.localCurrentTimeSlotHeight;
                });
              },
            ),
          // Current Time Indicator
          CurrentTimeIndicator(
              scrollToCurrentTimeIndicator: scrollToCurrentTimeIndicator),
        ],
      ),
    );
  }
}
