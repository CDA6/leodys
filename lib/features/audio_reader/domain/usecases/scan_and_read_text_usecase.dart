import '../repositories/ocr_repository.dart';
import '../models/reader_config.dart';
import '../repositories/tts_repository.dart';

/// Cas d'usage :
/// L'utilisateur scan un document, le systeme traite le document et transforme en texte.
/// Le systeme lance la lecrture audio
class ScanAndReadTextUsecase {

  final OcrRepository ocrRepository;
  final TtsRepository ttsRepository;

  ScanAndReadTextUsecase(this.ocrRepository, this.ttsRepository);

///   Lancer le Scan du document. Vérifier le traitement de l'image->texte
///   Lancer la lecture audio
  Future<void> execute (String imagePath, ReaderConfig config) async {

    final text = await ocrRepository.extractTextFromImage(imagePath);

    if (text.trim().isEmpty || text.startsWith('Aucun') || text.startsWith('Impossible') ){
      return;
    }

    return ttsRepository.speak(text, config);


  }
}