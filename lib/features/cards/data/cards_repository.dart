import 'dart:io';
import 'package:leodys/features/cards/data/datasources/cards_local_datasource.dart';
import 'package:leodys/features/cards/data/datasources/cards_remote_datasource.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../domain/card_model.dart';

class CardsRepository {
  final CardsRemoteDatasource remote;
  final CardsLocalDatasource local;
  CardsRepository(this.remote, this.local);

  Future<List<CardModel>> getLocalUserCards() async {
    return await local.getLocalUserCards();
  }

  Future<File> createPdfFromImages(List<String> imagesPaths, String name) async {
    final pdf = pw.Document();
    for (var path in imagesPaths) {
      final image = pw.MemoryImage(File(path).readAsBytesSync());
      pdf.addPage(pw.Page(build: (pw.Context context) => pw.Center(child: pw.Image(image))));
    }

    final Directory output = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final pathFile =
        "${output.path}/$name.pdf";
    final file = File(pathFile);
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> uploadCard(File file, String userId, String name) async {
    await remote.uploadPdf(file: file, userId: userId, fileName: name);
  }

  Future<void> deleteCard(CardModel card) async {
    await local.deleteCard(card);
  }

  Future<List<CardModel>> getRemoteUserCards(String userId) async {
    return await remote.listUserCards(userId);
  }

  Future<CardModel> saveNewCard(List<File> images, String cardName) async {
    return await local.saveScannedImages(images: images, cardName: cardName);
  }
}