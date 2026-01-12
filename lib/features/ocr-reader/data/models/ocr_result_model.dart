import '../../domain/entities/ocr_result.dart';

class OcrResultModel extends OcrResult {
  const OcrResultModel({
    required super.text,
    required super.isEmpty,
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