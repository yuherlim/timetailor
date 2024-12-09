import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timetailor/core/constants/route_path.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/domain/task_management/providers/calendar_local_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_read_only_provider.dart';
import 'package:timetailor/domain/task_management/providers/task_time_slot_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/current_time_position_provider.dart';
import 'package:timetailor/domain/task_management/providers/date_provider.dart';
import 'package:timetailor/domain/task_management/providers/scroll_controller_provider.dart';
import 'package:timetailor/domain/task_management/task_manager.dart';
import 'package:timetailor/screens/task_management/widgets/calendar_header.dart';
import 'package:timetailor/screens/task_management/widgets/calendar_widget.dart';

class TaskManagementScreen extends ConsumerStatefulWidget {
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
    }
  }

  void _onTaskCreate() {
    final taskTimeSlotStateNotifier =
        ref.read(taskTimeSlotStateNotifierProvider.notifier);
    final localDyNotifier = ref.read(localDyProvider.notifier);
    final localCurrentTimeSlotHeightNotifier =
        ref.read(localCurrentTimeSlotHeightProvider.notifier);
    final scrollControllerNotifier =
        ref.read(scrollControllerNotifierProvider.notifier);
    final currentTimePosition = ref.read(currentTimePositionNotifierProvider);

    // Binary search to find the correct time slot
    int slotIndex = TaskManager.binarySearchSlotIndex(
        currentTimePosition, ref.read(timeSlotBoundariesProvider));

    debugPrint("currentTimePosition: $currentTimePosition");
    debugPrint("slotIndex: $slotIndex");

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

    taskTimeSlotStateNotifier.updateDraggableBoxPosition(
      dx: ref.read(slotStartXProvider),
      dy: ref.read(timeSlotBoundariesProvider)[slotIndex],
    );
    taskTimeSlotStateNotifier.updateCurrentTimeSlotHeight(
        ref.read(defaultTimeSlotHeightProvider)); // Reset height
    ref.read(showDraggableBoxProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    final currentSelectedDate = ref.watch(currentDateNotifierProvider);
    final currentMonth = ref.watch(currentMonthNotifierProvider);

    return Scaffold(
      floatingActionButton: !ref.watch(showDraggableBoxProvider)
          ? FloatingActionButton(
              onPressed: () {
                ref.read(showDraggableBoxProvider.notifier).state = true;
                _onTaskCreate();
              },
              child: const Icon(Icons.add),
            )
          : null,
      appBar: AppBar(
        leading: IconButton(
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
                ref.read(currentDateNotifierProvider.notifier).updateToToday();
              },
            ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              context
                  .go(RoutePath.taskHistoryPath); // Navigate to task creation
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
    );
  }
}
