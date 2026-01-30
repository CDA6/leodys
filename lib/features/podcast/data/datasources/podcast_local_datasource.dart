import 'package:hive/hive.dart';
import '../models/podcast_model.dart';

// interface : contrat pour le stockage (facilite les tests)
abstract interface class PodcastLocalDataSource {
  Future<List<PodcastModel>> getAllPodcasts();
  Future<List<PodcastModel>> getPodcastsByGenre(String genre);
  Future<PodcastModel> addPodcast(PodcastModel model);
  Future<void> deletePodcast(dynamic key);
  Future<void> seedInitialData(List<PodcastModel> podcasts);
  dynamic getKey(PodcastModel model);
}

class PodcastLocalDataSourceImpl implements PodcastLocalDataSource {
  final Box<PodcastModel> _box;
  PodcastLocalDataSourceImpl(this._box);


  @override
  Future<List<PodcastModel>> getAllPodcasts() async {
    return _box.values.toList();
  }


  @override
  Future<List<PodcastModel>> getPodcastsByGenre(String genre) async {
    return _box.values.where((p) => p.genre == genre).toList();
  }


  @override
  Future<PodcastModel> addPodcast(PodcastModel model) async {
    await _box.add(model);
    return model;
  }


  @override
  Future<void> deletePodcast(dynamic key) async {
    await _box.delete(key);
  }


  @override
  Future<void> seedInitialData(List<PodcastModel> podcasts) async {
    if (_box.isEmpty) {
      await _box.addAll(podcasts);
    }
  }


  @override
  dynamic getKey(PodcastModel model) => model.key;
}