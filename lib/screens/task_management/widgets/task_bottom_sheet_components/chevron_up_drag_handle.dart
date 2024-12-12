import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/domain/task_management/providers/bottom_sheet_scroll_controller_provider.dart';

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

class ChevronUpDragHandle extends ConsumerWidget {
  const ChevronUpDragHandle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color chevronColor =
        Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5);

    return GestureDetector(
      onTap: () {
        print("ontap triggered");
        ref.read(bottomSheetScrollControllerNotifierProvider.notifier).scrollToMiddleExtent();
      },
      child: Center(
        child: Container(
          height: 20,
          width: 60,
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          child: CustomPaint(
            painter: ChevronUpPainter(color: chevronColor),
          ),
        ),
      ),
    );
  }
}
