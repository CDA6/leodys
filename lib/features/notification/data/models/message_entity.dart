import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.referentId,
    required super.referentName,
    required super.subject,
    required super.body,
    required super.sentAt,
    required super.userId
  });

  /// Convertit une Entité du Domaine en Modèle de Données
  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      referentId: entity.referentId,
      referentName: entity.referentName,
      subject: entity.subject,
      body: entity.body,
      sentAt: entity.sentAt,
      userId: entity.userId
    );
  }

  /// Désérialisation depuis le JSON Supabase
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String? ?? '',
      referentId: json['referent_id'] as String? ?? '',
      referentName: json['referent_name'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      body: json['body'] as String? ?? '',
      sentAt: DateTime.parse(json['sent_at'] as String? ?? ''),
      userId: json['user_id'] as String? ?? ''
    );
  }

  /// Sérialisation pour l'insertion dans Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referent_id': referentId,
      'referent_name': referentName,
      'subject': subject,
      'body': body,
      'sent_at': sentAt.toIso8601String(),
      'user_id': userId

    };
  }
}