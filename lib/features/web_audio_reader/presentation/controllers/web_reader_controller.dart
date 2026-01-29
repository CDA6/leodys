import '../../domain/entities/reader_config.dart';
import '../../domain/usecases/read_text_usecase.dart';
import '../../domain/usecases/read_webpage_usecase.dart';

class WebReaderController {
  final ReadWebPageUseCase readWebPageUseCase;
  final ReadTextUseCase readTextUseCase;

  bool _isReading = false;
  bool get isReading => _isReading;

  int _currentChunkIndex = 0;
  List<String> _chunks = [];

  WebReaderController({
    required this.readWebPageUseCase,
    required this.readTextUseCase,
  });

  Future<void> readWebsite(
      String url,
      ReaderConfig config, {
        void Function()? onReadingComplete,
      }) async {
    _chunks.clear();
    _currentChunkIndex = 0;

    String text = await readWebPageUseCase.execute(url);
    _chunks = _splitTextIntoChunks(text);

    _isReading = true;
    _readNextChunk(config, onReadingComplete);
  }

  void _readNextChunk(
      ReaderConfig config, void Function()? onReadingComplete) {
    if (!_isReading || _currentChunkIndex >= _chunks.length) {
      _isReading = false;
      if (onReadingComplete != null) onReadingComplete();
      return;
    }

    String chunk = _chunks[_currentChunkIndex];
    _currentChunkIndex++;

    readTextUseCase.execute(chunk, config).then((_) {
      _readNextChunk(config, onReadingComplete);
    });
  }

  void pauseReading() {
    readTextUseCase.pause();
    _isReading = false;
  }

  void stopReading() {
    readTextUseCase.stop();
    _isReading = false;
    _currentChunkIndex = _chunks.length;
  }

  List<String> _splitTextIntoChunks(String text, [int size = 3500]) {
    List<String> chunks = [];
    for (int i = 0; i < text.length; i += size) {
      chunks.add(text.substring(i, (i + size > text.length) ? text.length : i + size));
    }
    return chunks;
  }
}
