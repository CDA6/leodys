import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:leodys/features/forum/domain/usecases/get_messages.dart';
import 'package:leodys/features/forum/domain/usecases/send_message.dart';
import '../../provider.dart';

final getMessagesUseCaseProvider = Provider<GetMessages>((ref) {
  final repo = ref.read(messageRepositoryProvider);
  return GetMessages(repo);
});

final sendMessageUseCaseProvider = Provider<SendMessage>((ref) {
  final repo = ref.read(messageRepositoryProvider);
  return SendMessage(repo);
});