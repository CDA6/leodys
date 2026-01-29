import '../entities/reader_config.dart';

abstract class TtsRepository {
  Future<void> speak(String text, ReaderConfig config);
  Future<void> pause();
  Future<void> stop();
}
