import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/common/mixins/repository_mixin.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/errors/failures.dart';
import '../../domain/repositories/vocal_chat_repository.dart';
import '../services/openrouter_service.dart';

/// Implémentation du repository de chat vocal.
///
/// Utilise [OpenRouterService] pour communiquer avec l'API.
class VocalChatRepositoryImpl with RepositoryMixin implements VocalChatRepository {
  final OpenRouterService _openRouterService;

  VocalChatRepositoryImpl(this._openRouterService);

  @override
  Future<Either<Failure, String>> sendMessage(
    List<ChatMessage> conversationHistory,
    String userMessage,
  ) {
    return execute('sendMessage', () async {
      try {
        // Construire la liste de messages pour l'API
        final messages = conversationHistory
            .map((msg) => msg.toApiFormat())
            .toList();

        // Ajouter le nouveau message utilisateur
        messages.add({
          'role': 'user',
          'content': userMessage,
        });

        // Appeler le service OpenRouter
        final response = await _openRouterService.sendChatCompletion(messages);
        return Right(response);
      } on OpenRouterFailure catch (e) {
        return Left(e);
      } catch (e) {
        return Left(UnknownFailure('Erreur inattendue: $e'));
      }
    });
  }
}
