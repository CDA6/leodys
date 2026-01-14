import 'package:hive/hive.dart';

part 'message_entity.g.dart';

@HiveType(typeId: 32) // <-- On fixe l'ID 32 ici pour corriger l'erreur
class MessageEntity {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String referentId;

  @HiveField(2)
  final String referentName;

  @HiveField(3)
  final String subject;

  @HiveField(4)
  final String body;

  @HiveField(5)
  final DateTime sentAt;

  const MessageEntity({
    required this.id,
    required this.referentId,
    required this.referentName,
    required this.subject,
    required this.body,
    required this.sentAt,
  });

}