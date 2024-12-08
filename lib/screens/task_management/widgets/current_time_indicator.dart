import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/task_management/providers/calendar_local_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_read_only_provider.dart';
import 'package:timetailor/domain/task_management/providers/current_time_position_provider.dart';
import 'package:timetailor/domain/task_management/providers/scroll_controller_provider.dart';

class CurrentTimeIndicator extends ConsumerStatefulWidget {
  const CurrentTimeIndicator({
    super.key,
  });

  @override
  ConsumerState<CurrentTimeIndicator> createState() =>
      _CurrentTimeIndicatorState();
}

class _CurrentTimeIndicatorState extends ConsumerState<CurrentTimeIndicator> {

  @override
  Widget build(BuildContext context) {
    final timeIndicatorIconSize = ref.watch(timeIndicatorIconSizeProvider);
    final topPosition = ref.watch(currentTimePositionNotifierProvider);

    ref
        .read(scrollControllerNotifierProvider.notifier)
        .scrollToCurrentTimeIndicator(position: topPosition, context: context);

    // time indicator position
    final screenWidth = MediaQuery.of(context).size.width;
    final indicatorSidePadding = ref.read(sidePaddingProvider);
    final textPadding = ref.read(textPaddingProvider);
    final timeIndicatorStartX = indicatorSidePadding +
        screenWidth * 0.1 +
        textPadding -
        timeIndicatorIconSize * 0.5;

    return Positioned(
      top: topPosition, // Dynamically calculate this position
      left: timeIndicatorStartX,
      right: 0,
      child: Row(
        children: [
          Container(
            width: timeIndicatorIconSize, // Diameter of the circle
            height: timeIndicatorIconSize,
            decoration: BoxDecoration(
              color: AppColors.timeIndicatorColor, // Color of the circle
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: indicatorSidePadding),
              child: SizedBox(
                height: timeIndicatorIconSize,
                child: Divider(
                  color: AppColors.timeIndicatorColor,
                  thickness: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
