

import 'package:flutter_tts/flutter_tts.dart';

class TtsServiceImpl{
  /*
  Instance de plugin Flutter de syntese vocale.
  Transforme du texte en audio
   */
  final FlutterTts _flutterTts = FlutterTts();

  /*
  Lance la lecture vocal du texte fourni
  Méthode asynchrone car la lecture vocal est une opération non instantanée
  Cette méthode prendre en parametres un texte et une vitesse de lecture (0.0 à 1.0)
   */
  Future<void> speak(String text, {double speed = 0.5}) async {
    await _flutterTts.setSpeechRate(speed);
    await _flutterTts.speak(text);
  }

  /*
  Mettre en pause la lecture audio en cours
   */
  Future<void> pause() async{
    await _flutterTts.pause();
  }

  /*
  Arrêter complètement la lecture
   */
  Future<void> stop()async{
    await _flutterTts.stop();
  }
}