import 'package:flutter_tts/flutter_tts.dart';

class TtsController {
  final FlutterTts _flutterTts = FlutterTts();

  TtsController() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("fr-FR");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5); // Vitesse réduite pour une meilleure compréhension DYS
  }

  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}