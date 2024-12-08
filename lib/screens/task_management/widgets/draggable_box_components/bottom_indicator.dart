import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/task_management/providers/calendar_local_state_provider.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';

class BottomIndicator extends ConsumerStatefulWidget {
  final double indicatorWidth;
  final double indicatorHeight;
  final ScrollController scrollController;

  const BottomIndicator({
    super.key,
    required this.indicatorWidth,
    required this.indicatorHeight,
    required this.scrollController,
  });

  @override
  ConsumerState<BottomIndicator> createState() => _BottomIndicatorState();
}

class _BottomIndicatorState extends ConsumerState<BottomIndicator> {
  Timer? _scrollTimer;

  void _handleBottomDrag({
    required DragUpdateDetails details,
  }) {
    final currentCalendarState = ref.read(calendarStateNotifierProvider);
    final calendarStateNotifier =
        ref.read(calendarStateNotifierProvider.notifier);
    final localCurrentTimeSlotHeightNotifier = ref.read(localCurrentTimeSlotHeightProvider.notifier);
    final isScrolledNotifier = ref.read(isScrolledProvider.notifier);
    final localDy = ref.watch(localDyProvider);
    final localCurrentTimeSlotHeight = ref.watch(localCurrentTimeSlotHeightProvider);

    // Get the scroll offset of the calendar
    final scrollOffset = widget.scrollController.offset;
    final remainingScrollableContentInView =
        widget.scrollController.position.viewportDimension;

    // Calculate the maximum height for the task to prevent exceeding the calendar boundary
    calendarStateNotifier.updateMaxTaskHeight(max(
        (currentCalendarState.calendarWidgetBottomBoundaryY - localDy),
        currentCalendarState.snapIntervalHeight));

    // Adjust height for bottom resizing
    final newSize = (localCurrentTimeSlotHeight + details.delta.dy).clamp(
        currentCalendarState.snapIntervalHeight,
        currentCalendarState.maxTaskHeight);
    if (newSize >= currentCalendarState.snapIntervalHeight) {
      localCurrentTimeSlotHeightNotifier.state = newSize;
    }

    // Calculate the bottom position of the draggable box
    final draggableBoxBottomBoundary = localDy + localCurrentTimeSlotHeight;

    // Calculate the visible bottom boundary of the viewport
    final viewportBottom = scrollOffset + remainingScrollableContentInView;

    // Scroll if the bottom of the box goes beyond the viewport
    if (draggableBoxBottomBoundary > viewportBottom) {
      _startDownwardsAutoScroll();
      isScrolledNotifier.state = true;
    } else {
      _stopAutoScroll();
    }
  }

  void _handleBottomDragEnd() {
    final currentCalendarState = ref.read(calendarStateNotifierProvider);
    final calendarStateNotifier =
        ref.read(calendarStateNotifierProvider.notifier);
    final localCurrentTimeSlotHeightNotifier = ref.read(localCurrentTimeSlotHeightProvider.notifier);
    final isScrolled = ref.watch(isScrolledProvider);
    final localCurrentTimeSlotHeight = ref.watch(localCurrentTimeSlotHeightProvider);

    _stopAutoScroll();

    // scroll extra if timeslot drag caused scrolling.
    if (isScrolled) {
      scrollDown(scrollAmount: currentCalendarState.defaultTimeSlotHeight);
    }

    // Snap height to the nearest interval after dragging
    final newSize =
        (localCurrentTimeSlotHeight / currentCalendarState.snapIntervalHeight)
                .round() *
            currentCalendarState.snapIntervalHeight;

    localCurrentTimeSlotHeightNotifier.state = newSize;

    calendarStateNotifier.updateCurrentTimeSlotHeight(newSize);
  }

  void scrollDown({required double scrollAmount}) {
    final isScrolledNotifier = ref.read(isScrolledProvider.notifier);

    // reset isScrolled state
    isScrolledNotifier.state = false;

    // perform extra scrolling
    final scrollOffset = widget.scrollController.offset;
    final maxScrollExtent = widget.scrollController.position.maxScrollExtent;
    if (scrollOffset < maxScrollExtent) {
      widget.scrollController.animateTo(
        (scrollOffset + scrollAmount).clamp(0.0, maxScrollExtent),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _startDownwardsAutoScroll() {
    const double scrollAmount = 15;

    final currentCalendarState = ref.read(calendarStateNotifierProvider);
    final calendarStateNotifier =
        ref.read(calendarStateNotifierProvider.notifier);
    final localCurrentTimeSlotHeight = ref.watch(localCurrentTimeSlotHeightProvider);
    final localCurrentTimeSlotHeightNotifier = ref.read(localCurrentTimeSlotHeightProvider.notifier);

    _stopAutoScroll(); // Stop any ongoing scroll
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final currentOffset = widget.scrollController.offset;
      final maxScrollExtent = widget.scrollController.position.maxScrollExtent;

      if (currentOffset < maxScrollExtent) {
        widget.scrollController.jumpTo(
          (currentOffset + scrollAmount)
              .clamp(0, maxScrollExtent), // Scroll down
        );
        final newSize = (localCurrentTimeSlotHeight + scrollAmount).clamp(
            currentCalendarState.snapIntervalHeight,
            currentCalendarState.maxTaskHeight);

        // update local state
        localCurrentTimeSlotHeightNotifier.state = newSize;

        calendarStateNotifier.updateCurrentTimeSlotHeight(newSize);
      } else {
        _stopAutoScroll(); // Stop scrolling if we reach the end
      }
    });
  }

  void _stopAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
  }

  @override
  void dispose() {
    // Clean up
    _stopAutoScroll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentCalendarState = ref.watch(calendarStateNotifierProvider);
    final localDy = ref.watch(localDyProvider);
    final localCurrentTimeSlotHeight = ref.watch(localCurrentTimeSlotHeightProvider);

    return Positioned(
      left: currentCalendarState.draggableBox.dx +
          currentCalendarState.slotWidth * 0.75 -
          widget.indicatorWidth * 0.5, // Center horizontally
      top: localDy +
          localCurrentTimeSlotHeight -
          widget.indicatorHeight / 2, // Below the bottom edge
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          _handleBottomDrag(details: details);
        },
        onVerticalDragEnd: (_) {
          _handleBottomDragEnd();
        },
        child: Container(
          width: widget.indicatorWidth,
          height: widget.indicatorHeight,
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
        ),
      ),
    );
  }
}
