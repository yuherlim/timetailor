import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/domain/task_management/providers/bottom_sheet_scroll_controller_provider.dart';

class MiddleDragHandle extends ConsumerWidget {
  const MiddleDragHandle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(bottomSheetScrollControllerNotifierProvider.notifier).scrollToMaxExtent(),
      child: Center(
        child: Container(
          height: 4,
          width: 40,
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
