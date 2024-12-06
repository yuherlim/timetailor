import 'package:timetailor/domain/task_management/state/draggable_box_state.dart';

class CalendarState {
  final double currentTimeSlotHeight;
  final double defaultTimeSlotHeight;
  final double pixelsPerMinute;
  final double snapInterval;
  final int currentSlotIndex;
  final DraggableBoxState draggableBox;
  final bool showDraggableBox;
  final List<double> timeSlotBoundaries;
  final double maxTaskHeight;
  final double calendarWidgetBottomBoundaryY;
  final double calendarHeight;

  final double slotStartX;
  final double slotWidth;

  static const double calendarWidgetTopBoundaryY = 16;
  static const double calendarBottomPadding = 120;

  CalendarState({
    required this.defaultTimeSlotHeight,
    required this.showDraggableBox,
    required this.currentTimeSlotHeight,
    required this.draggableBox,
    required this.currentSlotIndex,
    required this.timeSlotBoundaries,
    required this.maxTaskHeight,
    required this.calendarWidgetBottomBoundaryY,
    required this.slotStartX,
    required this.slotWidth,
    required this.pixelsPerMinute,
    required this.snapInterval,
    required this.calendarHeight,
  });

  CalendarState copyWith({
    double? defaultTimeSlotHeight,
    bool? showDraggableBox,
    double? currentTimeSlotHeight,
    int? currentSlotIndex,
    DraggableBoxState? draggableBox,
    List<double>? timeSlotBoundaries,
    double? maxTaskHeight,
    double? calendarWidgetBottomBoundaryY,
    double? slotStartX,
    double? slotWidth,
    double? pixelsPerMinute,
    double? snapInterval,
    double? calendarHeight,
  }) {
    return CalendarState(
      defaultTimeSlotHeight:
          defaultTimeSlotHeight ?? this.defaultTimeSlotHeight,
      showDraggableBox: showDraggableBox ?? this.showDraggableBox,
      currentTimeSlotHeight:
          currentTimeSlotHeight ?? this.currentTimeSlotHeight,
      draggableBox: draggableBox ?? this.draggableBox,
      currentSlotIndex: currentSlotIndex ?? this.currentSlotIndex,
      timeSlotBoundaries: timeSlotBoundaries ?? this.timeSlotBoundaries,
      maxTaskHeight: maxTaskHeight ?? this.maxTaskHeight,
      calendarWidgetBottomBoundaryY:
          calendarWidgetBottomBoundaryY ?? this.calendarWidgetBottomBoundaryY,
      slotStartX: slotStartX ?? this.slotStartX,
      slotWidth: slotWidth ?? this.slotWidth,
      pixelsPerMinute: pixelsPerMinute ?? this.pixelsPerMinute,
      snapInterval: snapInterval ?? this.snapInterval,
      calendarHeight: calendarHeight ?? this.calendarHeight,
    );
  }
}
