import 'package:flutter/foundation.dart';
import 'package:leodys/common/utils/no_params.dart';
import '../../domain/entities/podcast.dart';
import '../../domain/usecases/add_podcast_usecase.dart';
import '../../domain/usecases/get_local_podcasts_usecase.dart';

// ViewModel pour l'écran d'accueil des podcasts.
class PodcastHomeViewModel extends ChangeNotifier {
  final GetLocalPodcastsUseCase getLocalPodcastsUseCase;
  final AddPodcastUseCase addPodcastUseCase;

  List<Podcast> _podcasts = [];
  bool _isLoading = false;
  String? _errorMessage;

  PodcastHomeViewModel({
    required this.getLocalPodcastsUseCase,
    required this.addPodcastUseCase,
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

    final result = await getLocalPodcastsUseCase(const NoParams());

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

  // Ajoute un nouveau podcast personnalisé.
  Future<bool> addPodcast({
    required String title,
    required String rssUrl,
  }) async {
    final result = await addPodcastUseCase(
      AddPodcastParams(
        title: title,
        genre: 'Autre',
        rssUrl: rssUrl,
        imageUrl: '',
      ),
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        loadPodcasts();
        return true;
      },
    );
  }
}
