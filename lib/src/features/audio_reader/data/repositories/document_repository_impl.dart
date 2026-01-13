import 'package:hive/hive.dart';
import 'package:leodys/src/features/audio_reader/domain/models/document.dart';
import 'package:leodys/src/features/audio_reader/domain/repositories/document_repository.dart';

class DocumentRepositoryImpl implements DocumentRepository {

  static const String _boxName = 'document_box';


  @override
  Future<void> deleteDocument(String id) async {
    final box = await Hive.openBox(_boxName);
    await box.delete(id);

  }

  @override
  Future<Document?> getById(String id) async {
    final box = await Hive.openBox(_boxName);

    final data = box.get(id);
    if (data == null) {
      return null;
    }

    return Document (
        idText: data['idText'],
        title: data['title'],
        content: data['content'],
        createAt: DateTime.parse(data['createAt']),
    );

  }

  @override
  Future<List<Document>> getAllDocuments() async {
    final box = await Hive.openBox(_boxName);
    final List<Document> documents = [];
    for (final key in box.keys){
      final data = box.get(key);

      // if (data == null ||
      //     data['idText'] == null ||
      //     data['title'] == null ||
      //     data['content'] == null ||
      //     data['createAt'] == null) {
      //   continue;
      // }

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

  @override
  Future<void> saveDocument(Document document) async {
    final box = await Hive.openBox(_boxName);
    await box.put(document.idText,{
      'idText': document.idText,
      'title': document.title,
      'content': document.content,
      'createAt': document.createAt.toIso8601String(),
    });
  }

}