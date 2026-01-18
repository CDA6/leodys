import 'package:leodys/src/features/audio_reader/domain/repositories/document_repository.dart';

import '../models/document.dart';

/// Cas d'utilisation pour la gestion métier des documents scannés
class DocumentUsecase {

  final DocumentRepository documentRepository;
  DocumentUsecase(this.documentRepository);

  /// Sauvegarde d'un document scanné
  Future<void> saveDocument(Document document){
    return documentRepository.saveDocument(document);
  }

  /// Récuperer les documents enregistrés
  Future<List<Document>> getAllDocuments(){
    return documentRepository.getAllDocuments();
  }

  /// Récuperer un document grace à son identifiant
  Future<Document?> getById(String id){
    return documentRepository.getById(id);
  }

  /// Supprimer un document
  Future<void> deleteDocument(String id){
    return documentRepository.deleteDocument(id);
  }
}