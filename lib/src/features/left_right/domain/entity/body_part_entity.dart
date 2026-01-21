enum BodySide { left, right, center }

class BodyPoint {
  final double x;
  final double y;
  final String label;
  final BodySide side;
  final double confidence;

  BodyPoint({
    required this.x,
    required this.y,
    required this.label,
    required this.side,
    this.confidence = 0.0,
  });
}