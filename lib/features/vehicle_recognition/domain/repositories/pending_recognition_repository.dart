import '../models/pending_recognition.dart';

abstract class PendingRecognitionRepository {
  Future<void> add(PendingRecognition pending);
  Future<List<PendingRecognition>> getAll();
  Future<void> remove(String id);
  Future<void> clear();
}
