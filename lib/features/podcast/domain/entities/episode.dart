
class Episode {
  final String title;
  final String? mp3Url;
  final String? imageUrl;
  final Duration? duration;

  const Episode({
    required this.title,
    this.mp3Url,
    this.imageUrl,
    this.duration,
  });


  String get formattedDuration {
    if (duration == null) return 'Durée inconnue';

    if (duration!.inHours > 0) {
      return '${duration!.inHours}h ${duration!.inMinutes % 60}';
    }
    return '${duration!.inMinutes} min';
  }

  bool get isPlayable => mp3Url != null && mp3Url!.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Episode &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          mp3Url == other.mp3Url &&
          imageUrl == other.imageUrl &&
          duration == other.duration;

  @override
  int get hashCode =>
      title.hashCode ^ mp3Url.hashCode ^ imageUrl.hashCode ^ duration.hashCode;

  @override
  String toString() =>
      'Episode(title: $title, mp3Url: $mp3Url, duration: $duration)';
}
