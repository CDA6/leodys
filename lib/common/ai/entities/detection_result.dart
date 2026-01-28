import 'dart:ui'; // Nécessaire pour l'objet Rect

/// Entité représentant une détection unique.
/// Elle est agnostique du modèle (marche pour YOLO, SSD, MobileNet...)
class DetectionResult {
  /// Le nom de l'objet détecté (ex: "10 de Coeur" ou "Personne")
  final String label;

  /// Le score de confiance (entre 0.0 et 1.0)
  final double confidence;

  /// Le rectangle de délimitation (Bounding Box)
  /// Note : Les coordonnées sont relatives à la taille de l'image d'entrée (640x640)
  final Rect boundingBox;

  DetectionResult({
    required this.label,
    required this.confidence,
    required this.boundingBox,
  });

  @override
  String toString() {
    return 'DetectionResult(label: $label, confidence: ${confidence.toStringAsFixed(2)}, box: $boundingBox)';
  }
}