import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/common/mixins/usecase_mixin.dart';
import '../entities/chat_message.dart';
import '../repositories/vocal_chat_repository.dart';

/// Paramètres pour le use case d'envoi de message.
class SendChatMessageParams {
  final List<ChatMessage> conversationHistory;
  final String userMessage;

  const SendChatMessageParams({
    required this.conversationHistory,
    required this.userMessage,
  });

  @override
  String toString() =>
      'SendChatMessageParams(messageLength: ${userMessage.length}, historySize: ${conversationHistory.length})';
}

/// Use case pour envoyer un message au LLM.
///
/// Orchestre l'appel au repository et retourne la réponse de l'assistant.
class SendChatMessageUseCase with UseCaseMixin<String, SendChatMessageParams> {
  final VocalChatRepository repository;

  SendChatMessageUseCase(this.repository);

  Future<Either<Failure, String>> execute(SendChatMessageParams params) async {
    return await repository.sendMessage(
      params.conversationHistory,
      params.userMessage,
    );
  }
}
