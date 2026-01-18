import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/common/utils/app_logger.dart';
import 'package:leodys/features/ocr-reader/data/models/ocr_result_model.dart';
import 'package:leodys/common/mixins/datasource_mixin.dart';

abstract interface class MLKitDataSource {
  Future<OcrResultModel> recognizeText(File imageFile);
}

class MLKitDataSourceImpl with DataSourceMixin<OcrResultModel> implements MLKitDataSource {
  @override
  Future<OcrResultModel> recognizeText(File imageFile) {
    return execute('recognizeText', imageFile, (file) async {
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

      try {
        final processedImage = await _ImageProcessor.preprocess(file);
        final inputImage = InputImage.fromFile(processedImage);
        final recognizedText = await textRecognizer.processImage(inputImage);

        AppLogger().info('ML Kit - ${recognizedText.blocks.length} blocs détectés');

        return OcrResultModel.fromText(recognizedText.text);
      } finally {
        textRecognizer.close();
      }
    });
  }
}

class _ImageProcessor {
  /// Prétraite l'image pour faciliter l'analyse de ML Kit
  static Future<File> preprocess(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw ImageProcessingFailure('Impossible de décoder l\'image');
      }

      final originalWidth = image.width;
      final originalHeight = image.height;

      // Redimensionnement si nécessaire
      img.Image processedImage = image;
      if (image.width > 2048) {
        processedImage = img.copyResize(image, width: 2048);
        AppLogger().trace('Redimensionnement: ${originalWidth}x${originalHeight} → ${processedImage.width}x${processedImage.height}');
      }

      // Prétraitement (grayscale, contraste, luminosité)
      processedImage = img.grayscale(processedImage);
      processedImage = img.adjustColor(processedImage, contrast: 1.3);
      processedImage = img.adjustColor(processedImage, brightness: 1.1);

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(img.encodeJpg(processedImage, quality: 95));

      AppLogger().info('Image prétraitée pour ML Kit');

      return tempFile;
    } on ImageProcessingFailure {
      rethrow;
    } catch (e) {
      throw ImageProcessingFailure('Erreur lors du prétraitement de l\'image: $e');
    }
  }
}