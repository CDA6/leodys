import 'package:leodys/features/forum/domain/entities/message.dart';

class MessageModel extends Message {
  MessageModel({
    required String id,
    required String userId,
    required String username,
    required String content,
    required DateTime timestamp,
  }) : super(
    id: id,
    userId: userId,
    username: username,
    content: content,
    createdAt: timestamp,
  );

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'].toString(),
      userId: json['user_id'],
      username: json['username'] ?? json['user_id'],
      content: json['content'],
      timestamp: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'username': username,
    'content': content,
  };
}

