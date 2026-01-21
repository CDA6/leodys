import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:leodys/common/mixins/datasource_mixin.dart';
import 'package:path_provider/path_provider.dart';

import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/common/utils/app_logger.dart';
import 'package:leodys/features/ocr-reader/data/models/ocr_result_model.dart';

abstract class OCRSpaceDataSource {
  Future<OcrResultModel> recognizeText(File imageFile);
}

class OCRSpaceDataSourceImpl with DataSourceMixin<OcrResultModel> implements OCRSpaceDataSource {
  static const String _apiKey = 'K88946411988957';
  static const String _baseUrl = 'https://api.ocr.space/parse/image';

  @override
  Future<OcrResultModel> recognizeText(File imageFile) {
    return execute('recognizeText', imageFile, (file) async {
      final compressedImage = await _ImageProcessor.compress(file);
      final bytes = await compressedImage.readAsBytes();
      final base64Image = base64Encode(bytes);

      AppLogger().info('Envoi de l\'image à OCR.space...');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'apikey': _apiKey},
        body: {
          'base64Image': 'data:image/jpeg;base64,$base64Image',
          'language': 'fre',
          'isOverlayRequired': 'false',
          'detectOrientation': 'true',
          'scale': 'true',
          'OCREngine': '2',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw NetworkFailure('Erreur HTTP ${response.statusCode}');
      }

      final data = json.decode(response.body);

      if (data['IsErroredOnProcessing'] == true) {
        final errorMessage = data['ErrorMessage']?.join(', ') ?? 'Erreur inconnue';
        throw OCRFailure(errorMessage);
      }

      final parsedResults = data['ParsedResults'] as List?;
      if (parsedResults == null || parsedResults.isEmpty) {
        return OcrResultModel.fromText('');
      }

      final extractedText = parsedResults[0]['ParsedText'] ?? '';

      AppLogger().info('OCR.space - ${extractedText.length} caractères extraits');

      return OcrResultModel.fromText(extractedText);
    });
  }
}

class _ImageProcessor {
  /// Compresse l'image pour respecter la limite de 1 MB
  static Future<File> compress(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      var image = img.decodeImage(bytes);

      if (image == null) {
        throw ImageProcessingFailure('Impossible de décoder l\'image');
      }

      if (image.width > 1920) {
        image = img.copyResize(image, width: 1920);
      }

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      int quality = 85;
      List<int> compressedBytes;

      do {
        compressedBytes = img.encodeJpg(image, quality: quality);
        if (compressedBytes.length > 1024 * 1024 && quality > 30) {
          quality -= 10;
        } else {
          break;
        }
      } while (quality > 30);

      await tempFile.writeAsBytes(compressedBytes);

      final fileSizeKB = compressedBytes.length / 1024;
      AppLogger().info('Image compressée: ${fileSizeKB.toStringAsFixed(1)} KB (qualité: $quality)');

      return tempFile;
    } on ImageProcessingFailure {
      rethrow;
    } catch (e) {
      throw ImageProcessingFailure('Erreur lors du traitement de l\'image: $e');
    }
  }
}