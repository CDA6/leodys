import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:leodys/common/utils/app_logger.dart';
import '../../domain/errors/failures.dart';

/// Service pour communiquer avec l'API OpenRouter.
///
/// Ce service est stateless et ne nécessite pas d'initialisation.
/// Il utilise la clé API depuis les variables d'environnement.
class OpenRouterService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1';
  static const String _model = 'tngtech/deepseek-r1t2-chimera:free';
  static const Duration _timeout = Duration(seconds: 60);

  /// Récupère la clé API depuis les variables d'environnement.
  String get _apiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';

  /// Envoie une conversation au modèle et retourne la réponse.
  ///
  /// [messages] Liste de messages au format API (role, content).
  ///
  /// Retourne le contenu de la réponse de l'assistant.
  /// Lève [OpenRouterFailure] en cas d'erreur.
  Future<String> sendChatCompletion(List<Map<String, String>> messages) async {
    // Vérification de la clé API
    if (_apiKey.isEmpty) {
      throw const OpenRouterFailure(
        'OPENROUTER_API_KEY non trouvée dans .env',
        errorCode: 'MISSING_API_KEY',
      );
    }

    final url = '$_baseUrl/chat/completions';
    AppLogger().info('[OpenRouterService] Envoi de ${messages.length} messages à $url');
    AppLogger().info('[OpenRouterService] Model: $_model');
    AppLogger().info('[OpenRouterService] API Key présente: ${_apiKey.isNotEmpty}');

    try {
      final requestBody = json.encode({
        'model': _model,
        'messages': messages,
      });
      AppLogger().info('[OpenRouterService] Request body: $requestBody');

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
              'HTTP-Referer': 'https://leodys.app',
              'X-Title': 'Leodys',
            },
            body: requestBody,
          )
          .timeout(_timeout);

      AppLogger().info('[OpenRouterService] Status code: ${response.statusCode}');
      AppLogger().info('[OpenRouterService] Response headers: ${response.headers}');
      AppLogger().info('[OpenRouterService] Response body (first 500 chars): ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}');

      // Gestion des erreurs HTTP
      if (response.statusCode != 200) {
        AppLogger().error(
          '[OpenRouterService] HTTP ${response.statusCode}: ${response.body}',
        );
        throw OpenRouterFailure(
          'Erreur API: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      // Vérifier que la réponse est bien du JSON
      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        AppLogger().error('[OpenRouterService] Content-Type inattendu: $contentType');
        AppLogger().error('[OpenRouterService] Body: ${response.body}');
        throw OpenRouterFailure(
          'Réponse invalide: attendu JSON, reçu $contentType',
          errorCode: 'INVALID_CONTENT_TYPE',
        );
      }

      // Parsing de la réponse
      final data = json.decode(response.body);
      final content = data['choices']?[0]?['message']?['content'] as String?;

      if (content == null || content.isEmpty) {
        throw const OpenRouterFailure('Réponse vide du modèle');
      }

      AppLogger().info(
        '[OpenRouterService] Réponse reçue: ${content.length} caractères',
      );
      return content;
    } on OpenRouterFailure {
      rethrow;
    } on TimeoutException {
      AppLogger().error('[OpenRouterService] Timeout après $_timeout');
      throw const OpenRouterFailure(
        'Timeout: le serveur n\'a pas répondu à temps',
        errorCode: 'TIMEOUT',
      );
    } catch (e) {
      AppLogger().error('[OpenRouterService] Exception: $e');
      throw OpenRouterFailure('Erreur réseau: $e');
    }
  }
}
