import 'package:leodys/src/features/audio_reader/domain/repositories/document_repository.dart';

import '../models/document.dart';

class DocumentUsecase {

  final DocumentRepository documentRepository;
  DocumentUsecase(this.documentRepository);

  Future<void> saveDocument(Document document){
    return documentRepository.saveDocument(document);
  }

  Future<List<Document>> getAllDocuments(){
    return documentRepository.getAllDocuments();
  }

  Future<Document?> getById(String id){
    return documentRepository.getById(id);
  }

  Future<void> deleteDocument(String id){
    return documentRepository.deleteDocument(id);
  }
}