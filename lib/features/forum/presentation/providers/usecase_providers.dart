import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:leodys/features/forum/data/repositories/message_repository_impl.dart';
import 'package:leodys/features/forum/domain/usecases/get_messages.dart';
import 'package:leodys/features/forum/domain/usecases/send_message.dart';
import 'package:leodys/features/forum/domain/repositories/message_repository.dart';

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  final client = Supabase.instance.client;
  return MessageRepositoryImpl(client: client);
});

// Use case providers
final getMessagesUseCaseProvider = Provider<GetMessages>((ref) {
  final repo = ref.read(messageRepositoryProvider);
  return GetMessages(repo);
});

final sendMessageUseCaseProvider = Provider<SendMessage>((ref) {
  final repo = ref.read(messageRepositoryProvider);
  return SendMessage(repo);
});