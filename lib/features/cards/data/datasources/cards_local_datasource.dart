import 'dart:async';
import 'dart:io';

import 'package:leodys/features/cards/domain/card_model.dart';
import 'package:path_provider/path_provider.dart';

class CardsLocalDatasource {
  Future<void> deleteCard(CardModel card) async {
    final folder = Directory(card.folderPath!);

    if (await folder.exists()) {
      await folder.delete();
    }
  }

  Future<CardModel> saveScannedImages({
    required List<File> images,
    required String cardName,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final cardFolder = Directory('${appDir.path}/$cardName');

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

    return CardModel(
      name: cardName,
      rectoPath: rectoPath ?? '',
      versoPath: versoPath ?? '',
      folderPath: cardFolder.path,
    );
  }

  // récupère les cartes locales
  Future<List<CardModel>> getLocalUserCards() async {
    final directory = await getApplicationDocumentsDirectory();
    final folders = directory.listSync().whereType<Directory>();

    List<CardModel> cards = [];

    for (final folder in folders) {
      final files = folder.listSync().whereType<File>().toList();
      String? recto = files.firstWhere(
            (f) => f.path.endsWith('recto.jpg'),
        orElse: () => File(''),
      ).path;
      String? verso = files.firstWhere(
            (f) => f.path.endsWith('verso.jpg'),
        orElse: () => File(''),
      ).path;

      final cardName = folder.uri.pathSegments.elementAt(folder.uri.pathSegments.length - 2);
      print("cardname: $cardName");
      cards.add(CardModel(
        name: cardName,
        rectoPath: recto,
        versoPath: verso,
        folderPath: folder.path,
      ));
    }

    return cards;
  }

}