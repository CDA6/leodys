/// Entité représentant une simplification de texte pour dyslexiques.
class TextSimplificationEntity {
  final String id;
  final String originalText;
  final String simplifiedText;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const TextSimplificationEntity({
    required this.id,
    required this.originalText,
    required this.simplifiedText,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;
}
