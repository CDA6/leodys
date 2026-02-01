import 'package:hive/hive.dart';
import '../../domain/models/document.dart';
import '../../domain/repositories/document_repository.dart';

/// Gestion de la sauvegarde des textes extraits à partir des photos
class DocumentRepositoryImpl implements DocumentRepository {

  static const String _boxName = 'document_box';

  /// Sauvegarder un document sous forme de Map<String, Dynamic>
  /// ans passer par typeAdapter
  @override
  Future<void> saveDocument(Document document) async {
    final box = await Hive.openBox(_boxName);
    await box.put(document.idText,{
      'idText': document.idText,
      'title': document.title,
      'content': document.content,
      'createAt': document.createAt.toIso8601String(),
      // toIso8601String() est un affichage normalisé de la date
      // préconiser pour les sauvegardes dans Hive
    });
  }

 ///Ouvre la box Hive afin d'accéder aux données stockées en local
  /// Suppression d'un document
  @override
  Future<void> deleteDocument(String id) async {
    final box = await Hive.openBox(_boxName);
    await box.delete(id);

  }

  /// Récuperer un document à partir de son id
  @override
  Future<Document?> getById(String id) async {
    final box = await Hive.openBox(_boxName);

    final data = box.get(id);
    if (data == null) {
      return null;
    }

    // reconstruire l'objet
    return Document (
        idText: data['idText'],
        title: data['title'],
        content: data['content'],
        createAt: DateTime.parse(data['createAt']),
    );

  }

  /// Récuperer une liste de documents enregistrés
  @override
  Future<List<Document>> getAllDocuments() async {
    final box = await Hive.openBox(_boxName);
    final List<Document> documents = [];
    for (final key in box.keys){
      final data = box.get(key);
      documents.add(
        Document(
          idText: data['idText'],
          title: data ['title'],
          content: data['content'],
          createAt: DateTime.parse(data['createAt']),
        )
      );
    }
    return documents;
  }

}