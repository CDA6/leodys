import 'package:flutter/foundation.dart';
import '../../domain/entities/episode.dart';
import '../../domain/entities/podcast.dart';
import '../../domain/usecases/get_episodes_usecase.dart';

// ViewModel pour l'écran de liste des épisodes d'un podcast.
class EpisodeListViewModel extends ChangeNotifier {
  final GetEpisodesUseCase getEpisodesUseCase;
  final Podcast podcast;

  List<Episode> _episodes = [];
  bool _isLoading = false;
  String? _errorMessage;

  EpisodeListViewModel({
    required this.getEpisodesUseCase,
    required this.podcast,
  }) {
    loadEpisodes();
  }

  List<Episode> get episodes => _episodes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Charge les épisodes depuis le flux RSS du podcast.
  Future<void> loadEpisodes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getEpisodesUseCase(podcast.rssUrl);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _episodes = [];
      },
      (episodes) {
        _episodes = episodes;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  // Retourne l'URL de l'image pour un épisode.

  String? getImageUrl(Episode episode) {
    if (episode.imageUrl != null && episode.imageUrl!.isNotEmpty) {
      return episode.imageUrl;
    }
    if (podcast.imageUrl.isNotEmpty) {
      return podcast.imageUrl;
    }
    return null;
  }
}
