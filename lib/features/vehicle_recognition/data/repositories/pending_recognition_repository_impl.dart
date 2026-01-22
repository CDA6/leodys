import 'package:hive/hive.dart';
import '../../domain/models/pending_recognition.dart';
import '../../domain/repositories/pending_recognition_repository.dart';

class PendingRecognitionRepositoryImpl
    implements PendingRecognitionRepository {

  static const _boxName = 'pending_recognitions';

  Future<Box> _openBox() async {
    return await Hive.openBox(_boxName);
  }

  @override
  Future<void> add(PendingRecognition pending) async {
    final box = await _openBox();
    await box.put(pending.id, {
      'id': pending.id,
      'imagePath': pending.imagePath,
      'createdAt': pending.createdAt.toIso8601String(),
    });
  }

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

  @override
  Future<void> remove(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  @override
  Future<void> clear() async {
    final box = await _openBox();
    await box.clear();
  }
}
