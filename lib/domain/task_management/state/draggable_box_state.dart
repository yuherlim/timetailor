class DraggableBoxState {
  final double dx;
  final double dy;
  final double currentTimeSlotHeight;

  DraggableBoxState({
    required this.dx,
    required this.dy,
    required this.currentTimeSlotHeight,
  });

  DraggableBoxState copyWith({
    double? dx,
    double? dy,
    double? currentTimeSlotHeight,
  }) {
    return DraggableBoxState(
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
      currentTimeSlotHeight:
          currentTimeSlotHeight ?? this.currentTimeSlotHeight,
    );
  }
}
