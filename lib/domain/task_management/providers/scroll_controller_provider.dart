import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_read_only_provider.dart';

part 'scroll_controller_provider.g.dart'; // Generated file

@riverpod
class ScrollControllerNotifier extends _$ScrollControllerNotifier {
  Timer? _scrollTimer;

  @override
  ScrollController build() {
    // Register cleanup logic
    ref.onDispose(() {
      stopAutoScroll();
      state.dispose();
    });

    return ScrollController();
  }

  void scrollUp({required double scrollAmount}) {
    final isScrolledNotifier = ref.read(isScrolledProvider.notifier);
    // reset isScrolled state
    isScrolledNotifier.state = false;

    // perform extra scrolling
    final scrollOffset = state.offset;
    if (scrollOffset > 0) {
      state.animateTo(
        (scrollOffset - scrollAmount).clamp(0.0, double.infinity),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void startUpwardsAutoScroll() {
    double scrollAmount = ref.read(autoScrollAmountProvider);

    final localDyNotifier = ref.read(localDyProvider.notifier);
    final localCurrentTimeSlotHeightNotifier =
        ref.read(localCurrentTimeSlotHeightProvider.notifier);

    stopAutoScroll(); // Stop any ongoing scroll
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final localDy = ref.read(localDyProvider);
      final localCurrentTimeSlotHeight =
          ref.read(localCurrentTimeSlotHeightProvider);
      final maxTaskHeight = ref.read(maxTaskHeightProvider);

      final currentOffset = state.offset;
      final minScrollExtent = state.position.minScrollExtent;

      if (currentOffset > minScrollExtent) {
        state.jumpTo(
          max(minScrollExtent, (currentOffset - scrollAmount)), // Scroll up
        );
        final newDy = max(ref.read(calendarWidgetTopBoundaryYProvider),
            (localDy - scrollAmount));
        final double newSize = (localCurrentTimeSlotHeight + scrollAmount)
            .clamp(ref.read(snapIntervalHeightProvider), maxTaskHeight);

        // update local state
        localDyNotifier.state = newDy;
        localCurrentTimeSlotHeightNotifier.state = newSize;
      } else {
        stopAutoScroll(); // Stop scrolling if we reach the end
      }
    });
  }

  void startBottomBoundaryUpwardsAutoScroll() {
    double scrollAmount = ref.read(autoScrollAmountProvider);

    final localCurrentTimeSlotHeightNotifier =
        ref.read(localCurrentTimeSlotHeightProvider.notifier);

    stopAutoScroll(); // Stop any ongoing scroll
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final localDy = ref.read(localDyProvider);
      final localCurrentTimeSlotHeight =
          ref.read(localCurrentTimeSlotHeightProvider);
      final maxTaskHeight = ref.read(maxTaskHeightProvider);
      final snapIntervalHeight = ref.read(snapIntervalHeightProvider);

      final currentOffset = state.offset;
      final minScrollExtent = state.position.minScrollExtent;

      if (currentOffset > minScrollExtent) {
        state.jumpTo(
          max(localDy + snapIntervalHeight,
              (currentOffset - scrollAmount)), // Scroll up
        );
        final double newSize = (localCurrentTimeSlotHeight - scrollAmount)
            .clamp(ref.read(snapIntervalHeightProvider), maxTaskHeight);

        // update local state
        localCurrentTimeSlotHeightNotifier.state = newSize;
      } else {
        stopAutoScroll(); // Stop scrolling if we reach the end
      }
    });
  }

  void scrollDown({required double scrollAmount}) {
    final isScrolledNotifier = ref.read(isScrolledProvider.notifier);

    // reset isScrolled state
    isScrolledNotifier.state = false;

    // perform extra scrolling
    final scrollOffset = state.offset;
    final maxScrollExtent = state.position.maxScrollExtent;
    if (scrollOffset < maxScrollExtent) {
      state.animateTo(
        (scrollOffset + scrollAmount).clamp(0.0, maxScrollExtent),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void startDownwardsAutoScroll() {
    double scrollAmount = ref.read(autoScrollAmountProvider);

    final localCurrentTimeSlotHeightNotifier =
        ref.read(localCurrentTimeSlotHeightProvider.notifier);

    stopAutoScroll(); // Stop any ongoing scroll
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final localCurrentTimeSlotHeight =
          ref.read(localCurrentTimeSlotHeightProvider);
      final maxTaskHeight = ref.read(maxTaskHeightProvider);

      final currentOffset = state.offset;
      final maxScrollExtent = state.position.maxScrollExtent;

      if (currentOffset < maxScrollExtent) {
        state.jumpTo(
          (currentOffset + scrollAmount)
              .clamp(0, maxScrollExtent), // Scroll down
        );
        final double newSize = (localCurrentTimeSlotHeight + scrollAmount)
            .clamp(ref.read(snapIntervalHeightProvider), maxTaskHeight);

        // update local state
        localCurrentTimeSlotHeightNotifier.state = newSize;
      } else {
        stopAutoScroll(); // Stop scrolling if we reach the end
      }
    });
  }

  void startTopBoundaryDownwardsAutoScroll() {
    double scrollAmount = ref.read(autoScrollAmountProvider);

    final localCurrentTimeSlotHeightNotifier =
        ref.read(localCurrentTimeSlotHeightProvider.notifier);
    final localDyNotifier = ref.read(localDyProvider.notifier);

    stopAutoScroll(); // Stop any ongoing scroll
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final localCurrentTimeSlotHeight =
          ref.read(localCurrentTimeSlotHeightProvider);
      final dyTop = ref.read(localDyProvider);
      final dyBottom = ref.read(localDyBottomProvider);
      final snapIntervalHeight = ref.read(snapIntervalHeightProvider);
      final currentOffset = state.offset;
      final maxScrollExtent = state.position.maxScrollExtent;
      final minTimeSlotDy = dyBottom - snapIntervalHeight;

      if (currentOffset < maxScrollExtent) {
        state.jumpTo(
          (currentOffset + scrollAmount)
              .clamp(0, minTimeSlotDy), // Scroll down
        );
        final double newDy = min(dyTop + scrollAmount, minTimeSlotDy);
        final double newSize = (localCurrentTimeSlotHeight - scrollAmount)
            .clamp(snapIntervalHeight, double.infinity);

        // update local state
        localDyNotifier.state = newDy;
        localCurrentTimeSlotHeightNotifier.state = newSize;
      } else {
        stopAutoScroll(); // Stop scrolling if we reach the end
      }
    });
  }

  void startUpwardsAutoDrag() {
    double scrollAmount = ref.read(autoScrollAmountProvider);

    final localDyNotifier = ref.read(localDyProvider.notifier);

    stopAutoScroll(); // Stop any ongoing scroll
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final localDy = ref.read(localDyProvider);

      final currentOffset = state.offset;
      final minScrollExtent = state.position.minScrollExtent;

      if (currentOffset > minScrollExtent) {
        state.jumpTo(
          max(0.0, (currentOffset - scrollAmount)), // Scroll up
        );
        final newDy = max(ref.read(calendarWidgetTopBoundaryYProvider),
            (localDy - scrollAmount));

        // update local state
        localDyNotifier.state = newDy;
      } else {
        stopAutoScroll(); // Stop scrolling if we reach the end
      }
    });
  }

  void startDownwardsAutoDrag() {
    double scrollAmount = ref.read(autoScrollAmountProvider);

    final localDyNotifier = ref.read(localDyProvider.notifier);

    stopAutoScroll(); // Stop any ongoing scroll
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final localDy = ref.read(localDyProvider);
      final localCurrentTimeSlotHeight =
          ref.read(localCurrentTimeSlotHeightProvider);
      // Ensure that the new dy considers the time slot height.
      final upperLimit = ref.read(calendarWidgetBottomBoundaryYProvider) -
          localCurrentTimeSlotHeight;

      final currentOffset = state.offset;
      final maxScrollExtent = state.position.maxScrollExtent;

      if (currentOffset < maxScrollExtent) {
        state.jumpTo(
          (currentOffset + scrollAmount)
              .clamp(0, maxScrollExtent), // Scroll down
        );

        final newDy = (localDy + scrollAmount).clamp(0.0, upperLimit);

        // update local state
        localDyNotifier.state = newDy;
      } else {
        stopAutoScroll(); // Stop scrolling if we reach the end
      }
    });
  }

  void stopAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
  }

  void scrollToCurrentTimeIndicator(
      {required double position, required BuildContext context}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenHeight = MediaQuery.of(context).size.height;
      state.animateTo(
        position - screenHeight * 0.3,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    });
  }
}
