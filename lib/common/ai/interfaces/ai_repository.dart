import '../entities/detection_result.dart';

/// Interface (Contrat) que tous vos Services d'IA doivent implémenter.
/// Cela permet de changer de modèle sans casser l'interfaces utilisateur.
abstract class AIRepository {
  /// Charge le modèle en mémoire (TFLite Interpreter)
  Future<void> loadModel();

  /// Lance la prédiction sur une entrée donnée.
  /// [input] est 'dynamic' pour accepter soit un File (Photo), soit une CameraImage (Stream)
  Future<List<DetectionResult>> predict(dynamic input);

  /// Libère les ressources (ferme l'interpréteur)
  void dispose();
}