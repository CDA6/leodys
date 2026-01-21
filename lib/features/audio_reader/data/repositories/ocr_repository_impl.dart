
import '../../domain/repositories/ocr_repository.dart';
import '../services/ocr_service.dart';

/// Implémentation du repository de OCR
/// Relie le Domain (contrat OcrRepository) et le service technique de
/// reconnaissance de texte (OcrServiceImpl)
class OcrRepositoryImpl implements OcrRepository{
  // Appel le service Google ML Kit
  final OcrService ocrService;
  // Injection du service OCR via le constructeur
  OcrRepositoryImpl (this.ocrService);

  /// Lance la reconnaissance de texte à partir d'une photo
  @override
  Future<String> extractTextFromImage(String imagePath) async {

    try{

      final text = await ocrService.recognizeText(imagePath);

      if (text.trim().isEmpty){
        return "Aucun texte détecté sur l'image";
      }

      return text;

    }catch(e) {

      throw Exception("Impossible de lire le message");

    }

  }


}