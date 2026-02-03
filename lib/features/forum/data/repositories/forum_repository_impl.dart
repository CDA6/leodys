import '../../domain/entities/topic.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/forum_repository.dart';
import '../models/topic_model.dart';
import '../models/message_model.dart';
import '../datasources/supabase_remote_data_source.dart';

class ForumRepositoryImpl implements ForumRepository {
  final SupabaseForumRemoteDataSource remoteDataSource;

  ForumRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Topic>> getTopics() async {
    final topics = await remoteDataSource.fetchTopics();
    return topics.map((t) => Topic.fromMap(t.toMap())).toList();
  }

  @override
  Future<void> createTopic(Topic topic) async {
    final topicModel = TopicModel(
      id: topic.id,
      title: topic.title,
      userId: topic.userId,
      createdAt: topic.createdAt,
    );
    await remoteDataSource.postTopic(topicModel);
  }

  @override
  Future<List<Message>> getMessages(String topicId) async {
    final messages = await remoteDataSource.fetchMessages(topicId);
    return messages.map((m) => Message.fromMap(m.toMap())).toList();
  }

  @override
  Future<void> sendMessage(Message message) async {
    final messageModel = MessageModel(
      id: message.id,
      topicId: message.topicId,
      userId: message.userId!,
      username: message.username,
      content: message.content,
      createdAt: message.createdAt,
    );
    await remoteDataSource.postMessage(messageModel);
  }
}
