class DraggableBoxState {
  final double dx;
  double dy;

  DraggableBoxState({
    required this.dx,
    required this.dy,
  });

  DraggableBoxState copyWith({
    double? dx,
    double? dy,
  }) {
    return DraggableBoxState(
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
    );
  }
}
