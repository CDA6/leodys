import '../repositories/web_reader_repository.dart';

class ReadWebPageUseCase {
  final WebReaderRepository repository;

  ReadWebPageUseCase(this.repository);

  Future<String> execute(String url) {
    return repository.getReadableText(url);
  }
}
