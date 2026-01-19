import 'package:flutter/cupertino.dart';
import 'package:leodys/src/features/audio_reader/domain/usecases/document_usecase.dart';

import '../../domain/models/document.dart';

/// Controller responsable de la gestion de l'état des documents scannés.
/// Cette classe fait le lien entre la couche présentation et domain(usecase).
/// Elle utilise changeNotifier pour prévenir l'interface d'un changement d'état
class DocumentController extends ChangeNotifier {

  final DocumentUsecase documentUsecase;
  DocumentController({required this.documentUsecase});

  bool isLoading = false;
  String message = '';

  List<Document> documents = [];
  Document? selectedDocument;

/// Récuperer l'ensemble des documents
  Future<void> getAllDocuments() async {
    isLoading = true;
    notifyListeners();

    documents = await documentUsecase.getAllDocuments();
    isLoading = false;
    notifyListeners();

  }

  /// Sauvegarder un document scanné
  Future<void> saveDocument(Document document) async {
    await documentUsecase.saveDocument(document); // enregistrement
    await getAllDocuments(); // Mettre à jour la liste
  }

  /// Supprimer un document
  Future<void> deleteDocument(String id) async {
    await documentUsecase.deleteDocument(id); // Suppression
    await getAllDocuments(); // Mettre à jour la liste
  }

  /// Récuperer un document par son identifiant
  Future<Document?> getById(String id) async {
    isLoading = true;
    notifyListeners();

    final document = await documentUsecase.getById(id);
    selectedDocument = document;
    isLoading = false;
    notifyListeners();
    return selectedDocument;
  }
}
