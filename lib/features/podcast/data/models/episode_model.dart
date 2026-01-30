import '../../domain/entities/episode.dart';

// dto : objet temporaire pour le parsing
class EpisodeModel {
  final String title;
  final String? mp3Url;
  final String? imageUrl;
  final String? durationRaw; // durée en texte (xml)

  const EpisodeModel({
    required this.title,
    this.mp3Url,
    this.imageUrl,
    this.durationRaw,
  });

//mapping
  Episode toEntity() {
    return Episode(
      title: title,
      mp3Url: mp3Url,
      imageUrl: imageUrl,
      duration: _parseDuration(durationRaw),
    );
  }

  // transforme le bordel du rss en objet duration dart
  Duration? _parseDuration(String? raw) {
    if (raw == null || raw.isEmpty) return null;

    // cas "3600" (secondes)
    if (!raw.contains(':')) {
      final seconds = int.tryParse(raw);
      return seconds != null ? Duration(seconds: seconds) : null;
    }

    // cas "01:30:00" ou "45:00"
    final parts = raw.split(':').map(int.tryParse).toList();
    if (parts.any((p) => p == null)) return null;
    final validParts = parts.whereType<int>().toList();

    if (validParts.length == 3) {
      return Duration(hours: validParts[0], minutes: validParts[1], seconds: validParts[2]);
    } else if (validParts.length == 2) {
      return Duration(minutes: validParts[0], seconds: validParts[1]);
    }
    return null;
  }
}