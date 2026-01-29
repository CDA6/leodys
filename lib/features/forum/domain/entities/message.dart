class Message {
  final String id;
  final String? userId;
  final String username; // added
  final String content;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.createdAt,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    final userProfile = map['user_profiles'] as Map<String, dynamic>?;

    final username = userProfile != null
        ? '${userProfile['first_name'] ?? ''} ${userProfile['last_name'] ?? ''}'.trim()
        : 'Anonymous';

    return Message(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      username: username,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
