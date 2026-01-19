
import '../../domain/repositories/ocr_repository.dart';
import '../services/ocr_service_impl.dart';

/// Implémentation du repository de OCR
/// Relie le Domain (contrat OcrRepository) et le service technique de
/// reconnaissance de texte (OcrServiceImpl)
class OcrRepositoryImpl implements OcrRepository{
  // Appel le service Google ML Kit
  final OcrServiceImpl ocrServiceImpl;
  // Injection du service OCR via le constructeur
  OcrRepositoryImpl (this.ocrServiceImpl);

  /// Lance la reconnaissance de texte à partir d'une photo
  @override
  Future<String> extractTextFromImage(String imagePath) async {

    try{

      final text = await ocrServiceImpl.recognizeText(imagePath);

      if (text.trim().isEmpty){
        return "Aucun texte détecté sur l'image";
      }

      return text;

    }catch(e) {

      throw Exception("Impossible de lire le message");

    }

  }


}