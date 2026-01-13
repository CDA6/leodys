import '../models/document.dart';

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