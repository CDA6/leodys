import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/topic.dart';
import '../../domain/entities/message.dart';
import '../../provider.dart';

class ForumController {
  final Ref ref;

  ForumController({required this.ref});

  Future<List<Topic>> loadTopics() async {
    final getTopics = ref.read(getTopicsUseCaseProvider);
    return await getTopics.call();
  }

  Future<void> addTopic(String title, String userId) async {
    final createTopic = ref.read(createTopicUseCaseProvider);
    final topic = Topic(
      id: const Uuid().v4(),
      title: title,
      userId: userId,
      createdAt: DateTime.now(),
    );
    await createTopic.call(topic);
  }

  Future<List<Message>> loadMessages(String topicId) async {
    final getMessages = ref.read(getMessagesUseCaseProvider);
    return await getMessages.call(topicId);
  }

  Future<void> addMessage(String topicId, String content, String userId, String username) async {
    final sendMessage = ref.read(sendMessageUseCaseProvider);
    final message = Message(
      id: const Uuid().v4(),
      userId: userId,
      username: username,
      content: content,
      createdAt: DateTime.now(),
      topicId: topicId,
    );
    await sendMessage.call(message);
  }
}
