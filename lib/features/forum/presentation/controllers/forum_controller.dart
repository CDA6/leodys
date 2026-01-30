import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:leodys/features/forum/domain/entities/message.dart';
import 'package:uuid/uuid.dart';

import '../../presentation/providers/message_provider.dart';

final forumControllerProvider = Provider<ForumController>(
      (ref) => ForumController(ref: ref),
);

class ForumController {
  final Ref ref;

  ForumController({required this.ref});

  /// Send a new message
  Future<void> sendMessage(String content) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    final hasProfile = await _hasProfile(user.id);
    if (!hasProfile) {
      throw Exception('User has no profile');
    }

    final message = Message(
      id: const Uuid().v4(),
      userId: user.id,
      username: await _getUsername(user.id),
      content: content,
      createdAt: DateTime.now(),
    );

    await ref.read(messagesProvider.notifier).addMessage(message);
  }



  /// Fetch the username from Supabase profiles or fallback
  Future<String> _getUsername(String userId) async {

    final data = await Supabase.instance.client
        .from('user_profiles')
        .select('first_name, last_name')
        .eq('id', userId)
        .maybeSingle();

    if (data != null) {
      final firstName = data['first_name'] as String? ?? '';
      final lastName = data['last_name'] as String? ?? '';
      final fullName = '$firstName $lastName'.trim();
      if (fullName.isNotEmpty) return fullName;
    }

    final user = Supabase.instance.client.auth.currentUser;
    return user?.email ?? 'Anonymous';
  }

  Future<bool> _hasProfile(String userId) async {
    final data = await Supabase.instance.client
        .from('user_profiles')
        .select('id')
        .eq('id', userId)
        .maybeSingle();

    debugPrint(data != null ? "user id = " +data['id'] : 'user is null');
    return data != null;
  }

}
