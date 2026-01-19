import 'package:leodys/src/features/audio_reader/domain/models/reader_config.dart';
import 'package:leodys/src/features/audio_reader/domain/repositories/tts_repository.dart';

/// Cas d'usage:
/// L'utilisateur souhaite lancer une lecture audio d'un document déjà scanné
/// et traité par le systeme
class ReadTextUseCase {
  final TtsRepository ttsRepository;

  ReadTextUseCase(this.ttsRepository);

  /// Lance la lecture audio du texte fourni
  /// en utilisant la configuration donnée.
  Future<void> execute(String text, ReaderConfig config) {
    return ttsRepository.speak(text, config);
  }

  /// Mettre en pause la lecture audio
  Future<void> pause() {
    return ttsRepository.pause();
  }

  /// Reprise de la lecture
  Future<void> resume(String text, ReaderConfig config) {
    return ttsRepository.resume(text, config);
  }

  /// Arreter completement la lecture en cours
  Future<void> stop() {
    return ttsRepository.stop();
  }
}
