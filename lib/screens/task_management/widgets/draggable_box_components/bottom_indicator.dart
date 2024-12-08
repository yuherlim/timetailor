import 'package:flutter/material.dart';
import 'package:timetailor/core/theme/custom_theme.dart';

class BottomIndicator extends StatelessWidget {
  final double indicatorWidth;
  final double indicatorHeight;

  const BottomIndicator({
    super.key,
    required this.indicatorWidth,
    required this.indicatorHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: indicatorWidth,
      height: indicatorHeight,
      decoration: BoxDecoration(
        color: AppColors.primaryAccent,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Center(
        child: Icon(
          Icons.arrow_downward,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}
