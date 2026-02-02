import '../../domain/entities/referent_entity.dart';

class ReferentModel extends ReferentEntity {
  const ReferentModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.category,
    required super.userId

  });

  factory ReferentModel.fromEntity(ReferentEntity entity) {
    return ReferentModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      role: entity.role,
      category: entity.category,
      userId: entity.userId
    );
  }

  factory ReferentModel.fromJson(Map<String, dynamic> json) {
    return ReferentModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Sans nom',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      category: json['category'] as String? ?? '',
      userId: json['user_id'] as String? ?? ''
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'category': category,
      'user_id': userId,
    };
  }
}