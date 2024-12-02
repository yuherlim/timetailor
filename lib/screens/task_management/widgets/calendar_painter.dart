import 'package:flutter/material.dart';

class CalendarPainter extends CustomPainter {
  final List<String> timePeriods;
  final double slotHeight;

  CalendarPainter({
    required this.timePeriods,
    required this.slotHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maxTextWidth = calculateMaxTextWidth(timePeriods, const TextStyle());

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
        // style: TextStyle(color: Colors.black, fontSize: 14),
      );
      textPainter.layout();

      // Position the text to the left of the line
      textPainter.paint(canvas, Offset(8, y - textPainter.height / 2));

      // Draw the horizontal line
      canvas.drawLine(
          Offset(maxTextWidth + 16, y), Offset(size.width, y), paint);
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
