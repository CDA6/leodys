import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/card_model.dart';

class CardsRemoteDatasource {
  final SupabaseClient supabase;

  CardsRemoteDatasource({required this.supabase});

  // récupération des cartes hébergées sur supabase
  Future<void> pullRemoteCards(String userId) async {
    var response = [];
    try {
      response = await supabase
          .from('loyalty_card')
          .select()
          .eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw PostgrestException(message: e.message);
    } catch (e) {
      throw Exception(e.toString());
    }

    final appDir = await getApplicationDocumentsDirectory();
    final cardsDir = Directory('${appDir.path}/cards');

    // parcourt les lignes recupérées de la table
    for (final remote in response) {
      // id de la carte
      final cardId = remote['id'];
      // nouveau chemin en local
      final folder = Directory('${cardsDir.path}/$cardId');
      // chemin du fichier json avec métadonnées
      final jsonFile = File('${folder.path}/card.json');

      if (!folder.existsSync()) {
        await folder.create(recursive: true);
      }

      Map<String, dynamic>? localData;

      if (jsonFile.existsSync()) {
        localData = jsonDecode(await jsonFile.readAsString());
        if (localData!['updated_at'] != null &&
            localData['updated_at'].compareTo(remote['updated_at']) >= 0) {
          continue;
        }
      }

      // téléchargement des images du bucket supabase
      final images = ['recto.jpg', 'verso.jpg'];

      // enregistrement des images de la carte en local
      for (final img in images) {
        final storagePath = 'user_$userId/$cardId/$img';
        try {
          final bytes = await supabase.storage.from('cards').download(storagePath);
          final file = File('${folder.path}/$img');
          await file.writeAsBytes(bytes);
        } on StorageException catch (e) {
          throw StorageException(e.message);
        } catch (e) {
          throw Exception(e.toString());
        }
      }

      // ecriture du fichier json
      final newJson = {
        'id': cardId,
        'name': remote['name'],
        'created_at': remote['created_at'],
        'updated_at': remote['updated_at'],
        'sync_status': 'SYNCED',
        'deleted': remote['deleted'],
        'images': {
          'recto': 'recto.jpg',
          'verso': 'verso.jpg',
        }
      };

      await jsonFile.writeAsString(jsonEncode(newJson));
    }
  }

  Future<void> deleteCard(String cardId, String userId) async {
    // suppression des fichiers dans le bucket
    final images = ['recto.jpg', 'verso.jpg'];
    for (final img in images) {
      final path = 'user_$userId/$cardId/$img';
      try {
        await supabase.storage.from('cards').remove([path]);
      } on StorageException catch (e) {
        throw StorageException(e.message);
      } catch (e) {
        throw Exception(e.toString());
      }
    }

    // supprimer ligne de la carte dans la table loyalty_cards
    try {
      await supabase
          .from('loyalty_card')
          .delete()
          .eq('id', cardId)
          .eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw PostgrestException(message: e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> uploadCard(CardModel card) async {
    // upload des images dans le bucket
    final images = <String, String>{
      'recto': card.rectoPath,
      // ajout du verso seulement s'il existe
      if (card.versoPath != null && card.versoPath!.isNotEmpty)
        'verso': card.versoPath!,
    };

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw AuthException("Erreur : utilisateur non connecté");
    }

    final userId = user.id;

    // upload de chaque image dans le bucket
    for (final entry in images.entries) {
      final localPath = entry.value;
      if (localPath.isEmpty) continue;

      final file = File(localPath);
      if (!file.existsSync()) continue;

      // chemin distant
      final storagePath = 'user_$userId/${card.id}/${entry.key}.jpg';

      try {
        await supabase.storage
            .from('cards')
            .upload(storagePath, file, fileOptions: const FileOptions(upsert: true));
      } on StorageException catch (e) {
        throw StorageException(e.message);
      } catch (e) {
        throw Exception(e.toString());
      }
    }

    // upsert dans la table loyalty_card
    try {
      // ajout ou modification d'une ligne existante dans la table loyalty_card
      await supabase.from('loyalty_card').upsert({
        'id': card.id,
        'user_id': userId,
        'name': card.name,
        'created_at': card.updatedAt.toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        'deleted': card.deleted,
      }, onConflict: 'id'); // clé primaire pour upsert
    } on PostgrestException catch (e) {
      throw PostgrestException(message: e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}