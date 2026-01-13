import 'package:flutter/cupertino.dart';
import 'package:leodys/src/features/audio_reader/domain/usecases/document_usecase.dart';

import '../../domain/models/document.dart';

class DocumentController extends ChangeNotifier {
  final DocumentUsecase documentUsecase;

  DocumentController({required this.documentUsecase});

  bool isLoading = false;
  String message = '';

  List<Document> documents = [];
  Document? selectedDocument;


  Future<void> getAllDocuments() async {
    isLoading = true;
    notifyListeners();

    documents = await documentUsecase.getAllDocuments();
    isLoading = false;
    notifyListeners();
    print('Documents loaded: ${documents.length}');

  }

  Future<void> saveDocument(Document document) async {
    isLoading = true;
    notifyListeners();

    await documentUsecase.saveDocument(document);
    await getAllDocuments();
  }

  Future<void> deleteDocument(String id) async {
    isLoading = true;
    notifyListeners();

    await documentUsecase.deleteDocument(id);
    await getAllDocuments();
  }

  Future<Document?> getById(String id) async {
    isLoading = true;
    notifyListeners();

    selectedDocument = await documentUsecase.getById(id);
    isLoading = false;
    notifyListeners();
  }
}
