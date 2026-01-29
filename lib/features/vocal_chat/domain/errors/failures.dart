import 'package:leodys/common/errors/failures.dart';

/// Erreur liée aux appels API OpenRouter.
///
/// Levée lorsque :
/// - La clé API est manquante ou invalide
/// - Une erreur réseau survient
/// - Le modèle retourne une erreur (rate limit, quota, etc.)
/// - La réponse ne peut pas être parsée
class OpenRouterFailure extends Failure {
  final int? statusCode;
  final String? errorCode;

  const OpenRouterFailure(
    super.message, {
    this.statusCode,
    this.errorCode,
  });

  @override
  String toString() => 'OpenRouterFailure: $message (code: $statusCode, errorCode: $errorCode)';
}
