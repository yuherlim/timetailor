import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timetailor/domain/task_management/providers/calendar_read_only_provider.dart';

part 'calendar_state_provider.g.dart';

// to be initialized after widget build
final screenHeightProvider = StateProvider<double>((ref) => 0.0);
final maxBottomSheetExtentProvider = StateProvider<double>((ref) => 0.0);

final localDyProvider = StateProvider<double>((ref) => 0.0);
final localCurrentTimeSlotHeightProvider = StateProvider<double>((ref) => 0.0);
final localDyBottomProvider = StateProvider<double>((ref) =>
    ref.watch(localDyProvider) + ref.watch(localCurrentTimeSlotHeightProvider));
final showDraggableBoxProvider = StateProvider<bool>((ref) => false);

final isDraggableBoxLongPressedProvider = StateProvider<bool>((ref) => false);
final lastLongPressOffsetProvider = StateProvider<Offset>((ref) => Offset.zero);
final isResizingProvider = StateProvider<bool>((ref) => false);

final isScrolledProvider = StateProvider<bool>((ref) => false);
final isScrolledUpProvider = StateProvider<bool>((ref) => false);

final maxTaskHeightProvider = StateProvider<double>((ref) => 0.0);
final slotStartXProvider = StateProvider<double>((ref) => 0.0);
final slotWidthProvider = StateProvider<double>((ref) => 0.0);
final sidePaddingProvider = StateProvider<double>((ref) => 0.0);
final textPaddingProvider = StateProvider<double>((ref) => 0.0);
final startTimeProvider = StateProvider<String>((ref) => "N/A");
final endTimeProvider = StateProvider<String>((ref) => "N/A");
final durationProvider = StateProvider<String>((ref) => "N/A");

final dragIndicatorWidthProvider = StateProvider<double>((ref) => ref.watch(slotWidthProvider));
final dragIndicatorHeightProvider = StateProvider<double>((ref) => ref.watch(localCurrentTimeSlotHeightProvider));


@riverpod
class SheetExtent extends _$SheetExtent {
  @override
  double build() {
    return ref.watch(initialBottomSheetExtentProvider);
  }

  void hideBottomSheet() {
    ref.read(showBottomSheetProvider.notifier).state = false;
  }

  void redisplayBottomSheet() {
    // display back bottom sheet when drag end
    ref.read(showBottomSheetProvider.notifier).state = true;
  }

  void update(double value) {
    state = value;
  }
}

final showBottomSheetProvider = StateProvider<bool>((ref) => true);
