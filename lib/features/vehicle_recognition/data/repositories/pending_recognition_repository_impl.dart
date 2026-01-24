import 'package:hive/hive.dart';
import '../../domain/models/pending_recognition.dart';
import '../../domain/repositories/pending_recognition_repository.dart';

/// Implémentation de la classe PendingRecognition
class PendingRecognitionRepositoryImpl
    implements PendingRecognitionRepository {

  static const _boxName = 'pending_recognitions';

  /// Ouvre une box Hive
  Future<Box> _openBox() async {
    return await Hive.openBox(_boxName);
  }

  /// Ajouter un reconnaissance dans la file d'attente
  @override
  Future<void> add(PendingRecognition pending) async {
    final box = await _openBox();
    await box.put(pending.id, {
      'id': pending.id,
      'imagePath': pending.imagePath,
      'createdAt': pending.createdAt.toIso8601String(),
    });
  }

  /// retourner les donées stocké dans Hive sous forme objet métier PendingRecognition
  @override
  Future<List<PendingRecognition>> getAll() async {
    final box = await _openBox();

    return box.values.map((e) {
      return PendingRecognition(
        id: e['id'],
        imagePath: e['imagePath'],
        createdAt: DateTime.parse(e['createdAt']),
      );
    }).toList();
  }

  /// Supprimer un reconnaissance en attente apres un traitement réussi
  @override
  Future<void> remove(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  /// Supprimer tout les reconnaissance en attente
  @override
  Future<void> clear() async {
    final box = await _openBox();
    await box.clear();
  }
}
