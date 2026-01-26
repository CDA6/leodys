import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:leodys/features/cards/domain/card_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class CardsLocalDatasource {
  Future<void> removeCard(CardModel card) async {
    final folder = Directory(card.folderPath);

    if (await folder.exists()) {
      await folder.delete(recursive: true);
    }
  }

  Future<CardModel> saveScannedImages({
    required List<File> images,
    required String cardName,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();

    // generation d'un uuid
    final cardId = const Uuid().v4();
    final cardFolder = Directory('${appDir.path}/cards/$cardId');

    // on crée le dossier si il n'existe pas
    await cardFolder.create(recursive: true);

    String? rectoPath;
    String? versoPath;

    for (int i = 0; i < images.length; i++) {
      final image = images[i];
      final newFile = await image.copy(
        '${cardFolder.path}/${i == 0 ? "recto" : "verso"}.jpg',
      );

      if (i == 0) rectoPath = newFile.path;
      if (i == 1) versoPath = newFile.path;
    }

    // creation du fichier card.json contenant les métadonnées de la carte
    final now = DateTime.now().toUtc().toIso8601String();

    final cardJson = {
      "id": cardId,
      "name": cardName,
      "created_at": now,
      "updated_at": now,
      "sync_status": "PENDING",
      "deleted": false,
      "images": {
        "recto": "recto.jpg",
        "verso": "verso.jpg",
      }
    };

    final jsonFile = File('${cardFolder.path}/card.json');
    await jsonFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(cardJson),
    );
    print('fichier sauvé a : $cardFolder');

    return CardModel(
      id: cardId,
      name: cardName,
      rectoPath: rectoPath ?? '',
      versoPath: versoPath ?? '',
      folderPath: cardFolder.path,
    );
  }

  // récupère les cartes locales
  Future<List<CardModel>> getLocalUserCards() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cardsDir = Directory('${appDir.path}/cards');

    if (!cardsDir.existsSync()) return [];

    final folders = cardsDir.listSync().whereType<Directory>();

    List<CardModel> cards = [];

    for (final folder in folders) {
      final jsonFile = File('${folder.path}/card.json');

      // sécurité : on ignore les dossiers sans métadonnées
      if (!jsonFile.existsSync()) continue;

      final jsonString = await jsonFile.readAsString();
      final Map<String, dynamic> data = jsonDecode(jsonString);

      if (data['deleted'] == true) continue;

      final rectoPath = data['images']?['recto'] != null
          ? '${folder.path}/${data['images']['recto']}'
          : '';

      final versoPath = data['images']?['verso'] != null
          ? '${folder.path}/${data['images']['verso']}'
          : '';

      cards.add(
        CardModel(
          id: data['id'],
          name: data['name'],
          rectoPath: rectoPath,
          versoPath: versoPath,
          folderPath: folder.path,
        ),
      );
    }

    return cards;
  }

  Future<List<CardModel>> getCardsToSync() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cardsDir = Directory('${appDir.path}/cards');

    if (!cardsDir.existsSync()) return [];

    final folders = cardsDir.listSync().whereType<Directory>();
    List<CardModel> cards = [];

    for (final folder in folders) {
      final jsonFile = File('${folder.path}/card.json');
      if (!jsonFile.existsSync()) continue;

      final data = jsonDecode(await jsonFile.readAsString());

      // inclure les cartes PENDING, même si deleted = true
      if (data['sync_status'] != 'PENDING') continue;

      cards.add(CardModel.fromJson(data, folderPath: folder.path));
    }

    return cards;
  }

  Future<void> markAsSynced(String cardId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final cardFolder = Directory('${appDir.path}/cards/$cardId');

    final jsonFile = File('${cardFolder.path}/card.json');

    if (!jsonFile.existsSync()) return;

    final data = jsonDecode(await jsonFile.readAsString());
    if(data['sync_status'] == 'PENDING') data['sync_status'] = 'SYNCED';
    data['updated_at'] = DateTime.now().toUtc().toIso8601String();


    await jsonFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
    );
  }

  Future<void> markAsDeleted(String cardId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final cardFolder = Directory('${appDir.path}/cards/$cardId');
    final jsonFile = File('${cardFolder.path}/card.json');

    if (!jsonFile.existsSync()) return;

    final data = jsonDecode(await jsonFile.readAsString());
    print('data before : $data');
    data['deleted'] = true;
    data['sync_status'] = 'PENDING';
    data['updated_at'] = DateTime.now().toUtc().toIso8601String();
    print('data after : $data');

    await jsonFile.writeAsString(
      JsonEncoder.withIndent('  ').convert(data),
    );

    // lecture pour vérifier
    final newContent = await jsonFile.readAsString();
    print('JSON on disk : $newContent');
  }


}