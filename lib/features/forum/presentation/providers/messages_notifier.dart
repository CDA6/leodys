import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/message.dart';
import '../controllers/forum_controller.dart';

class MessagesNotifier extends StateNotifier<List<Message>> {
  final ForumController controller;
  final String topicId;

  MessagesNotifier({required this.controller, required this.topicId}) : super([]);

  Future<void> loadMessages() async {
    final msgs = await controller.loadMessages(topicId);
    state = msgs;
  }

  Future<void> addMessage(String content, String userId, String username) async {
    await controller.addMessage(topicId, content, userId, username);
    await loadMessages();
  }
}