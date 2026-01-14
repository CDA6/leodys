import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/card_model.dart';

class CardsRemoteDatasource {
  final SupabaseClient supabase;

  CardsRemoteDatasource({required this.supabase});

  Future<void> uploadPdf({
    required File file,
    required String userId,
    required String fileName
  }) async {
    if (supabase.auth.currentUser == null) {
      // A SUPPRIMER PLUS TARD
      final response = await supabase.auth.signInWithPassword(
        email: 'coleenconte@icloud.com',
        password: '780Asq35.',
      );
    }

    await supabase.storage.from('cards').upload(
      'user_$userId/$fileName.pdf',
      file,
      fileOptions: const FileOptions(
        contentType: 'application/pdf',
      ),
    );
  }

  // Future<List<String>> listUserCards(String userId) async {
  //   final response = await supabase.storage
  //       .from('cards')
  //       .list(path: userId);
  //
  //   return response.map((e) => e.name).toList();
  // }

  Future<List<CardModel>> listUserCards(String userId) async {
    final files = await supabase.storage
        .from('cards')
        .list(path: 'user_$userId');

    return files.map((file) {
      return CardModel(
        name: file.name.replaceAll('.pdf', ''),
        folderPath: 'user_$userId/${file.name}',
        rectoPath: 'user_$userId/${file.name}/recto.png',
        versoPath: 'user_$userId/${file.name}/verso.png'
      );
    }).toList();
  }
}