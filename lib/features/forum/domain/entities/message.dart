class Message {
  final String id;
  final String topicId;
  final String? userId;
  final String username;
  final String content;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.topicId,
    required this.userId,
    required this.username,
    required this.content,
    required this.createdAt,
  });

  /// Factory to create a Message from a Map (from Supabase or JSON)
  factory Message.fromMap(Map<String, dynamic> map) {
    final userProfile = map['user_profiles'] as Map<String, dynamic>?;

    final username = userProfile != null
        ? '${userProfile['first_name'] ?? ''} ${userProfile['last_name'] ?? ''}'.trim()
        : 'Anonymous';

    return Message(
      id: map['id'].toString(),
      topicId: map['topic_id'].toString(),
      userId: map['user_id'] as String?,
      username: username,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }


  /// Convert Message to Map for Supabase insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topic_id': topicId,
      'user_id': userId,
      'username': username,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
