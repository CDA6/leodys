import '../../domain/entities/reader_config.dart';
import '../../domain/usecases/read_text_usecase.dart';
import '../../domain/usecases/read_webpage_usecase.dart';

class WebReaderController {
  final ReadWebPageUseCase readWebPageUseCase;
  final ReadTextUseCase readTextUseCase;

  bool _isReading = false;
  bool get isReading => _isReading;

  WebReaderController({
    required this.readWebPageUseCase,
    required this.readTextUseCase,
  });

  Future<void> readText(String text, ReaderConfig config) async {
    _isReading = true;
    await readTextUseCase.execute(text, config);
    _isReading = false;
  }

  void pauseReading() {
    readTextUseCase.pause();
    _isReading = false;
  }

  void stopReading() {
    readTextUseCase.stop();
    _isReading = false;
  }
}
