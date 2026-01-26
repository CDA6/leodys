import 'package:hive/hive.dart';
import 'package:leodys/features/vocal_notes/data/models/vocal_note_model.dart';

abstract class VocalNoteLocalDataSource {
  Future<List<VocalNoteModel>> getAllNotes();
  Future<VocalNoteModel?> getNoteById(String id);
  Future<void> saveNote(VocalNoteModel note);
  Future<void> deleteNote(String id); // Soft delete
  Future<void> permanentlyDeleteNote(String id);
  Future<List<VocalNoteModel>> getNotesUpdatedAfter(DateTime date);
}

class VocalNoteLocalDataSourceImpl implements VocalNoteLocalDataSource {
  final Box _box;

  VocalNoteLocalDataSourceImpl(this._box);

  @override
  Future<List<VocalNoteModel>> getAllNotes() async {
    return _box.values
        .map((e) => VocalNoteModel.fromHive(Map<String, dynamic>.from(e)))
        .where(
          (note) => note.deletedAt == null,
        ) // On ne retourne que les actifs
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<VocalNoteModel?> getNoteById(String id) async {
    final data = _box.get(id);
    if (data == null) return null;
    return VocalNoteModel.fromHive(Map<String, dynamic>.from(data));
  }

  @override
  Future<void> saveNote(VocalNoteModel note) async {
    await _box.put(note.id, note.toHive());
  }

  @override
  Future<void> deleteNote(String id) async {
    final note = await getNoteById(id);
    if (note != null) {
      final deletedNote = note.copyWith(deletedAt: DateTime.now().toUtc());
      await saveNote(deletedNote);
    }
  }

  @override
  Future<void> permanentlyDeleteNote(String id) async {
    await _box.delete(id);
  }

  @override
  Future<List<VocalNoteModel>> getNotesUpdatedAfter(DateTime date) async {
    return _box.values
        .map((e) => VocalNoteModel.fromHive(Map<String, dynamic>.from(e)))
        .where((note) => note.updatedAt.isAfter(date))
        .toList();
  }
}
