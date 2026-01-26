import '../repositories/ocr_repository.dart';

/// Cas d'usage:
/// Scan un document et retourne un texte
class ScanDocumentUsecase {

  final OcrRepository ocrRepository;

  ScanDocumentUsecase(this.ocrRepository);

  Future<String> scanDocument(String imagePath){
    return ocrRepository.extractTextFromImage(imagePath);
  }
}