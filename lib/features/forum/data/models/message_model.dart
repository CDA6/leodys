import '../../domain/entities/message.dart';

class MessageModel extends Message {
  MessageModel({
    required String id,
    required String topicId,
    required String userId,
    required String username,
    required String content,
    required DateTime createdAt,
  }) : super(
    id: id,
    topicId: topicId,
    userId: userId,
    username: username,
    content: content,
    createdAt: createdAt,
  );

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'].toString(),
      topicId: json['topic_id'],
      userId: json['user_id'],
      username: json['username'] ?? json['user_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => super.toMap();
}
