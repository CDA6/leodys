import 'package:hive/hive.dart';
import '../../domain/entities/podcast.dart';

// modèle persistant avec annotations hive
@HiveType(typeId: 10) // id unique pour pas mélanger avec d'autres types
class PodcastModel extends HiveObject {
  @HiveField(0) final String title;
  @HiveField(1) final String genre;
  @HiveField(2) final String rssUrl;
  @HiveField(3) final String imageUrl;

  PodcastModel({
    required this.title,
    required this.genre,
    required this.rssUrl,
    this.imageUrl = '',
  });

  // mapping vers le domaine (utilisé par l'ui)
  Podcast toEntity(String id) {
    return Podcast(
      id: id,
      title: title,
      genre: genre,
      rssUrl: rssUrl,
      imageUrl: imageUrl,
    );
  }

  // transformation inverse pour la sauvegarde
  factory PodcastModel.fromEntity(Podcast entity) {
    return PodcastModel(
      title: entity.title,
      genre: entity.genre,
      rssUrl: entity.rssUrl,
      imageUrl: entity.imageUrl,
    );
  }
}

// l'adaptateur : le traducteur binaire pour hive
class PodcastModelAdapter extends TypeAdapter<PodcastModel> {
  @override final int typeId = 10;

  @override
  PodcastModel read(BinaryReader reader) {
    return PodcastModel(
      title: reader.readString(),
      genre: reader.readString(),
      rssUrl: reader.readString(),
      imageUrl: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, PodcastModel obj) {
    writer.writeString(obj.title);
    writer.writeString(obj.genre);
    writer.writeString(obj.rssUrl);
    writer.writeString(obj.imageUrl);
  }
}