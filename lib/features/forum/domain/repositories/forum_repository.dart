import 'package:supabase_flutter/supabase_flutter.dart';

import '../entities/message.dart';
import '../entities/topic.dart';

abstract class ForumRepository {
  Future<List<Topic>> getTopics();
  Future<void> createTopic(Topic topic);

  Future<List<Message>> getMessages(String topicId);
  Future<void> sendMessage(Message message);
}

class ForumRepositoryImpl implements ForumRepository {
  final SupabaseClient client;
  ForumRepositoryImpl(this.client);

  @override
  Future<List<Topic>> getTopics() async {
    final res = await client.from('forum_topics').select().order('created_at', ascending: true);
    final data = res as List<dynamic>;
    return data.map((e) => Topic.fromMap(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> createTopic(Topic topic) async {
    await client.from('forum_topics').insert(topic.toMap());
  }

  @override
  Future<List<Message>> getMessages(String topicId) async {
    final res = await client.from('forum_messages').select().eq('topic_id', topicId).order('created_at', ascending: true);
    final data = res as List<dynamic>;
    return data.map((e) => Message.fromMap(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> sendMessage(Message message) async {
    await client.from('forum_messages').insert(message.toMap());
  }
}
