import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:leodys/features/forum/data/models/message_model.dart';
import 'remote_data_source.dart';

class SupabaseRemoteDataSource implements RemoteDataSource {
  final SupabaseClient client;

  SupabaseRemoteDataSource(this.client);

  @override
  Future<List<MessageModel>> fetchMessages() async {
    final response = await client
        .from('forum_messages')
        .select()
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response)
        .map((json) => MessageModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> postMessage(MessageModel message) async {
    await client.from('forum_messages').insert(message.toJson());
  }
}

