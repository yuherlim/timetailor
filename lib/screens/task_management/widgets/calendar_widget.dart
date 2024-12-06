import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarWidget extends ConsumerStatefulWidget {
  const CalendarWidget({super.key});

  @override
  ConsumerState<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends ConsumerState<CalendarWidget> {

  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Stack(
        children: [
          GestureDetector(
            onTapUp: (details) {
              // if draggable box already created, do nothing
              if (showDraggableBox) {
                setState(() {
                  showDraggableBox = false;
                });
                return;
              }

              final tapPosition = details.localPosition.dy;

              // Binary search to find the correct time slot
              int slotIndex = binarySearchSlotIndex(tapPosition);

              print("slotIndex before handling: $slotIndex");

              // Handle case where the tap is after the last slot
              if (slotIndex == -1 && tapPosition >= timeSlotBoundaries.last) {
                slotIndex = timeSlotBoundaries.length - 1;
              }

              print("timeSlotBoundaries: ${timeSlotBoundaries.toString()}");
              print("relative calendar tap position: $tapPosition");
              print("local tap position: ${details.localPosition.dy}");
              print("slotIndex: $slotIndex");
              print("timeSlotStartingY: ${timeSlotBoundaries[slotIndex]}");

              // Snap to the correct time slot
              if (slotIndex != -1) {
                setState(() {
                  draggableBox = DraggableBox(
                    dx: slotStartX,
                    dy: timeSlotBoundaries[slotIndex],
                  );
                  currentTimeSlotHeight = defaultTimeSlotHeight; // Reset height
                  currentSlotIndex = slotIndex; // current slot index
                  showDraggableBox = true;
                });
              }
            },
            child: CalendarWidgetBackground(
              context: this.context,
              slotHeight: defaultTimeSlotHeight,
              snapInterval: TimeSlotInfo.snapInterval,
              topPadding: calendarWidgetTopBoundaryY,
              bottomPadding: calendarBottomPadding,
            ),
          ),
          if (showDraggableBox)
            Positioned(
              left: draggableBox.dx,
              top: draggableBox.dy,
              child: Container(
                width: slotWidth, // Fixed width
                height: currentTimeSlotHeight, // Dynamically adjusted height.
                decoration: BoxDecoration(
                  color: Colors.transparent, // Transparent background
                  border: Border.all(
                    color: AppColors.primaryAccent, // Border color
                    width: 2.0, // Border thickness
                  ),
                ),
              ),
            ),
          // Top Indicator
          if (showDraggableBox)
            Positioned(
              left: draggableBox.dx +
                  slotWidth * 0.25 -
                  indicatorWidth * 0.5, // Center horizontally
              top: draggableBox.dy - indicatorHeight / 2, // Above the top edge
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  print("");
                  print("onVerticalDragUpdate triggered");
                  setState(() {
                    final draggableBoxBottomBoundary =
                        (draggableBox.dy + currentTimeSlotHeight);

                    final minDraggableBoxSizeDy =
                        draggableBoxBottomBoundary - TimeSlotInfo.snapInterval;

                    print("");
                    print("debugging draggable box initial values:");
                    print(
                        "draggableBoxBottomBoundary: $draggableBoxBottomBoundary");
                    print("currentTimeSlotHeight: $currentTimeSlotHeight");
                    print(
                        "TimeSlotInfo.snapInterval: ${TimeSlotInfo.snapInterval}");
                    print("minDraggableBoxSizeDy: $minDraggableBoxSizeDy");
                    print("");

                    // Adjust height and position for top resizing
                    final newDy = draggableBox.dy + details.delta.dy;
                    final newSize = (currentTimeSlotHeight - details.delta.dy)
                        .clamp(TimeSlotInfo.snapInterval, double.infinity);

                    print("current position: ${draggableBox.dy}");
                    print("moved by: ${details.delta.dy}");
                    print("new position: $newDy");
                    print("new size: $newSize");

                    if (newDy >= calendarWidgetTopBoundaryY &&
                        newDy < minDraggableBoxSizeDy) {
                      draggableBox.dy = newDy;
                      currentTimeSlotHeight = newSize;
                    }

                    // print(
                    //     "currentTimeSlotHeight: $currentTimeSlotHeight");

                    final scrollOffset = _scrollController.offset;

                    // print(
                    //     "draggableBoxTopBoundary: ${draggableBox.dy}");
                    // print("scrollOffset: $scrollOffset");

                    maxTaskHeight = draggableBox.dy -
                        calendarWidgetTopBoundaryY +
                        currentTimeSlotHeight;

                    // print(
                    //     "maxTaskHeight before auto scroll: $maxTaskHeight");

                    if (draggableBox.dy < scrollOffset) {
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
                  });
                },
                onVerticalDragEnd: (_) {
                  _stopAutoScroll();

                  // scroll extra if timeslot drag caused scrolling.
                  if (isScrolled) {
                    scrollUp(scrollAmount: defaultTimeSlotHeight);
                  }

                  setState(() {
                    // print("");
                    // print(
                    //     "before update Height: $currentTimeSlotHeight");
                    // print("current dy: ${draggableBox.dy}");

                    // Adjust for padding before snapping
                    final adjustedDy =
                        draggableBox.dy - calendarWidgetTopBoundaryY;

                    // Snap position to the nearest interval
                    draggableBox.dy =
                        (adjustedDy / TimeSlotInfo.snapInterval).round() *
                            TimeSlotInfo.snapInterval;

                    // Reapply the padding offset
                    draggableBox.dy += calendarWidgetTopBoundaryY;

                    // Snap the height directly (no adjustment needed for height)
                    currentTimeSlotHeight =
                        (currentTimeSlotHeight / TimeSlotInfo.snapInterval)
                                .round() *
                            TimeSlotInfo.snapInterval;

                    // print("");
                    // print(
                    //     "Adjusted dy (before snapping): ${draggableBox.dy - calendarWidgetTopBoundaryY}");
                    // print(
                    //     "Snapped dy (after snapping): ${draggableBox.dy}");
                    // print(
                    //     "Current Time Slot Height (unchanged): $currentTimeSlotHeight");

                    // // Step 1: Calculate the current bottom position
                    // final currentBottom =
                    //     draggableBox.dy + currentTimeSlotHeight;

                    // // Step 2: Snap `dy` to the nearest interval
                    // final snappedDy =
                    //     (draggableBox.dy / TimeSlotInfo.snapInterval)
                    //             .round() *
                    //         TimeSlotInfo.snapInterval;

                    // // Step 3: Recalculate the height based on the snapped `dy`
                    // currentTimeSlotHeight = currentBottom - snappedDy;

                    // // Step 4: Update `dy` with the snapped value
                    // draggableBox.dy = snappedDy;

                    // print("current Bottom: $currentBottom");
                    // print("Original dy: ${draggableBox.dy}");
                    // print(
                    //     "Adjusted dy (before snapping): $adjustedDy");
                    // print(
                    //     "Snapped dy (after snapping): ${draggableBox.dy}");
                    // print(
                    //     "Current Time Slot Height: $currentTimeSlotHeight");

                    // print("");

                    // print(
                    //     "calendarWidgetBottomBoundaryY: $calendarWidgetBottomBoundaryY");
                    // print(
                    //     "defaultTimeSlotHeight: $defaultTimeSlotHeight");
                    // print(
                    //     "snapInterval: ${TimeSlotInfo.snapInterval}");

                    // print(
                    //     "scrollOffset after drag end: ${_scrollController.offset}");
                  });
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
            ),
          // Bottom Indicator
          if (showDraggableBox)
            Positioned(
              left: draggableBox.dx +
                  slotWidth * 0.75 -
                  indicatorWidth * 0.5, // Center horizontally
              top: draggableBox.dy +
                  currentTimeSlotHeight -
                  indicatorHeight / 2, // Below the bottom edge
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  setState(() {
                    // Get the scroll offset of the calendar
                    final scrollOffset = _scrollController.offset;
                    final remainingScrollableContentInView =
                        _scrollController.position.viewportDimension;

                    // Calculate the maximum height for the task to prevent exceeding the calendar boundary
                    maxTaskHeight = max(
                        (calendarWidgetBottomBoundaryY - draggableBox.dy),
                        TimeSlotInfo.snapInterval);

                    print(
                        "calendarWidgetBottomBoundaryY: $calendarWidgetBottomBoundaryY");
                    print("scrollOffset: $scrollOffset");
                    print(
                        "remainingScrollableContentInView: $remainingScrollableContentInView");
                    print("maxTaskHeight: $maxTaskHeight");
                    print("currentTimeSlotHeight: $currentTimeSlotHeight");
                    print("current position: ${draggableBox.dy}");
                    print("moved by: ${details.delta.dy}");
                    print(
                        "TimeSlotInfo.snapInterval: ${TimeSlotInfo.snapInterval}");

                    // Adjust height for bottom resizing
                    final newSize = (currentTimeSlotHeight + details.delta.dy)
                        .clamp(TimeSlotInfo.snapInterval, maxTaskHeight);
                    if (newSize >= TimeSlotInfo.snapInterval) {
                      currentTimeSlotHeight = newSize;
                    }

                    // Calculate the bottom position of the draggable box
                    final draggableBoxBottomBoundary =
                        draggableBox.dy + currentTimeSlotHeight;

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
                  });
                },
                onVerticalDragEnd: (_) {
                  _stopAutoScroll();

                  // scroll extra if timeslot drag caused scrolling.
                  if (isScrolled) {
                    scrollDown(scrollAmount: defaultTimeSlotHeight);
                  }

                  setState(() {
                    // Snap height to the nearest interval after dragging
                    currentTimeSlotHeight =
                        (currentTimeSlotHeight / TimeSlotInfo.snapInterval)
                                .round() *
                            TimeSlotInfo.snapInterval;
                  });
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
            ),
          // Current Time Indicator
          // const Positioned(
          //   top: 100, // Dynamically calculate this position
          //   left: 0,
          //   right: 0,
          //   child: Row(
          //     children: [
          //       SizedBox(width: 10),
          //       Icon(Icons.access_time, color: Colors.red),
          //       SizedBox(width: 10),
          //       Expanded(
          //         child: Divider(
          //           color: Colors.red,
          //           thickness: 1.5,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
