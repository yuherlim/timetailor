import 'package:flutter/material.dart';
import 'package:timetailor/screens/task_management/widgets/calendar_painter.dart';

class CalendarWidget extends StatelessWidget {
  final BuildContext context; // Add BuildContext
  final double slotHeight;

  const CalendarWidget({
    super.key,
    required this.context,
    required this.slotHeight,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> timePeriods = [
      '12 AM',
      ' 1 AM',
      ' 2 AM',
      ' 3 AM',
      ' 4 AM',
      ' 5 AM',
      ' 6 AM',
      ' 7 AM',
      ' 8 AM',
      ' 9 AM',
      '10 AM',
      '11 AM',
      '12 PM',
      ' 1 PM',
      ' 2 PM',
      ' 3 PM',
      ' 4 PM',
      ' 5 PM',
      ' 6 PM',
      ' 7 PM',
      ' 8 PM',
      ' 9 PM',
      '10 PM',
      '11 PM'
    ];

    // Calculate the total height for 24 slots
    double calendarHeight = timePeriods.length * slotHeight;

    return CustomPaint(
      size: Size(double.infinity, calendarHeight),
      painter: CalendarPainter(
        timePeriods: timePeriods,
        slotHeight: slotHeight,
        context: context,
      ),
    );
  }
}
