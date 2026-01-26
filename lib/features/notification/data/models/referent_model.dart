import '../../domain/entities/referent_entity.dart';

class ReferentModel extends ReferentEntity {
  const ReferentModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.category,
  });

  factory ReferentModel.fromEntity(ReferentEntity entity) {
    return ReferentModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      role: entity.role,
      category: entity.category,
    );
  }
}