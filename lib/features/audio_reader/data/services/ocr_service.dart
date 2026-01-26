import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {

/// Analyse l'image et retourne le texte reconnu
  Future<String> recognizeText(String imagePath) async {

    // Récuperere l'image depuis le chemin.
    // File(imagePath) Transforme le chemin en objet fichier
    // InputImage.fromFile() Convertir le fichier en image analysable par TextRecognizer()
    final inputImage = InputImage.fromFile(File(imagePath));

    // Initialise recognizer ML KIT.
    // TextRecognizer() analyse l'image et extrait du texte
    final textRecognizer = TextRecognizer();

    try {
      // lancement de la reconnaissance avec processImage()
      final RecognizedText recognizedText = await textRecognizer.processImage(
          inputImage);
      // Récuperer le texte reconnu
      return recognizedText.text;
    }catch(e){
      throw Exception("Erreur de la reconnaissance OCR");
    }finally{
      textRecognizer.close();
    }
  }
}