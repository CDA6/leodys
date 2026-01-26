import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:leodys/features/cards/domain/card_model.dart';
import 'package:leodys/features/cards/domain/card_update_model.dart';
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

    final imagesJson = {'recto': 'recto.jpg'};
    if (rectoPath == null) {
      throw StateError("La carte doit avoir une image recto");
    }

    if (versoPath != null && versoPath.trim().isNotEmpty) {
      imagesJson['verso'] = 'verso.jpg';
    }

    final cardJson = {
      "id": cardId,
      "name": cardName,
      "created_at": now,
      "updated_at": now,
      "sync_status": "PENDING",
      "deleted": false,
      "images": imagesJson,
    };

    final jsonFile = File('${cardFolder.path}/card.json');
    await jsonFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(cardJson),
    );

    return CardModel(
      id: cardId,
      name: cardName,
      rectoPath: rectoPath!,  // toujours présent
      versoPath: versoPath,    // peut rester null
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

      late Map<String, dynamic> data;

      final jsonString = await jsonFile.readAsString();
      try {
        data = jsonDecode(jsonString);
      } on FormatException catch (e) {
        throw FormatException(e.message);
      }

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
    late Directory appDir;
    appDir = await getApplicationDocumentsDirectory();

    final cardsDir = Directory('${appDir.path}/cards');

    if (!cardsDir.existsSync()) return [];

    final folders = cardsDir.listSync().whereType<Directory>();
    List<CardModel> cards = [];

    for (final folder in folders) {
      final jsonFile = File('${folder.path}/card.json');
      if (!jsonFile.existsSync()) continue;

      late dynamic data;
      try {
        data = jsonDecode(await jsonFile.readAsString());
      } on FormatException catch (e) {
        throw FormatException(e.message);
      }

      // inclure les cartes PENDING, même si deleted = true
      if (data['sync_status'] != 'PENDING') continue;

      cards.add(CardModel.fromJson(data, folderPath: folder.path));
    }

    return cards;
  }

  Future<void> markAsSynced(String cardId) async {
    late Directory appDir;
    appDir = await getApplicationDocumentsDirectory();

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

    late dynamic data;
    try {
      data = jsonDecode(await jsonFile.readAsString());
    } on FormatException catch (e) {
      throw FormatException(e.message);
    }

    data['deleted'] = true;
    data['sync_status'] = 'PENDING';
    data['updated_at'] = DateTime.now().toUtc().toIso8601String();

    await jsonFile.writeAsString(
      JsonEncoder.withIndent('  ').convert(data),
    );
  }


  Future<CardModel> updateCard(CardUpdateModel update) async {
    String rectoPath = update.card.rectoPath;
    String? versoPath = update.card.versoPath;

    final updatedName = update.newName ?? update.card.name;

    // remplacer recto
    if (update.newRecto != null) {
      final rectoFile = File('${update.card.folderPath}/recto.jpg');
      await update.newRecto!.copy(rectoFile.path);
      rectoPath = rectoFile.path;
    }

    // gérer verso
    if (update.removeVerso) {
      final versoFile = File('${update.card.folderPath}/verso.jpg');
      if (await versoFile.exists()) await versoFile.delete();
      versoPath = null;
    } else if (update.newVerso != null) {
      final versoFile = File('${update.card.folderPath}/verso.jpg');
      await update.newVerso!.copy(versoFile.path);

      versoPath = versoFile.path;
    }

    final updatedCard = CardModel(
      id: update.card.id,
      name: updatedName,
      rectoPath: rectoPath,
      versoPath: versoPath,
      folderPath: update.card.folderPath,
      syncStatus: 'PENDING',
      deleted: update.card.deleted,
      updatedAt: DateTime.now(),
    );

    // JSON
    final imagesJson = {'recto': 'recto.jpg'};
    if (versoPath != null) imagesJson['verso'] = 'verso.jpg';

    final cardJson = {
      "id": updatedCard.id,
      "name": updatedCard.name,
      "created_at": update.card.updatedAt.toIso8601String(),
      "updated_at": updatedCard.updatedAt.toIso8601String(),
      "sync_status": updatedCard.syncStatus,
      "deleted": updatedCard.deleted,
      "images": imagesJson,
    };

    final jsonFile = File('${updatedCard.folderPath}/card.json');
    await jsonFile.writeAsString(JsonEncoder.withIndent('  ').convert(cardJson));

    return updatedCard;
  }

}