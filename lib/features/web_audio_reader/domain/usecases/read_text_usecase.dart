import '../entities/reader_config.dart';
import '../repositories/tts_repository.dart';

class ReadTextUseCase {
  final TtsRepository repository;

  ReadTextUseCase(this.repository);

  Future<void> execute(String text, ReaderConfig config) {
    return repository.speak(text, config);
  }

  Future<void> pause() => repository.pause();
  Future<void> stop() => repository.stop();
}
