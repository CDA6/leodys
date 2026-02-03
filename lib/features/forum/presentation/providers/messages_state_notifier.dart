import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/forum_repository.dart';

class MessagesNotifier extends StateNotifier<List<Message>> {
  final ForumRepository repo;

  MessagesNotifier({required this.repo}) : super([]);

  Future<void> loadMessages([String? topicId]) async {
    if (topicId == null) return;
    final msgs = await repo.getMessages(topicId);
    state = msgs;
  }

  Future<void> addMessage(Message message) async {
    await repo.sendMessage(message);
    state = [...state, message];
  }
}
