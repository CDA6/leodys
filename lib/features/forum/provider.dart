import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/controllers/forum_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'domain/entities/message.dart';
import 'domain/repositories/message_repository.dart';
import 'domain/usecases/get_messages.dart';
import 'domain/usecases/send_message.dart';
import 'data/repositories/message_repository_impl.dart';

/// --------------------
/// REPOSITORY PROVIDER
/// --------------------
final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  final client = Supabase.instance.client;
  return MessageRepositoryImpl(client: client);
});

/// --------------------
/// USE CASE PROVIDERS
/// --------------------
final getMessagesUseCaseProvider = Provider<GetMessages>((ref) {
  final repo = ref.read(messageRepositoryProvider);
  return GetMessages(repo);
});

final sendMessageUseCaseProvider = Provider<SendMessage>((ref) {
  final repo = ref.read(messageRepositoryProvider);
  return SendMessage(repo);
});

/// --------------------
/// STATE NOTIFIER FOR MESSAGES
/// --------------------
final messagesProvider = StateNotifierProvider<MessagesNotifier, List<Message>>(
      (ref) {
    final repo = ref.watch(messageRepositoryProvider);
    return MessagesNotifier(repo: repo)..loadMessages();
  },
);

class MessagesNotifier extends StateNotifier<List<Message>> {
  final MessageRepository repo;

  MessagesNotifier({required this.repo}) : super([]);

  /// Load all messages from the repository
  Future<void> loadMessages() async {
    final msgs = await repo.getMessages();
    state = msgs;
  }

  /// Add a new message to the repository and update state
  Future<void> addMessage(Message message) async {
    await repo.sendMessage(message);
    state = [...state, message];
  }
}

/// --------------------
/// FORUM CONTROLLER
/// --------------------
final forumControllerProvider = Provider<ForumController>(
      (ref) => ForumController(ref: ref),
);

/// --------------------
/// PROFILE CHECK
/// --------------------
final userHasProfileProvider = FutureProvider<bool>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return false;

  final data = await Supabase.instance.client
      .from('user_profiles')
      .select('id')
      .eq('id', user.id)
      .maybeSingle();

  return data != null;
});
