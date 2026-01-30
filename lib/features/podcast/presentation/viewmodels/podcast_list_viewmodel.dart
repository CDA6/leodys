import 'package:flutter/foundation.dart';
import '../../domain/entities/podcast.dart';
import '../../domain/usecases/get_podcasts_by_genre_usecase.dart';


class PodcastListViewModel extends ChangeNotifier {
  final GetPodcastsByGenreUseCase getPodcastsByGenreUseCase;
  final String genre;

  List<Podcast> _podcasts = [];
  bool _isLoading = false;
  String? _errorMessage;

  PodcastListViewModel({
    required this.getPodcastsByGenreUseCase,
    required this.genre,
  }) {
    loadPodcasts();
  }

  List<Podcast> get podcasts => _podcasts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;


  Future<void> loadPodcasts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getPodcastsByGenreUseCase(genre);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _podcasts = [];
      },
      (podcasts) {
        _podcasts = podcasts;
      },
    );

    _isLoading = false;
    notifyListeners();
  }
}
