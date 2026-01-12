

import 'package:leodys/src/features/audio_reader/data/services/ocr_service_impl.dart';
import 'package:leodys/src/features/audio_reader/domain/repositories/ocr_repository.dart';

class OcrRepositoryImpl implements OcrRepository{

  final OcrServiceImpl ocrServiceImpl;

  OcrRepositoryImpl (this.ocrServiceImpl);

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