import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/episode_model.dart';

// interface : contrat pour la recuperation web
abstract interface class RssRemoteDataSource {
  Future<List<EpisodeModel>> fetchEpisodes(String rssUrl);
}

// implementation : parseur xml via http
class RssRemoteDataSourceImpl implements RssRemoteDataSource {
  final http.Client client;

  RssRemoteDataSourceImpl({http.Client? client})
      : client = client ?? http.Client();

  @override
  Future<List<EpisodeModel>> fetchEpisodes(String rssUrl) async {
    try {
      // 1. appel reseau
      final response = await client.get(Uri.parse(rssUrl));

      if (response.statusCode != 200) {
        throw Exception('erreur http ${response.statusCode}');
      }

      // 2. analyse du document xml
      final document = XmlDocument.parse(response.body);
      final items = document.findAllElements('item'); // chaque <item> est un episode

      // 3. mapping xml -> modele dart
      return items.map((node) {
        return EpisodeModel(
          title: node.findElements('title').firstOrNull?.innerText ?? 'sans titre',
          mp3Url: node.findElements('enclosure').firstOrNull?.getAttribute('url'),
          imageUrl: node.findAllElements('itunes:image').firstOrNull?.getAttribute('href'),
          durationRaw: node.findAllElements('itunes:duration').firstOrNull?.innerText,
        );
      }).toList();

    } catch (e) {
      throw Exception('echec parsing rss : $e');
    }
  }
}