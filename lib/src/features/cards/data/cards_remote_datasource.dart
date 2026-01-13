import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class CardsRemoteDatasource {
  final SupabaseClient supabase;

  CardsRemoteDatasource({required this.supabase});

  Future<void> uploadPdf({
    required File file,
    required String userId,
    required String fileName
  }) async {
    if (supabase.auth.currentUser == null) {
      final response = await supabase.auth.signInWithPassword(
        email: 'coleenconte@icloud.com',
        password: '780Asq35.',
      );
    }
    debug();

    await supabase.storage.from('cards').upload(
      'user_$userId/${file.path.split('/').last}', // chemin dans le bucket
      file,
      fileOptions: FileOptions(
        contentType: 'application/pdf',
        metadata: {
          'owner': userId,  // <-- important pour ta policy
        },
      ),
    );
  }

  void debug() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      print('Utilisateur connecté : ${user.email} (${user.id})');
    } else {
      print('Aucun utilisateur connecté');
    }
  }

  Future<List<String>> listUserCards(String userId) async {
    final response = await supabase.storage
        .from('cards')
        .list(path: userId);

    return response.map((e) => e.name).toList();
  }
}