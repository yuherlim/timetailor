import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';
import 'package:timetailor/domain/task_management/state/calendar_state.dart';

class TopIndicator extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final double localDy;
  final double localCurrentTimeSlotHeight;
  final void Function({
    double? localDy,
    double? localCurrentTimeSlotHeight,
  }) onDyOrCurrentTimeSlotHeightUpdate;

  const TopIndicator({
    super.key,
    required this.scrollController,
    required this.localDy,
    required this.localCurrentTimeSlotHeight,
    required this.onDyOrCurrentTimeSlotHeightUpdate,
  });

  @override
  ConsumerState<TopIndicator> createState() => _TopIndicatorState();
}

class _TopIndicatorState extends ConsumerState<TopIndicator> {
  late ScrollController _scrollController;
  bool isScrolled = false;
  Timer? _scrollTimer;

  @override
  void initState() {
    _scrollController = widget.scrollController;
    super.initState();
  }

  void scrollUp({required double scrollAmount}) {
    // reset isScrolled state
    setState(() {
      isScrolled = false;
    });

    // perform extra scrolling
    final scrollOffset = _scrollController.offset;
    if (scrollOffset > 0) {
      _scrollController.animateTo(
        (scrollOffset - scrollAmount).clamp(0.0, double.infinity),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _startUpwardsAutoScroll() {
    const double scrollAmount = 15;

    print("===========================");
    print("Debugging auto scroll up");
    print("===========================");

    final currentCalendarState = ref.read(calendarStateNotifierProvider);
    final calendarStateNotifier =
        ref.read(calendarStateNotifierProvider.notifier);

    _stopAutoScroll(); // Stop any ongoing scroll
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final currentOffset = _scrollController.offset;

      if (currentOffset > 0.0) {
        _scrollController.jumpTo(
          max(0.0, (currentOffset - scrollAmount)), // Scroll up
        );
        final newDy = max(CalendarState.calendarWidgetTopBoundaryY,
            (widget.localDy - scrollAmount));
        print("newDy: $newDy");
        print(
            "TimeSlotInfo.snapInterval: ${currentCalendarState.snapIntervalHeight}");
        print("maxTaskHeight: ${currentCalendarState.maxTaskHeight}");
        final newSize = (widget.localCurrentTimeSlotHeight + scrollAmount)
            .clamp(currentCalendarState.snapIntervalHeight,
                currentCalendarState.maxTaskHeight);
        print("ran clamp");

        print("dy: ${widget.localDy}");
        print("currentTimeSlotHeight: $newSize");

        // update local state
        widget.onDyOrCurrentTimeSlotHeightUpdate(
          localDy: newDy,
          localCurrentTimeSlotHeight: newSize,
        );

        calendarStateNotifier.updateDraggableBoxPosition(dy: newDy);
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("========================");
    print("top indicator build start");
    print("========================");
    print("localDy: ${widget.localDy}");
    print("localCurrentTimeSlotHeight: ${widget.localCurrentTimeSlotHeight}");

    final currentCalendarState = ref.watch(calendarStateNotifierProvider);
    final calendarStateNotifier =
        ref.read(calendarStateNotifierProvider.notifier);

    // indicator dimensions
    const double indicatorWidth = 80;
    const double indicatorHeight = 30;

    return // Top Indicator
        Positioned(
      left: currentCalendarState.draggableBox.dx +
          currentCalendarState.slotWidth * 0.25 -
          indicatorWidth * 0.5, // Center horizontally
      top: widget.localDy - indicatorHeight / 2, // Above the top edge
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          print("");
          print("onVerticalDragUpdate triggered for top indicator");
          final draggableBoxBottomBoundary =
              (widget.localDy + widget.localCurrentTimeSlotHeight);

          final minDraggableBoxSizeDy = draggableBoxBottomBoundary -
              currentCalendarState.snapIntervalHeight;

          print("");
          print("=========================================");
          print("debugging draggable box initial values:");
          print("=========================================");
          print("draggableBoxBottomBoundary: $draggableBoxBottomBoundary");
          print("currentTimeSlotHeight: ${widget.localCurrentTimeSlotHeight}");
          print(
              "TimeSlotInfo.snapInterval: ${currentCalendarState.snapIntervalHeight}");
          print("minDraggableBoxSizeDy: $minDraggableBoxSizeDy");
          print("");

          // Adjust height and position for top resizing
          final newDy = widget.localDy + details.delta.dy;
          final newSize = (widget.localCurrentTimeSlotHeight - details.delta.dy)
              .clamp(currentCalendarState.snapIntervalHeight, double.infinity);

          print("current position: ${widget.localDy}");
          print("moved by: ${details.delta.dy}");
          print("new position: $newDy");
          print("new size: $newSize");

          print("=========================================");

          if (newDy >= CalendarState.calendarWidgetTopBoundaryY &&
              newDy < minDraggableBoxSizeDy) {
            widget.onDyOrCurrentTimeSlotHeightUpdate(
              localDy: newDy,
              localCurrentTimeSlotHeight: newSize,
            );
            // calendarStateNotifier.updateDraggableBoxPosition(
            //     dy: newDy);
            // calendarStateNotifier
            //     .updateCurrentTimeSlotHeight(newSize);
          }
          print("========================");
          print("top indicator debugging state update");
          print("========================");
          print("localDy: ${widget.localDy}");
          print(
              "localCurrentTimeSlotHeight: ${widget.localCurrentTimeSlotHeight}");

          // print(
          //     "currentTimeSlotHeight: $currentTimeSlotHeight");

          final scrollOffset = _scrollController.offset;

          // print(
          //     "draggableBoxTopBoundary: ${draggableBox.dy}");
          // print("scrollOffset: $scrollOffset");

          calendarStateNotifier.updateMaxTaskHeight(widget.localDy -
              CalendarState.calendarWidgetTopBoundaryY +
              widget.localCurrentTimeSlotHeight);

          // print(
          //     "maxTaskHeight before auto scroll: $maxTaskHeight");

          if (widget.localDy < scrollOffset) {
            print("");
            print("start upwards scroll");
            print("");
            _startUpwardsAutoScroll();
            isScrolled = true;
          } else {
            _stopAutoScroll();
          }

          // print(
          //     "maxTaskHeight after auto scroll: $maxTaskHeight");
        },
        onVerticalDragEnd: (_) {
          _stopAutoScroll();

          // scroll extra if timeslot drag caused scrolling.
          if (isScrolled) {
            scrollUp(scrollAmount: currentCalendarState.defaultTimeSlotHeight);
          }

          // print("");
          // print(
          //     "before update Height: $currentTimeSlotHeight");
          // print("current dy: ${draggableBox.dy}");

          print("");
          print("=========================================");
          print("debugging draggable box onVerticalDragEnd for top indicator:");
          print("=========================================");

          // Adjust for padding before snapping
          final adjustedDy =
              widget.localDy - CalendarState.calendarWidgetTopBoundaryY;

          print("adjustedDy: $adjustedDy");
          print(
              "current dy before adjust: ${currentCalendarState.draggableBox.dy}");

          // Snap position to the nearest interval
          double newDy =
              (adjustedDy / currentCalendarState.snapIntervalHeight).round() *
                  currentCalendarState.snapIntervalHeight;

          // Reapply the padding offset
          newDy += CalendarState.calendarWidgetTopBoundaryY;

          // Snap the height directly (no adjustment needed for height)
          final newSize = (widget.localCurrentTimeSlotHeight /
                      currentCalendarState.snapIntervalHeight)
                  .round() *
              currentCalendarState.snapIntervalHeight;

          // Update local state
          widget.onDyOrCurrentTimeSlotHeightUpdate(
            localDy: newDy,
            localCurrentTimeSlotHeight: newSize,
          );

          // Update the new position and timeslot height
          calendarStateNotifier.updateDraggableBoxPosition(dy: newDy);
          calendarStateNotifier.updateCurrentTimeSlotHeight(newSize);

          print("=========================================");
        },
        child: Container(
          width: indicatorWidth,
          height: indicatorHeight,
          decoration: BoxDecoration(
            color: AppColors.primaryAccent,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Center(
            child: Icon(
              Icons.arrow_upward,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
