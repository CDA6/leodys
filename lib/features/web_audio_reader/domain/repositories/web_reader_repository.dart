abstract class WebReaderRepository {
  /// Returns clean readable text from a webpage
  Future<String> getReadableText(String url);
}