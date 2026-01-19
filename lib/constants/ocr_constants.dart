import 'package:flutter_dotenv/flutter_dotenv.dart';

class OCRConstants {
  static String get _apiKeyOCR => dotenv.env['OCR_SPACE_KEY'] ?? '';

}