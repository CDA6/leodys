class Topic {
  final String id;
  final String title;
  final String userId;
  final DateTime createdAt;

  Topic({
    required this.id,
    required this.title,
    required this.userId,
    required this.createdAt,
  });

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      id: map['id'].toString(),
      title: map['title'],
      userId: map['user_id'] as String,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
