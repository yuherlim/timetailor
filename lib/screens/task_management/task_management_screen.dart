import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/widgets/styled_text.dart';
import 'package:timetailor/domain/note_management/providers/notes_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_read_only_provider.dart';
import 'package:timetailor/domain/task_management/providers/current_time_position_provider.dart';
import 'package:timetailor/domain/task_management/providers/date_provider.dart';
import 'package:timetailor/domain/task_management/providers/scroll_controller_provider.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';
import 'package:timetailor/domain/task_management/task_utils.dart';
import 'package:timetailor/domain/user_management/providers/user_provider.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/calendar_header.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/calendar_widget.dart';
import 'package:timetailor/screens/task_management/widgets/task_management_screen/task_bottom_sheet.dart';

class TaskManagementScreen extends StatefulHookConsumerWidget {
  const TaskManagementScreen({super.key});

  @override
  ConsumerState<TaskManagementScreen> createState() =>
      _TaskManagementScreenState();
}

class _TaskManagementScreenState extends ConsumerState<TaskManagementScreen> {
  void calendarButtonOnTap({required DateTime date}) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      ref
          .read(currentDateNotifierProvider.notifier)
          .updateDate(date: selectedDate);
      ref.read(tasksNotifierProvider.notifier).endTaskCreation();
    }
  }

  void _onTaskCreate() {
    final localDyNotifier = ref.read(localDyProvider.notifier);
    final localCurrentTimeSlotHeightNotifier =
        ref.read(localCurrentTimeSlotHeightProvider.notifier);
    final scrollControllerNotifier =
        ref.read(scrollControllerNotifierProvider.notifier);
    final currentTimePosition = ref.read(currentTimePositionNotifierProvider);

    // Binary search to find the correct time slot
    int slotIndex = TaskUtils.binarySearchSlotIndex(
        currentTimePosition, ref.read(timeSlotBoundariesProvider));

    // debugPrint("currentTimePosition: $currentTimePosition");
    // debugPrint("slotIndex: $slotIndex");

    // Handle case where the tap is after the last slot
    if (slotIndex == -1 &&
        currentTimePosition >= ref.read(timeSlotBoundariesProvider).last) {
      slotIndex = ref.read(timeSlotBoundariesProvider).length - 1;
    } else if (slotIndex == -1) {
      debugPrint(
          "slot index not found, something wrong with currentTimeindicator");
      return;
    }

    scrollControllerNotifier.scrollToCurrentTimeIndicator(
      position: currentTimePosition,
      context: context,
    );

    // update local state
    localDyNotifier.state = ref.read(timeSlotBoundariesProvider)[slotIndex];
    localCurrentTimeSlotHeightNotifier.state =
        ref.read(defaultTimeSlotHeightProvider);

    // update local start time and end time with values from draggable box
    ref
        .read(tasksNotifierProvider.notifier)
        .updateTaskTimeStateFromDraggableBox(
          dy: ref.read(localDyProvider),
          currentTimeSlotHeight: ref.read(localCurrentTimeSlotHeightProvider),
        );

    // display draggable box
    ref.read(showDraggableBoxProvider.notifier).state = true;
  }

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
      ref.read(tasksNotifierProvider.notifier).endTaskCreation();

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
    final currentSelectedDate = ref.watch(currentDateNotifierProvider);
    final currentMonth = ref.watch(currentMonthNotifierProvider);
    final isValidDate = ref
        .read(currentDateNotifierProvider.notifier)
        .currentDateMoreThanEqualToday();

    return Stack(
      clipBehavior: Clip.none, // Allow children to overflow the bounds
      children: [
        Scaffold(
          floatingActionButton:
              !ref.watch(showDraggableBoxProvider) && isValidDate
                  ? FloatingActionButton(
                      heroTag: "taskManagementScreenFAB",
                      onPressed: () {
                        _onTaskCreate();
                      },
                      child: const Icon(Icons.add),
                    )
                  : null,
          appBar: AppBar(
            leading: ref.watch(showDraggableBoxProvider)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      ref
                          .read(tasksNotifierProvider.notifier)
                          .endTaskCreation();
                    },
                  )
                : IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: () {
                      calendarButtonOnTap(date: currentSelectedDate);
                    },
                  ),
            title: AppBarText(currentMonth),
            centerTitle: true,
            actions: [
              if (!ref
                  .read(currentDateNotifierProvider.notifier)
                  .currentDateIsToday())
                IconButton(
                  icon: const Icon(Icons.today),
                  onPressed: () {
                    ref
                        .read(currentDateNotifierProvider.notifier)
                        .updateToToday();
                    ref.read(tasksNotifierProvider.notifier).endTaskCreation();
                  },
                ),
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () {
                  ref.read(tasksNotifierProvider.notifier).endTaskCreation();
                  context.go(RoutePath.taskHistoryPath);
                },
              ),
            ],
          ),
          body: const Column(
            children: [
              // Calendar Header
              CalendarHeader(),

              // Task List with Time Indicator
              Expanded(
                child: CalendarWidget(),
              ),
            ],
          ),
        ),
        const TaskBottomSheet()
      ],
    );
  }
}
