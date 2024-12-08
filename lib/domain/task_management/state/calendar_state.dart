import 'package:timetailor/domain/task_management/state/draggable_box_state.dart';

class CalendarState {
  final double currentTimeSlotHeight;
  final double defaultTimeSlotHeight;
  final double pixelsPerMinute;
  final double snapIntervalHeight;
  final DraggableBoxState draggableBox;
  final bool showDraggableBox;
  final List<double> timeSlotBoundaries;
  final double calendarWidgetBottomBoundaryY;
  final double calendarHeight;

  final double slotStartX;
  final double slotWidth;
  final double textPadding;
  final double sidePadding;

  static const double calendarWidgetTopBoundaryY = 16;
  static const double calendarBottomPadding = 120;

  CalendarState({
    required this.defaultTimeSlotHeight,
    required this.showDraggableBox,
    required this.currentTimeSlotHeight,
    required this.draggableBox,
    required this.timeSlotBoundaries,
    required this.calendarWidgetBottomBoundaryY,
    required this.slotStartX,
    required this.slotWidth,
    required this.pixelsPerMinute,
    required this.snapIntervalHeight,
    required this.calendarHeight,
    required this.textPadding,
    required this.sidePadding,
  });

  CalendarState copyWith({
    double? defaultTimeSlotHeight,
    bool? showDraggableBox,
    double? currentTimeSlotHeight,
    DraggableBoxState? draggableBox,
    List<double>? timeSlotBoundaries,
    double? calendarWidgetBottomBoundaryY,
    double? slotStartX,
    double? slotWidth,
    double? pixelsPerMinute,
    double? snapIntervalHeight,
    double? calendarHeight,
    double? textPadding,
    double? sidePadding,
  }) {
    return CalendarState(
      defaultTimeSlotHeight:
          defaultTimeSlotHeight ?? this.defaultTimeSlotHeight,
      showDraggableBox: showDraggableBox ?? this.showDraggableBox,
      currentTimeSlotHeight:
          currentTimeSlotHeight ?? this.currentTimeSlotHeight,
      draggableBox: draggableBox ?? this.draggableBox,
      timeSlotBoundaries: timeSlotBoundaries ?? this.timeSlotBoundaries,
      calendarWidgetBottomBoundaryY:
          calendarWidgetBottomBoundaryY ?? this.calendarWidgetBottomBoundaryY,
      slotStartX: slotStartX ?? this.slotStartX,
      slotWidth: slotWidth ?? this.slotWidth,
      pixelsPerMinute: pixelsPerMinute ?? this.pixelsPerMinute,
      snapIntervalHeight: snapIntervalHeight ?? this.snapIntervalHeight,
      calendarHeight: calendarHeight ?? this.calendarHeight,
      textPadding: textPadding ?? this.textPadding,
      sidePadding: sidePadding ?? this.sidePadding,
    );
  }
}
