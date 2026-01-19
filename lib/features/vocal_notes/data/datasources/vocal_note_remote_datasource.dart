import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:leodys/features/vocal_notes/data/models/vocal_note_model.dart';

abstract class VocalNoteRemoteDataSource {
  Future<List<VocalNoteModel>> fetchAllNotes();
  Future<VocalNoteModel?> fetchNoteById(String id);
  Future<void> upsertNote(VocalNoteModel note);
  Future<void> deleteNote(String id); // Soft delete handled by update
  Future<List<VocalNoteModel>> fetchNotesUpdatedAfter(DateTime date);
}

class VocalNoteRemoteDataSourceImpl implements VocalNoteRemoteDataSource {
  final SupabaseClient _client;

  VocalNoteRemoteDataSourceImpl(this._client);

  @override
  Future<List<VocalNoteModel>> fetchAllNotes() async {
    final response = await _client
        .from('vocal_notes')
        .select()
        .filter('deleted_at', 'is', null)
        .order('updated_at', ascending: false);

    return (response as List).map((e) => VocalNoteModel.fromJson(e)).toList();
  }

  @override
  Future<VocalNoteModel?> fetchNoteById(String id) async {
    final response = await _client
        .from('vocal_notes')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return VocalNoteModel.fromJson(response);
  }

  @override
  Future<void> upsertNote(VocalNoteModel note) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final data = note.toJson();
    data['user_id'] = user.id;

    await _client.from('vocal_notes').upsert(data);
  }

  @override
  Future<void> deleteNote(String id) async {
    // Soft delete via update
    await _client
        .from('vocal_notes')
        .update({
          'deleted_at': DateTime.now().toUtc().toIso8601String(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', id);
  }

  @override
  Future<List<VocalNoteModel>> fetchNotesUpdatedAfter(DateTime date) async {
    final response = await _client
        .from('vocal_notes')
        .select()
        .gt('updated_at', date.toIso8601String());

    return (response as List).map((e) => VocalNoteModel.fromJson(e)).toList();
  }
}
