import 'package:flutter/material.dart';

class CalendarPainter extends CustomPainter {
  final List<String> timePeriods;
  final double slotHeight;
  final double snapInterval;
  final double topPadding;
  final void Function({
    required double slotStartX,
    required double slotWidth,
    required double sidePadding,
    required double textPadding,
  }) onSlotCalendarPainted;
  final BuildContext context; // Add BuildContext

  CalendarPainter({
    required this.timePeriods,
    required this.slotHeight,
    required this.snapInterval,
    required this.context,
    required this.topPadding,
    required this.onSlotCalendarPainted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final timePeriodTextStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        );

    // 10% of the screen width.
    final maxTextWidth = size.width * 0.1;

    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    int numberOfIntervals = 0;
    double slotEndX = 0;
    double slotStartX = 0;
    double slotWidth = 0;
    double horizontalLineStartX = 0;
    double verticalPadding = topPadding;
    const double horizontalPadding = 16;
    const double textPadding = 16;
    const double intervalLineWidthSmall = 16;
    const double intervalLineWidthLarge = 32;
    double calendarHeight = slotHeight * 24;
    double lastLineY = timePeriods.length * slotHeight + verticalPadding;
    double verticalLineStartY = verticalPadding;
    double verticalLineEndY = verticalPadding + calendarHeight;

    numberOfIntervals = (slotHeight > 0 && snapInterval > 0)
        ? (slotHeight / snapInterval).toInt()
        : 0;

    // update slot start x coordinate with sum of text and padding lencth
    slotStartX =
        (horizontalPadding + maxTextWidth + textPadding).floorToDouble();

    slotEndX = (size.width - horizontalPadding).floorToDouble();

    // Update slot width with line width
    slotWidth = slotEndX - slotStartX;

    // calculate horizontalLineStartX for hour lines.
    horizontalLineStartX = slotStartX - 8;

    // callback to notify state changes in due to calendar painted.
    onSlotCalendarPainted(
      slotStartX: slotStartX,
      slotWidth: slotWidth,
      sidePadding: horizontalPadding,
      textPadding: textPadding,
    );

    for (int i = 0; i < timePeriods.length; i++) {
      final y = i * slotHeight + verticalPadding;

      // Draw the time label
      textPainter.text = TextSpan(
        text: timePeriods[i],
        style: timePeriodTextStyle,
      );
      textPainter.layout();

      // Position the text to the left of the line
      textPainter.paint(
          canvas, Offset(horizontalPadding, y - textPainter.height * 0.5));

      // Draw the horizontal line
      canvas.drawLine(Offset(horizontalLineStartX, y), Offset(slotEndX, y), paint);

      // Draw the 5 min interval lines
      for (int j = 0; j < numberOfIntervals; j++) {
        if (j != 0) {
          final yToDraw = y + j * snapInterval;
          // 30 minute mark, draw a longer line.
          if (j == 6) {
            canvas.drawLine(
              Offset(slotStartX, yToDraw),
              Offset(slotStartX + intervalLineWidthLarge, yToDraw),
              paint,
            );
          }
          canvas.drawLine(
            Offset(slotStartX, yToDraw),
            Offset(slotStartX + intervalLineWidthSmall, yToDraw),
            paint,
          );
        }
      }
    }

    // Draw the last horizontal line
    canvas.drawLine(
        Offset(slotStartX, lastLineY), Offset(slotEndX, lastLineY), paint);

    

    // Draw the vertical line
    canvas.drawLine(Offset(slotStartX, verticalLineStartY),
        Offset(slotStartX, verticalLineEndY), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // No need to repaint unless the times change
  }
}
