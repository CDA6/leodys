import 'package:leodys/features/vehicle_recognition/data/services/plate_ocr_service.dart';
import 'package:leodys/features/vehicle_recognition/domain/repositories/plate_ocr_repository.dart';

/// Implémentation du repositories de l'OCR
/// Relie le Domain et le service technique de reconnaissance de texte
class PlateOcrRepositoryImpl implements PlateOcrRepository {

  final PlateOcrService plateOcrService;

  PlateOcrRepositoryImpl(this.plateOcrService);

  /// Lance la reconnaissance du texte
  @override
  Future<String?> extractTextFromImage(String imagePath) async {

    try{

      final text = await plateOcrService.recognizeText(imagePath);

      return text.trim().isEmpty ? "Aucun text détecté" : text;

    }catch (e) {

      throw Exception("Impossible de lire le message");

    }

  }

}