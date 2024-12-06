import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/domain/task_management/providers/calendar_widget_provider.dart';
import 'package:timetailor/screens/task_management/widgets/calendar_painter.dart';

class CalendarWidget extends ConsumerWidget {
  final BuildContext context; // Add BuildContext
  final double slotHeight;
  final double snapInterval;
  final double bottomPadding;
  final double topPadding;

  const CalendarWidget({
    super.key,
    required this.context,
    required this.slotHeight,
    required this.snapInterval,
    required this.bottomPadding,
    required this.topPadding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: CustomPaint(
        size: Size(double.infinity, calendarHeight),
        painter: CalendarPainter(
          timePeriods: timePeriods,
          slotHeight: slotHeight,
          snapInterval: snapInterval,
          context: context,
          topPadding: topPadding,
          onSlotStartXCalculated: (slotStartX) {
            // Delay the update to avoid lifecycle issues
            Future.microtask(() {
              ref
                  .read(slotStartXNotifierProvider.notifier)
                  .updateSlotStartX(slotStartX);

              print("");
              print("===============================");
              print("DEBUGGING UI bug in calendar widget");
              print("===============================");
              print("");

              print("Updated slotStartX in provider: $slotStartX");
              print("===============================");
            });
          },
        ),
      ),
    );
  }
}
