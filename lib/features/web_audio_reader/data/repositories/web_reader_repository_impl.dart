import '../../domain/repositories/web_reader_repository.dart';
import '../datasources/web_page_datasource.dart';

class WebReaderRepositoryImpl implements WebReaderRepository {
  final WebPageDataSource dataSource;

  WebReaderRepositoryImpl(this.dataSource);

  @override
  Future<String> getReadableText(String url) {
    return dataSource.fetchAndParse(url);
  }
}
