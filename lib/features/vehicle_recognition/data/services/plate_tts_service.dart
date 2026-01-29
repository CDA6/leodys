import 'package:flutter_tts/flutter_tts.dart';

class PlateTtsService {


  /// Instance de plugin Flutter de syntese vocale.
  /// Transforme du texte en audio
  final FlutterTts _flutterTts = FlutterTts();

  /// Lance la lecture vocal du texte fourni
  /// Méthode asynchrone car la lecture vocal est une opération non instantanée
  /// Paramètres : texte, langue, vitesse, pitch et voix optionnelle
  Future<void> speak({
    required String text,
    required String languageCode,
    required double speechRate,
    required double pitch,
    String? voiceId,
  }) async {
    // Langue
    await _flutterTts.setLanguage(languageCode);

    // Vitesse (lecture dys-friendly)
    await _flutterTts.setSpeechRate(speechRate);

    // Pitch (meilleure articulation)
    await _flutterTts.setPitch(pitch);

    // Voix spécifique si définie
    if (voiceId != null) {
      await _flutterTts.setVoice({"name": voiceId, "locale": languageCode});
    }

    await _flutterTts.speak(text);
  }

  /// Mettre en pause la lecture audio en cours
  Future<void> pause() async {
    await _flutterTts.pause();
  }

  /// Arrêter complètement la lecture
  Future<void> stop() async {
    await _flutterTts.stop();
  }
}