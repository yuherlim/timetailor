import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/core/theme/custom_theme.dart';
import 'package:timetailor/domain/task_management/providers/calendar_state_provider.dart';

class BottomIndicator extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final double localDy;
  final double localCurrentTimeSlotHeight;
  final void Function({
    double? localDy,
    double? localCurrentTimeSlotHeight,
  }) onDyOrCurrentTimeSlotHeightUpdate;

  const BottomIndicator({
    super.key,
    required this.scrollController,
    required this.localDy,
    required this.localCurrentTimeSlotHeight,
    required this.onDyOrCurrentTimeSlotHeightUpdate,
  });

  @override
  ConsumerState<BottomIndicator> createState() => _BottomIndicatorState();
}

class _BottomIndicatorState extends ConsumerState<BottomIndicator> {
  late ScrollController _scrollController;
  bool isScrolled = false;
  Timer? _scrollTimer;

  @override
  void initState() {
    _scrollController = widget.scrollController;
    super.initState();
  }

  void scrollDown({required double scrollAmount}) {
    // reset isScrolled state
    setState(() {
      isScrolled = false;
    });

    // perform extra scrolling
    final scrollOffset = _scrollController.offset;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    if (scrollOffset < maxScrollExtent) {
      _scrollController.animateTo(
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

    _stopAutoScroll(); // Stop any ongoing scroll
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final currentOffset = _scrollController.offset;
      final maxScrollExtent = _scrollController.position.maxScrollExtent;

      if (currentOffset < maxScrollExtent) {
        print("currentOffset: $currentOffset");
        print("maxScrollExtent: $maxScrollExtent");
        _scrollController.jumpTo(
          (currentOffset + scrollAmount)
              .clamp(0, maxScrollExtent), // Scroll down
        );
        final newSize = (widget.localCurrentTimeSlotHeight + scrollAmount)
            .clamp(currentCalendarState.snapIntervalHeight,
                currentCalendarState.maxTaskHeight);

        // update local state
        widget.onDyOrCurrentTimeSlotHeightUpdate(
          localCurrentTimeSlotHeight: newSize,
        );

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
    final currentCalendarState = ref.watch(calendarStateNotifierProvider);
    final calendarStateNotifier =
        ref.read(calendarStateNotifierProvider.notifier);

    // indicator dimensions
    const double indicatorWidth = 80;
    const double indicatorHeight = 30;

    return
        // Bottom Indicator
        Positioned(
      left: currentCalendarState.draggableBox.dx +
          currentCalendarState.slotWidth * 0.75 -
          indicatorWidth * 0.5, // Center horizontally
      top: widget.localDy +
          widget.localCurrentTimeSlotHeight -
          indicatorHeight / 2, // Below the bottom edge
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          // Get the scroll offset of the calendar
          final scrollOffset = _scrollController.offset;
          final remainingScrollableContentInView =
              _scrollController.position.viewportDimension;

          // Calculate the maximum height for the task to prevent exceeding the calendar boundary
          calendarStateNotifier.updateMaxTaskHeight(max(
              (currentCalendarState.calendarWidgetBottomBoundaryY -
                  widget.localDy),
              currentCalendarState.snapIntervalHeight));

          print(
              "calendarWidgetBottomBoundaryY: ${currentCalendarState.calendarWidgetBottomBoundaryY}");
          print("scrollOffset: $scrollOffset");
          print(
              "remainingScrollableContentInView: $remainingScrollableContentInView");
          print("maxTaskHeight: ${currentCalendarState.maxTaskHeight}");
          print(
              "currentTimeSlotHeight: ${currentCalendarState.currentTimeSlotHeight}");
          print("current position: ${currentCalendarState.draggableBox.dy}");
          print("moved by: ${details.delta.dy}");
          print(
              "TimeSlotInfo.snapInterval: ${currentCalendarState.snapIntervalHeight}");

          // Adjust height for bottom resizing
          final newSize = (widget.localCurrentTimeSlotHeight + details.delta.dy)
              .clamp(currentCalendarState.snapIntervalHeight,
                  currentCalendarState.maxTaskHeight);
          if (newSize >= currentCalendarState.snapIntervalHeight) {
            widget.onDyOrCurrentTimeSlotHeightUpdate(
              localCurrentTimeSlotHeight: newSize,
            );
          }

          // Calculate the bottom position of the draggable box
          final draggableBoxBottomBoundary =
              widget.localDy + widget.localCurrentTimeSlotHeight;

          // Calculate the visible bottom boundary of the viewport
          final viewportBottom =
              scrollOffset + remainingScrollableContentInView;

          // print("");
          // print("current position: ${draggableBox.dy}");
          // print("moved by: ${details.delta.dy}");
          // print("scrollOffset: $scrollOffset");
          // print("maxTaskHeight: $maxTaskHeight");
          // print("new size: $newSize");
          // print(
          //     "draggableBoxBottomBoundary: $draggableBoxBottomBoundary");
          // print("viewportBottom: $viewportBottom");

          // Scroll if the bottom of the box goes beyond the viewport
          if (draggableBoxBottomBoundary > viewportBottom) {
            _startDownwardsAutoScroll();
            isScrolled = true;
          } else {
            _stopAutoScroll();
          }
        },
        onVerticalDragEnd: (_) {
          _stopAutoScroll();

          // scroll extra if timeslot drag caused scrolling.
          if (isScrolled) {
            scrollDown(
                scrollAmount: currentCalendarState.defaultTimeSlotHeight);
          }

          // Snap height to the nearest interval after dragging
          final newSize = (widget.localCurrentTimeSlotHeight /
                      currentCalendarState.snapIntervalHeight)
                  .round() *
              currentCalendarState.snapIntervalHeight;

          // update local state
          widget.onDyOrCurrentTimeSlotHeightUpdate(
            localCurrentTimeSlotHeight: newSize,
          );

          calendarStateNotifier.updateCurrentTimeSlotHeight(newSize);
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
