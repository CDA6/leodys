import 'package:hive/hive.dart';

part 'referent_entity.g.dart';

@HiveType(typeId: 33) // Un ID unique différent de 32
class ReferentEntity {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String role;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final String userId;

  const ReferentEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.category,
    required this.userId,
  });

}
