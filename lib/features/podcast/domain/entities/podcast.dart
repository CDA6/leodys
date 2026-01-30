
class Podcast {
  final String id;
  final String title;
  final String genre;
  final String rssUrl;
  final String imageUrl;

  const Podcast({
    required this.id,
    required this.title,
    required this.genre,
    required this.rssUrl,
    this.imageUrl = '',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Podcast &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          genre == other.genre &&
          rssUrl == other.rssUrl &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      genre.hashCode ^
      rssUrl.hashCode ^
      imageUrl.hashCode;

  @override
  String toString() =>
      'Podcast(id: $id, title: $title, genre: $genre, rssUrl: $rssUrl)';
}
