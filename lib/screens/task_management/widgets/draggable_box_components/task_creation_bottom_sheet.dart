import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';

void showTaskCreationBottomSheet({
  required BuildContext context,
  required WidgetRef ref,
  required VoidCallback onConfirm,
}) {
  final startTime = ref.watch(startTimeProvider);
  final endTime = ref.watch(endTimeProvider);

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: onConfirm,
              child: const Text('Confirm Task Time'),
            ),
            const SizedBox(height: 16), // Spacing
            Text(
              'Start Time: $startTime\nEnd Time: $endTime',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ],
        ),
      );
    },
  );
}