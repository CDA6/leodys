import '../models/pending_recognition.dart';

/// Contrat du repository des reconnaissance en attente
/// objectif est de permettre une approche offline frist
abstract class PendingRecognitionRepository {

  /// Ajouter une reconnaissance en attente
  Future<void> add(PendingRecognition pending);

  /// Lister les reconnaissances
  Future<List<PendingRecognition>> getAll();

  /// effacer une reconnaissance
  Future<void> remove(String id);

  /// Tout effacer
  Future<void> clear();
}
