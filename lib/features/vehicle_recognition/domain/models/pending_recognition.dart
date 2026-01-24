/// Classe qui représente une reconnaissance de véhicule en attente
/// Il est stocké localement quand le systeme est hors ligne

class PendingRecognition {
  final String id;
  final String imagePath;
  final DateTime createdAt;

  PendingRecognition({
    required this.id,
    required this.imagePath,
    required this.createdAt,
  });
}
