import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import '../entities/chat_message.dart';

/// Interface abstraite pour le repository de chat vocal.
///
/// Définit le contrat pour l'envoi de messages au LLM.
abstract class VocalChatRepository {
  /// Envoie un message utilisateur au LLM et retourne la réponse.
  ///
  /// [conversationHistory] L'historique de la conversation (messages précédents).
  /// [userMessage] Le nouveau message de l'utilisateur.
  ///
  /// Retourne :
  /// - [Right] avec la réponse de l'assistant en cas de succès
  /// - [Left] avec un [Failure] en cas d'erreur
  Future<Either<Failure, String>> sendMessage(
    List<ChatMessage> conversationHistory,
    String userMessage,
  );
}
