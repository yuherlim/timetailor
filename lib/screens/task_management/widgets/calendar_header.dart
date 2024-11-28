import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timetailor/domain/task_management/providers/datebox_animation_provider.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/core/shared/styled_text.dart';

class CalendarHeader extends ConsumerWidget {
  final List<DateTime> weekDates;
  final DateTime currentSelectedDate;
  final Function(DateTime date) onDateSelected;

  const CalendarHeader({
    super.key,
    required this.weekDates,
    required this.currentSelectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    // Watch the state of the dateboxAnimationNotifierProvider
    final dateBoxKeys = ref.watch(dateboxAnimationNotifierProvider);

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
                onDateSelected(date);
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
