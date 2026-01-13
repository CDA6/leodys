class MessageEntity {
  final String id;
  final String referentId;
  final String referentName;
  final String subject;
  final String body;
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