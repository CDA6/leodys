import 'package:leodys/features/forum/data/models/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/topic_model.dart';

abstract class RemoteDataSource {
  Future<List<TopicModel>> fetchTopics();
  Future<List<MessageModel>> fetchMessages(String topicId);
  Future<void> postTopic(TopicModel topic);
  Future<void> postMessage(MessageModel message);
}

class SupabaseRemoteDataSource implements RemoteDataSource {
  final SupabaseClient client;
  SupabaseRemoteDataSource(this.client);

  @override
  Future<List<TopicModel>> fetchTopics() async {
    final response = await client
        .from('forum_topics')
        .select()
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(response)
        .map((json) => TopicModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> postTopic(TopicModel topic) async {
    await client.from('forum_topics').insert(topic.toJson());
  }

  @override
  Future<List<MessageModel>> fetchMessages(String topicId) async {
    // Join with user_profiles to get first_name & last_name
    final response = await client
        .from('forum_messages')
        .select('*, user_profiles(first_name, last_name)')
        .eq('topic_id', topicId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response)
        .map((json) => MessageModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> postMessage(MessageModel message) async {
    // Only insert user_id, topic_id, content, created_at
    await client.from('forum_messages').insert({
      'topic_id': message.topicId,
      'user_id': message.userId,
      'content': message.content,
      'created_at': message.createdAt.toIso8601String(),
    });
  }
}
