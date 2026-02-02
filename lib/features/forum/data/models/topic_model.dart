import 'package:leodys/features/forum/domain/entities/topic.dart';

class TopicModel extends Topic {
  TopicModel({
    required String id,
    required String title,
    required String userId,
    required DateTime createdAt,
  }) : super(id: id, title: title, userId: userId, createdAt: createdAt);

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'].toString(),
      title: json['title'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'user_id': userId,
    'created_at': createdAt.toIso8601String()
  };
}

