import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/message.dart';
import '../../data/repositories/message_repository_impl.dart';
import '../../domain/repositories/message_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final messageRepositoryProvider = Provider<MessageRepository>(
  (ref) => MessageRepositoryImpl(client: Supabase.instance.client),
);

final messagesProvider = StateNotifierProvider<MessagesNotifier, List<Message>>(
  (ref) {
    final repo = ref.watch(messageRepositoryProvider);
    return MessagesNotifier(repo: repo)..loadMessages();
  },
);

class MessagesNotifier extends StateNotifier<List<Message>> {
  final MessageRepository repo;

  MessagesNotifier({required this.repo}) : super([]);

  Future<void> loadMessages() async {
    final msgs = await repo.getMessages();
    state = msgs;
  }

  Future<void> addMessage(Message message) async {
    await repo.sendMessage(message);
    state = [...state, message];
  }
}
