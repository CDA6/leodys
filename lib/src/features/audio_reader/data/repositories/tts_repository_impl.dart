

import 'package:leodys/src/features/audio_reader/data/services/tts_service_imp.dart';
import 'package:leodys/src/features/audio_reader/domain/models/reader_config.dart';

import '../../domain/repositories/tts_repository.dart';

class TtsRepositoryImpl implements TtsRepository{

  final TtsServiceImpl _ttsService;

  TtsRepositoryImpl(this._ttsService);

  @override
  Future<void> speak(String text, ReaderConfig config) async{
    await _ttsService.speak(
        text: text,
        speechRate: config.speechRate,
        pitch: config.pitch,
      languageCode: config.languageCode,
    );
  }

  @override
  Future<void> pause() async{
    await _ttsService.pause();
  }

  @override
  Future<void> resume(String text, ReaderConfig config) async{
    await _ttsService.speak(
      text: text,
      speechRate: config.speechRate,
      pitch: config.pitch,
      languageCode: config.languageCode,
    );
  }

  @override
  Future<void> stop() async {
    await _ttsService.stop();
  }

}