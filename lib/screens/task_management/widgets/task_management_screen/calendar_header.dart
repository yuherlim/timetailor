import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timetailor/domain/task_management/providers/datebox_animation_provider.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/core/shared/styled_text.dart';
import 'package:timetailor/domain/task_management/providers/date_provider.dart';
import 'package:timetailor/domain/task_management/providers/tasks_provider.dart';

class CalendarHeader extends ConsumerWidget {
  const CalendarHeader({
    super.key,
  });

  // Helper function to trigger ripple animation
  void _triggerRipple(GlobalKey? key, BuildContext context) {
    if (key == null) {
      debugPrint("No GlobalKey for this date");
      return;
    }

    final boxContext = key.currentContext;
    if (boxContext == null) {
      debugPrint("No context for this GlobalKey");
      return;
    }

    final renderBox = boxContext.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      debugPrint("No RenderBox for this GlobalKey");
      return;
    }

    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;

    if (overlay == null) {
      debugPrint("No Overlay found for context");
      return;
    }

    // Calculate the position of the ripple effect
    final position = renderBox.localToGlobal(
      renderBox.size.center(Offset.zero),
      ancestor: overlay,
    );

    // Trigger the ripple effect
    final materialState = Material.of(boxContext);

    InkRipple(
      position: position,
      color: Colors.blue.withOpacity(0.2), // Ripple color
      borderRadius: BorderRadius.circular(8), // Match your container's radius
      controller: materialState, // Use MaterialState for animation control
      referenceBox: renderBox, // The RenderBox to apply the ripple
      textDirection: ui.TextDirection.ltr, // Ensure correct ripple direction
    ).confirm();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSelectedDate = ref.watch(currentDateNotifierProvider);
    final weekDates = ref.watch(currentWeekDatesNotifierProvider);
    // Watch the state of the dateboxAnimationNotifierProvider
    final dateBoxKeys = ref.watch(dateboxAnimationNotifierProvider);

    // Total horizontal padding of the parent container
    const double horizontalPadding = 16; // 8 (left) + 8 (right)
    const double spacingBetweenContainers = 6; // Space between each container
    final int numberOfDates = weekDates.length;

    // Calculate available width for the containers
    final double availableWidth = MediaQuery.of(context).size.width -
        horizontalPadding -
        (spacingBetweenContainers * (numberOfDates - 1));

    // Width for each container
    final double containerWidth = availableWidth / numberOfDates;

    // Listen for changes in the animation state
    ref.listen<Map<DateTime, GlobalKey>>(dateboxAnimationNotifierProvider,
        (_, state) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerRipple(state[ref.watch(currentDateNotifierProvider)], context);
      });
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: weekDates.map((date) {
          return Material(
            borderRadius: BorderRadius.circular(8),
            color: currentSelectedDate == date
                ? AppColors.primaryColor
                : AppColors.secondaryColor,
            child: InkWell(
              key: dateBoxKeys[date], // Use GlobalKey for this date
              onTap: () {
                ref
                    .read(currentDateNotifierProvider.notifier)
                    .updateDate(date: date);
                ref.read(tasksNotifierProvider.notifier).cancelTaskCreation();
              },
              borderRadius: BorderRadius.circular(8),
              splashColor: Colors.blue.withOpacity(0.2), // Ripple color
              highlightColor: Colors.white.withOpacity(0.1), // Highlight effect
              child: Container(
                width: containerWidth,
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    DateDayText(
                      DateFormat('EEE').format(date), // Day of the week
                    ),
                    DateNumberText(
                      date.day.toString(), // Date
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
