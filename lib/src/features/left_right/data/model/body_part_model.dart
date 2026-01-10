import '../../domain/entity/body_part_entity.dart';

class BodyPartModel extends BodyPart {
  final double y;

  BodyPartModel({
    required String name,
    required double x,
    required Side side,
    required double confidence,
    required this.y,
  }) : super(
    label: name,
    x: x,
    side: side,
    confidence: confidence,
  );

  factory BodyPartModel.fromYolo(Map<String, dynamic> json) {
    return BodyPartModel(
      name: json['label'] ?? 'Inconnu',
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      side: Side.unknown,
    );
  }
}