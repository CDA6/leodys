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
    final response = await supabase
        .from('loyalty_card')
        .select()
        .eq('user_id', userId);

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
        } catch (e) {
          print('Warning: image not found in bucket: $storagePath');
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
        print('suppression $path');
      } catch (e) {
        // ignorer si le fichier n’existe pas, ou logger
        print('Erreur suppression image $path: $e');
      }
    }

    // supprimer ligne de la carte dans la table loyalty_cards
    await supabase
        .from('loyalty_card')
        .delete()
        .eq('id', cardId)
        .eq('user_id', userId);
  }

  Future<void> uploadCard(String userId, CardModel card) async {
    // upload des images dan sle bucket
    final images = <String, String>{
      'recto': card.rectoPath,
      'verso': ?card.versoPath,
    };

    for (final entry in images.entries) {
      final localPath = entry.value;
      if (localPath.isEmpty) continue;

      final file = File(localPath);
      if (!file.existsSync()) continue;

      final storagePath = 'user_$userId/${card.id}/${entry.key}.jpg';

      try {
        await supabase.storage
            .from('cards')
            .upload(storagePath, file, fileOptions: const FileOptions(upsert: true));
      } catch (e) {
        print('Erreur upload image ${entry.key}: $e');
        rethrow;
      }
    }

    // upsert dans la table
    try {
      await supabase.from('loyalty_card').upsert({
        'id': card.id,
        'user_id': userId,
        'name': card.name,
        'created_at': card.updatedAt.toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        'deleted': card.deleted,
      }, onConflict: 'id'); // clé primaire pour upsert
    } catch (e) {
      print('Erreur upsert card ${card.id}: $e');
      rethrow;
    }
  }

}