import '../models/document.dart';

/// DocumentRepository une une classe abstraite qui joue le role d'interface métier.
abstract class DocumentRepository {

  ///Enregistrement d'un document
  Future<void> saveDocument(Document document);

  ///Supprimer un doucment
  Future<void> deleteDocument(String id);

  ///Liste des doucments
  Future<List<Document>> getAllDocuments();

  ///Recupere un document par son id
  Future<Document?> getById(String id);

}