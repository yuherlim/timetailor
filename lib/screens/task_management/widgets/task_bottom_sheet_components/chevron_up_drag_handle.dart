import 'package:flutter/material.dart';

class ChevronUpPainter extends CustomPainter {
  final Color color;

  ChevronUpPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0 // Thickness of the lines
      ..strokeCap = StrokeCap.round;

    final Path path = Path()
      // Upper Chevron
      ..moveTo(size.width * 0.2, size.height * 0.4)
      ..lineTo(size.width * 0.5, size.height * 0.2)
      ..lineTo(size.width * 0.8, size.height * 0.4);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ChevronUpDragHandle extends StatelessWidget {
  const ChevronUpDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final Color chevronColor =
        Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5);

    return Center(
      child: Container(
        height: 20,
        width: 60,
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        child: CustomPaint(
          painter: ChevronUpPainter(color: chevronColor),
        ),
      ),
    );
  }
}
