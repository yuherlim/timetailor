import 'package:flutter/material.dart';

class CalendarPainter extends CustomPainter {
  final List<String> timePeriods;
  final double slotHeight;
  final double snapInterval;
  final double topPadding;
  final BuildContext context; // Add BuildContext

  static double slotWidth = 0;
  static double slotStartX = 0;
  int numberOfIntervals = 0;

  CalendarPainter({
    required this.timePeriods,
    required this.slotHeight,
    required this.snapInterval,
    required this.context,
    required this.topPadding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final timePeriodTextStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        );
    final maxTextWidth =
        calculateMaxTextWidth(timePeriods, timePeriodTextStyle!);

    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    double verticalPadding = topPadding;
    const double horizontalPadding = 16;
    const double textPadding = 16;
    const double intervalLineWidthSmall = 16;
    const double intervalLineWidthLarge = 32;
    double lastLineY = timePeriods.length * slotHeight + verticalPadding;

    numberOfIntervals = (slotHeight > 0 && snapInterval > 0)
        ? (slotHeight / snapInterval).toInt()
        : 0;

    // print("numberOfIntervals: $numberOfIntervals");

    // update slot start x coordinate with sum of text and padding lencth
    slotStartX =
        (horizontalPadding + maxTextWidth + textPadding).floorToDouble();

    // Update slot width with line width
    slotWidth = size.width - horizontalPadding - slotStartX;

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
      canvas.drawLine(Offset(slotStartX, y),
          Offset(size.width - horizontalPadding, y), paint);

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
        Offset(slotStartX, lastLineY),
        Offset(size.width - horizontalPadding, lastLineY),
        paint);

    print("slotStart in painter: $slotStartX");
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // No need to repaint unless the times change
  }

  double calculateMaxTextWidth(List<String> timePeriods, TextStyle textStyle) {
    double maxWidth = 0.0;

    final textPainter = TextPainter(
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    for (final time in timePeriods) {
      textPainter.text = TextSpan(
        text: time,
        style: textStyle,
      );
      textPainter.layout(); // Calculate the dimensions of the text
      maxWidth = maxWidth < textPainter.width ? textPainter.width : maxWidth;
    }

    return maxWidth;
  }
}
