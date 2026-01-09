enum Side { left, right, unknown}

class BodyPart {
  final String name;
  final Side side;
  final double confidence;

  BodyPart({required this.name, required this.side,required this.confidence}){}
}