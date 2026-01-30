import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> speak({
    required String text,
    required String languageCode,
    required double speechRate,
    required double pitch,
  }) async {
    await _flutterTts.setLanguage(languageCode);
    await _flutterTts.setSpeechRate(speechRate);
    await _flutterTts.setPitch(pitch);
    await _flutterTts.speak(text);
  }

  Future<void> pause() async => _flutterTts.pause();
  Future<void> stop() async => _flutterTts.stop();
}
