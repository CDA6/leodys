import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';

class ScanService {
  /// Lance le scan et renvoie un File (image) ou null si annulé
  Future<File?> scanDocument() async {
    try {
      List<String> pictures = await CunningDocumentScanner.getPictures() ?? [];
      if (pictures.isEmpty) return null;

      // renvoie uniquement la première image prise
      return File(pictures.first);
    } catch (e) {
      print("Erreur scan : $e");
      return null;
    }
  }

  /// pour scanner plusieurs images
  Future<List<File>> scanMultipleDocuments() async {
    List<String> pictures = await CunningDocumentScanner.getPictures() ?? [];
    return pictures.map((p) => File(p)).toList();
  }
}