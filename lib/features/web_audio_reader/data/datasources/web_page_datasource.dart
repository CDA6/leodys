import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

class WebPageDataSource {
  Future<String> fetchAndParse(String url) async {
    final response = await http.get(Uri.parse(url));
    final document = parse(response.body);

    final main = document.querySelector('[role="main"]') ??
        document.querySelector('main') ??
        document.querySelector('article') ??
        document.body;

    return main?.text.trim() ?? "";
  }
}
