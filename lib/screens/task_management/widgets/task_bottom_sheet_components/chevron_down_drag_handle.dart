import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/domain/task_management/providers/bottom_sheet_scroll_controller_provider.dart';

class ChevronDownPainter extends CustomPainter {
  final Color color;

  ChevronDownPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0 // Thickness of the lines
      ..strokeCap = StrokeCap.round;

    final Path path = Path()
      // Lower Chevron
      ..moveTo(size.width * 0.2, size.height * 0.6)
      ..lineTo(size.width * 0.5, size.height * 0.8)
      ..lineTo(size.width * 0.8, size.height * 0.6);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ChevronDownDragHandle extends ConsumerWidget {
  const ChevronDownDragHandle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color chevronColor =
        Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5);

    return GestureDetector(
      onTap: () => ref.read(bottomSheetScrollControllerNotifierProvider.notifier).scrollToMiddleExtent(),
      child: Center(
        child: Container(
          height: 20,
          width: 60,
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          child: CustomPaint(
            painter: ChevronDownPainter(color: chevronColor),
          ),
        ),
      ),
    );
  }
}
