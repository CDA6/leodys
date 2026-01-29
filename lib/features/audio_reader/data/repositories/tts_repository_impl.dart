
import '../../domain/models/reader_config.dart';
import '../../domain/repositories/tts_repository.dart';
import '../services/tts_service.dart';

/// Implémentation du repositories de TTS
/// Relie le Domain (contrat TtsRepository) et le service technique de
/// synthese vocal (TtsServiceImpl)
class TtsRepositoryImpl implements TtsRepository {
  // Appel le plugin flutter_tts
  final TtsService _ttsService;

  // Injection de service TTS via le constructeur
  TtsRepositoryImpl(this._ttsService);

  /// Lance la lecture vocal d'un texte avec la configuration prédéfinie
  @override
  Future<void> speak(String text, ReaderConfig config) async {
    await _ttsService.speak(
      text: text,
      speechRate: config.speechRate,
      pitch: config.pitch,
      languageCode: config.languageCode,
    );
  }

  /// Mettre en pause la lecture
  @override
  Future<void> pause() async {
    await _ttsService.pause();
  }

  /// Reprendre la lecture
  @override
  Future<void> resume(String text, ReaderConfig config) async {
    await _ttsService.speak(
      text: text,
      speechRate: config.speechRate,
      pitch: config.pitch,
      languageCode: config.languageCode,
    );
  }

  /// Arreter la lecture
  @override
  Future<void> stop() async {
    await _ttsService.stop();
  }
}
