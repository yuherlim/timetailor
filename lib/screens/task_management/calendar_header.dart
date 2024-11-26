import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/core/shared/styled_text.dart';

class CalendarHeader extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: weekDates.map((date) {
          return GestureDetector(
            onTap: () {
              onDateSelected(date);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: currentSelectedDate == date
                    ? AppColors.primaryColor
                    : AppColors.secondaryColor,
              ),
              child: Column(
                children: [
                  StyledText(
                    DateFormat('EEE').format(date), // Day of the week
                  ),
                  StyledText(
                    date.day.toString(), // Date
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
