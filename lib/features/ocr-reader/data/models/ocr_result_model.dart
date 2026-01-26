import 'package:leodys/features/ocr-reader/domain/entities/ocr_result.dart';

class OcrResultModel {
  final String text;
  final bool isEmpty;

  const OcrResultModel({
    required this.text,
    required this.isEmpty,
  });

  factory OcrResultModel.fromText(String text) {
    final trimmedText = text.trim();
    return OcrResultModel(
      text: trimmedText.isEmpty ? 'Aucun texte détecté' : trimmedText,
      isEmpty: trimmedText.isEmpty,
    );
  }

  OcrResult toEntity() {
    return OcrResult(
      text: text,
      isEmpty: isEmpty,
    );
  }
}