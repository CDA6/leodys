import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/datasources/supabase_remote_data_source.dart';
import 'data/repositories/forum_repository_impl.dart';
import 'domain/entities/topic.dart';
import 'domain/usecases/get_topics.dart';
import 'domain/usecases/create_topic.dart';
import 'domain/usecases/get_messages.dart';
import 'domain/usecases/send_message.dart';
import 'presentation/controllers/forum_controller.dart';
import 'domain/entities/message.dart';
import 'presentation/providers/messages_state_notifier.dart';
import 'presentation/providers/messages_notifier.dart' as notifier;

/// --------------------
/// SUPABASE CLIENT
/// --------------------
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// --------------------
/// REMOTE DATA SOURCE
/// --------------------
final forumRemoteDataSourceProvider = Provider<SupabaseForumRemoteDataSource>((ref) {
  final client = ref.read(supabaseClientProvider);
  return SupabaseForumRemoteDataSource(client);
});

/// --------------------
/// REPOSITORY
/// --------------------
final forumRepositoryProvider = Provider<ForumRepositoryImpl>((ref) {
  final remote = ref.read(forumRemoteDataSourceProvider);
  return ForumRepositoryImpl(remoteDataSource: remote);
});

/// --------------------
/// USE CASES
/// --------------------
final getTopicsUseCaseProvider = Provider<GetTopics>((ref) {
  final repo = ref.read(forumRepositoryProvider);
  return GetTopics(repo);
});

final createTopicUseCaseProvider = Provider<CreateTopic>((ref) {
  final repo = ref.read(forumRepositoryProvider);
  return CreateTopic(repo);
});

final getMessagesUseCaseProvider = Provider<GetMessages>((ref) {
  final repo = ref.read(forumRepositoryProvider);
  return GetMessages(repo);
});

final sendMessageUseCaseProvider = Provider<SendMessage>((ref) {
  final repo = ref.read(forumRepositoryProvider);
  return SendMessage(repo);
});

/// --------------------
/// FORUM CONTROLLER
/// --------------------
final forumControllerProvider = Provider<ForumController>((ref) {
  return ForumController(ref: ref);
});

/// --------------------
/// MESSAGES STATE NOTIFIER
/// --------------------
final messagesProvider = StateNotifierProvider<MessagesNotifier, List<Message>>((ref) {
  final repo = ref.read(forumRepositoryProvider);
  return MessagesNotifier(repo: repo)..loadMessages();
});

final topicMessagesProvider = StateNotifierProviderFamily<notifier.MessagesNotifier, List<Message>, String>(
      (ref, topicId) {
    final controller = ref.read(forumControllerProvider);
    return notifier.MessagesNotifier(controller: controller, topicId: topicId)..loadMessages();
  },
);

/// --------------------
/// TOPIC
/// --------------------
final topicsProvider = FutureProvider<List<Topic>>((ref) async {
  final controller = ref.read(forumControllerProvider);
  return controller.loadTopics();
});