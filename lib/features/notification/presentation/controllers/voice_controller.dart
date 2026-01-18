import 'package:speech_to_text/speech_to_text.dart';

import '../../../../common/utils/platform_util.dart';

class VoiceController {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;

  Future<bool> initSpeech() async {
    if (PlatformUtil.isWindows) {
      try {
        return await _speech.initialize();
      } catch (e) {
        print("Erreur d'initialisation Voice sur Windows: $e");
        return false;
      }
    }
    return await _speech.initialize();
  }

  void startListening(Function(String) onResult) async {
    if (!_isListening) {
      await _speech.listen(onResult: (result) {
        onResult(result.recognizedWords);
      });
      _isListening = true;
    }
  }

  void stopListening() async {
    await _speech.stop();
    _isListening = false;
  }

  bool get isListening => _isListening;
}