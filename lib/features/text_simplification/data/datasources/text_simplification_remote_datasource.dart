import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:leodys/features/text_simplification/data/models/text_simplification_model.dart';

abstract class TextSimplificationRemoteDataSource {
  Future<List<TextSimplificationModel>> fetchAll();
  Future<TextSimplificationModel?> fetchById(String id);
  Future<void> upsert(TextSimplificationModel item);
  Future<void> delete(String id); // Soft delete handled by update
  Future<List<TextSimplificationModel>> fetchUpdatedAfter(DateTime date);
}

class TextSimplificationRemoteDataSourceImpl
    implements TextSimplificationRemoteDataSource {
  final SupabaseClient _client;

  TextSimplificationRemoteDataSourceImpl(this._client);

  @override
  Future<List<TextSimplificationModel>> fetchAll() async {
    final response = await _client
        .from('text_simplifications')
        .select()
        .filter('deleted_at', 'is', null)
        .order('updated_at', ascending: false);

    return (response as List)
        .map((e) => TextSimplificationModel.fromJson(e))
        .toList();
  }

  @override
  Future<TextSimplificationModel?> fetchById(String id) async {
    final response = await _client
        .from('text_simplifications')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return TextSimplificationModel.fromJson(response);
  }

  @override
  Future<void> upsert(TextSimplificationModel item) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final data = item.toJson();
    data['user_id'] = user.id;

    await _client.from('text_simplifications').upsert(data);
  }

  @override
  Future<void> delete(String id) async {
    // Soft delete via update
    await _client
        .from('text_simplifications')
        .update({
          'deleted_at': DateTime.now().toUtc().toIso8601String(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', id);
  }

  @override
  Future<List<TextSimplificationModel>> fetchUpdatedAfter(DateTime date) async {
    final response = await _client
        .from('text_simplifications')
        .select()
        .gt('updated_at', date.toIso8601String());

    return (response as List)
        .map((e) => TextSimplificationModel.fromJson(e))
        .toList();
  }
}
