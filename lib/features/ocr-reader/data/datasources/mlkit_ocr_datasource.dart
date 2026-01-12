import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import '../models/ocr_result_model.dart';

abstract class MLKitDataSource {
  Future<OcrResultModel> recognizeText(File imageFile);
}

class MLKitDataSourceImpl implements MLKitDataSource {
  final TextRecognizer _textRecognizer;

  MLKitDataSourceImpl() : _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  @override
  Future<OcrResultModel> recognizeText(File imageFile) async {
    try {
      final processedImage = await _ImageProcessor.preprocess(imageFile);
      final inputImage = InputImage.fromFile(processedImage);

      final recognizedText = await _textRecognizer.processImage(inputImage);

      print('=== ML Kit - Résultats ===');
      print('Blocs détectés : ${recognizedText.blocks.length}');
      print('Texte : ${recognizedText.text}');

      if (recognizedText.text.isEmpty) {
        return OcrResultModel.fromText(
          'Aucun texte détecté. Assurez-vous que l\'image est nette et bien éclairée.',
        );
      }

      return OcrResultModel.fromText(recognizedText.text);
    } catch (e) {
      throw Exception('Erreur ML Kit: $e');
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}

class _ImageProcessor {

  /// Prétraite l'image pour faciliter l'analyse de ML Kit
  static Future<File> preprocess(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Impossible de décoder l\'image');
    }

    img.Image processedImage = image;

    if (image.width > 2048) {
      processedImage = img.copyResize(image, width: 2048);
    }

    processedImage = img.grayscale(processedImage);
    processedImage = img.adjustColor(processedImage, contrast: 1.3);
    processedImage = img.adjustColor(processedImage, brightness: 1.1);

    final tempDir = await getTemporaryDirectory();
    final tempFile = File(
      '${tempDir.path}/processed_${DateTime
          .now()
          .millisecondsSinceEpoch}.jpg',
    );
    await tempFile.writeAsBytes(img.encodeJpg(processedImage, quality: 95));

    return tempFile;
  }
}