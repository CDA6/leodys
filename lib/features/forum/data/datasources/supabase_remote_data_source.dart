import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/topic_model.dart';
import '../models/message_model.dart';

abstract class ForumRemoteDataSource {
  Future<List<TopicModel>> fetchTopics();
  Future<void> postTopic(TopicModel topic);
  Future<List<MessageModel>> fetchMessages(String topicId);
  Future<void> postMessage(MessageModel message);
}

class SupabaseForumRemoteDataSource implements ForumRemoteDataSource {
  final SupabaseClient client;

  SupabaseForumRemoteDataSource(this.client);

  @override
  Future<List<TopicModel>> fetchTopics() async {
    final res = await client
        .from('forum_topics')
        .select()
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(res)
        .map((e) => TopicModel.fromJson(e))
        .toList();
  }

  @override
  Future<void> postTopic(TopicModel topic) async {
    await client.from('forum_topics').insert(topic.toJson());
  }

  @override
  Future<List<MessageModel>> fetchMessages(String topicId) async {
    final res = await client
        .from('forum_messages')
        .select('*, user_profiles(first_name, last_name)')
        .eq('topic_id', topicId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(res)
        .map((e) => MessageModel.fromJson(e))
        .toList();
  }

  @override
  Future<void> postMessage(MessageModel message) async {
    await client.from('forum_messages').insert({
      'topic_id': message.topicId,
      'user_id': message.userId,
      'content': message.content,
      'created_at': message.createdAt.toIso8601String(),
    });
  }
}
