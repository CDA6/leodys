enum Side { left, right, unknown }

class BodyPart {
  final String label;
  final double x;
  final Side side;
  final double confidence;

  BodyPart({
    required this.label,
    required this.x,
    required this.side,
    required this.confidence
  });

  BodyPart copyWith({Side? side}) => BodyPart(
    label: label,
    x: x,
    side: side ?? this.side,
    confidence: confidence,
  );
}