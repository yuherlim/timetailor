import 'package:flutter/material.dart';

class CalendarPainter extends CustomPainter {
  final List<String> timePeriods;
  final double slotHeight;
  final BuildContext context; // Add BuildContext
  

  static double slotWidth = 0;
  static double slotStartX = 0;

  CalendarPainter({
    required this.timePeriods,
    required this.slotHeight,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final timePeriodTextStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        );
    final maxTextWidth = calculateMaxTextWidth(timePeriods, timePeriodTextStyle!);

    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < timePeriods.length; i++) {
      final y = i * slotHeight;

      // Draw the time label
      textPainter.text = TextSpan(
        text: timePeriods[i],
        style: timePeriodTextStyle,
      );
      textPainter.layout();

      // Position the text to the left of the line
      textPainter.paint(canvas, Offset(8, y - textPainter.height / 2));

      // Draw the horizontal line
      canvas.drawLine(
          Offset(maxTextWidth + 16, y), Offset(size.width, y), paint);
      
      // Update slot width with line width
      slotWidth = size.width - (maxTextWidth + 16);

      // update slot start x coordinate with sum of text and padding lencth
      slotStartX = maxTextWidth + 24;
    }
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
