import '../../domain/entities/reader_config.dart';
import '../../domain/repositories/tts_repository.dart';
import '../services/tts_service.dart';

class TtsRepositoryImpl implements TtsRepository {
  final TtsService _ttsService;

  TtsRepositoryImpl(this._ttsService);

  @override
  Future<void> speak(String text, ReaderConfig config) async {
    await _ttsService.speak(
      text: text,
      languageCode: config.languageCode,
      speechRate: config.speechRate,
      pitch: config.pitch,
    );
  }

  @override
  Future<void> pause() => _ttsService.pause();

  @override
  Future<void> stop() => _ttsService.stop();
}
