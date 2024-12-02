class TimeSlotInfo {
  static double pixelsPerMinute = 0;
  static double snapInterval = 0;
  static double slotWidth = 0;

  double slotHeight;

  TimeSlotInfo({
    required this.slotHeight,
  });

  // A copyWith method to create a new instance with updated properties
  TimeSlotInfo copyWith({
    double? slotHeight,
    String? timeLabel,
  }) {
    return TimeSlotInfo(
      slotHeight: slotHeight ?? this.slotHeight,
    );
  }
}
