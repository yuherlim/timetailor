import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calendar_state_provider.g.dart';

// to be initialized after widget build
final screenHeightProvider = StateProvider<double>((ref) => 0.0);
final maxBottomSheetExtentProvider = StateProvider<double>((ref) => 0.0);

final localDyProvider = StateProvider<double>((ref) => 0.0);
final localCurrentTimeSlotHeightProvider = StateProvider<double>((ref) => 0.0);
final localDyBottomProvider = StateProvider<double>((ref) =>
    ref.read(localDyProvider) + ref.read(localCurrentTimeSlotHeightProvider));
final showDraggableBoxProvider = StateProvider<bool>((ref) => false);
final isScrolledProvider = StateProvider<bool>((ref) => false);
final isScrolledUpProvider = StateProvider<bool>((ref) => false);
final maxTaskHeightProvider = StateProvider<double>((ref) => 0.0);
final slotStartXProvider = StateProvider<double>((ref) => 0.0);
final slotWidthProvider = StateProvider<double>((ref) => 0.0);
final sidePaddingProvider = StateProvider<double>((ref) => 0.0);
final textPaddingProvider = StateProvider<double>((ref) => 0.0);
final startTimeProvider = StateProvider<String>((ref) => "N/A");
final endTimeProvider = StateProvider<String>((ref) => "N/A");

@riverpod
class InitialBottomSheetExtent extends _$InitialBottomSheetExtent {
  static const initialValue = 0.15;

  @override
  double build() => initialValue;

  void update(double value) {
    state = value;
  }

  void reinitialize() {
    state = initialValue;
  }
}

@riverpod
class SheetExtent extends _$SheetExtent {
  @override
  double build() {
    print("is rebuilt.");
    return ref.watch(initialBottomSheetExtentProvider);
  }

  void hideBottomSheet() {
    ref.read(showBottomSheetProvider.notifier).state = false;
  }

  void redisplayBottomSheet() {
    // ensure that the intialBottomSheetExtent value is updated to the current sheet extent value
    // helps to ensure that the bottom sheet is rebuilt to the current user's view of the bottom sheet.

    print("current sheet extent: $state");

    ref.read(initialBottomSheetExtentProvider.notifier).update(state);
    // Check the state after the frame is completed
    print(
        "initial bottomSheet now after frame: ${ref.read(initialBottomSheetExtentProvider)}");

    // display back bottom sheet when drag end
    ref.read(showBottomSheetProvider.notifier).state = true;
  }

  void update(double value) {
    print("sheetExtentProvider state updated to: $value");
    state = value;
  }
}

final showBottomSheetProvider = StateProvider<bool>((ref) => true);
