import 'package:leodys/features/forum/domain/entities/message.dart';
import 'package:leodys/features/forum/domain/repositories/message_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessageRepositoryImpl implements MessageRepository {
  final SupabaseClient client;

  MessageRepositoryImpl({required this.client});

  @override
  Future<List<Message>> getMessages() async {
    final res = await client
        .from('forum_messages')
        .select('id, user_id, content, created_at, user_profiles(first_name, last_name)')
        .order('created_at', ascending: true);

    final data = res as List<dynamic>;
    return data.map((e) => Message.fromMap(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> sendMessage(Message message) async {
    await client.from('forum_messages').insert(message.toMap());
  }
}
