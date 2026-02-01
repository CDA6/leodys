import 'package:hive/hive.dart';
import 'package:leodys/features/text_simplification/data/models/text_simplification_model.dart';

abstract class TextSimplificationLocalDataSource {
  Future<List<TextSimplificationModel>> getAll();
  Future<TextSimplificationModel?> getById(String id);
  Future<void> save(TextSimplificationModel item);
  Future<void> delete(String id); // Soft delete
  Future<void> permanentlyDelete(String id);
  Future<List<TextSimplificationModel>> getUpdatedAfter(DateTime date);
}

class TextSimplificationLocalDataSourceImpl
    implements TextSimplificationLocalDataSource {
  final Box _box;

  TextSimplificationLocalDataSourceImpl(this._box);

  @override
  Future<List<TextSimplificationModel>> getAll() async {
    return _box.values
        .map((e) =>
            TextSimplificationModel.fromHive(Map<String, dynamic>.from(e)))
        .where(
          (item) => item.deletedAt == null,
        ) // On ne retourne que les actifs
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<TextSimplificationModel?> getById(String id) async {
    final data = _box.get(id);
    if (data == null) return null;
    return TextSimplificationModel.fromHive(Map<String, dynamic>.from(data));
  }

  @override
  Future<void> save(TextSimplificationModel item) async {
    await _box.put(item.id, item.toHive());
  }

  @override
  Future<void> delete(String id) async {
    final item = await getById(id);
    if (item != null) {
      final deletedItem = item.copyWith(deletedAt: DateTime.now().toUtc());
      await save(deletedItem);
    }
  }

  @override
  Future<void> permanentlyDelete(String id) async {
    await _box.delete(id);
  }

  @override
  Future<List<TextSimplificationModel>> getUpdatedAfter(DateTime date) async {
    return _box.values
        .map((e) =>
            TextSimplificationModel.fromHive(Map<String, dynamic>.from(e)))
        .where((item) => item.updatedAt.isAfter(date))
        .toList();
  }
}
