import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

// Domain
import 'domain/entities/podcast.dart';
import 'domain/repositories/audio_repository.dart';
import 'domain/repositories/podcast_repository.dart';
import 'domain/usecases/add_podcast_usecase.dart';
import 'domain/usecases/get_episodes_usecase.dart';
import 'domain/usecases/get_local_podcasts_usecase.dart';
import 'domain/usecases/get_podcasts_by_genre_usecase.dart';
import 'domain/usecases/pause_resume_usecase.dart';
import 'domain/usecases/play_episode_usecase.dart';
import 'domain/usecases/seek_usecase.dart';
import 'domain/usecases/skip_backward_usecase.dart';
import 'domain/usecases/skip_forward_usecase.dart';

// Data
import 'data/datasources/podcast_local_datasource.dart';
import 'data/datasources/rss_remote_datasource.dart';
import 'data/models/podcast_model.dart';
import 'data/repositories/audio_repository_impl.dart';
import 'data/repositories/podcast_repository_impl.dart';
import 'data/services/audio_player_service.dart';

// Presentation
import 'presentation/viewmodels/audio_player_viewmodel.dart';
import 'presentation/viewmodels/episode_list_viewmodel.dart';
import 'presentation/viewmodels/podcast_home_viewmodel.dart';
import 'presentation/viewmodels/podcast_list_viewmodel.dart';

final sl = GetIt.instance;

// Données par défaut
final List<PodcastModel> _seedPodcasts = [
  PodcastModel(
    title: 'Affaires Sensibles',
    genre: 'France Inter',
    rssUrl: 'https://radiofrance-podcast.net/podcast09/rss_13940.xml',
    imageUrl: 'https://media.radiofrance-podcast.net/podcast09/13940-20.01.2026-ITEMA_24376595-2026C13940S0020-21.jpg',
  ),
  PodcastModel(
    title: 'La Bande Originale',
    genre: 'France Inter',
    rssUrl: 'https://radiofrance-podcast.net/podcast09/rss_13937.xml',
    imageUrl: 'https://media.radiofrance-podcast.net/podcast09/13937-21.01.2026-ITEMA_24377508-2026C13937S0021-21.jpg',
  ),
  PodcastModel(
    title: 'Les Pieds sur terre',
    genre: 'France Culture',
    rssUrl: 'https://radiofrance-podcast.net/podcast09/rss_10078.xml',
    imageUrl: 'https://media.radiofrance-podcast.net/podcast09/10078-21.01.2026-ITEMA_24377227-2026C10078S0021-21.jpg',
  ),
  PodcastModel(
    title: 'LSD, La série documentaire',
    genre: 'France Culture',
    rssUrl: 'https://radiofrance-podcast.net/podcast09/rss_14310.xml',
    imageUrl: 'https://media.radiofrance-podcast.net/podcast09/14310-21.01.2026-ITEMA_24377230-2026C14310S0021-21.jpg',
  ),
];


Future<void> init() async {

  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(PodcastModelAdapter());
  }


  if (!sl.isRegistered<AudioPlayerService>()) {
    sl.registerLazySingleton<AudioPlayerService>(() {
      final service = AudioPlayerService();
      service.init();
      return service;
    });
  }


  final podcastBox = await Hive.openBox<PodcastModel>('podxa_podcasts');

  sl.registerLazySingleton<PodcastLocalDataSource>(
        () => PodcastLocalDataSourceImpl(podcastBox),
  );

  sl.registerFactory<RssRemoteDataSource>(
        () => RssRemoteDataSourceImpl(client: http.Client()),
  );

  if (podcastBox.isEmpty) {
    await sl<PodcastLocalDataSource>().seedInitialData(_seedPodcasts);
  }
  sl.registerLazySingleton<PodcastRepository>(
        () => PodcastRepositoryImpl(
      localDataSource: sl<PodcastLocalDataSource>(),
      remoteDataSource: sl<RssRemoteDataSource>(),
    ),
  );

  if (!sl.isRegistered<AudioRepository>()) {
    sl.registerLazySingleton<AudioRepository>(
          () => AudioRepositoryImpl(service: sl<AudioPlayerService>()),
    );
  }

  sl.registerLazySingleton(() => GetLocalPodcastsUseCase(sl<PodcastRepository>()));
  sl.registerLazySingleton(() => GetPodcastsByGenreUseCase(sl<PodcastRepository>()));
  sl.registerLazySingleton(() => AddPodcastUseCase(sl<PodcastRepository>()));
  sl.registerLazySingleton(() => GetEpisodesUseCase(sl<PodcastRepository>()));

  sl.registerLazySingleton(() => PlayEpisodeUseCase(sl<AudioRepository>()));
  sl.registerLazySingleton(() => PauseResumeUseCase(sl<AudioRepository>()));
  sl.registerLazySingleton(() => SeekUseCase(sl<AudioRepository>()));
  sl.registerLazySingleton(() => SkipBackwardUseCase(sl<AudioRepository>()));
  sl.registerLazySingleton(() => SkipForwardUseCase(sl<AudioRepository>()));


  sl.registerFactory<PodcastHomeViewModel>(
        () => PodcastHomeViewModel(
      getLocalPodcastsUseCase: sl<GetLocalPodcastsUseCase>(),
      addPodcastUseCase: sl<AddPodcastUseCase>(),
    ),
  );

  sl.registerFactoryParam<PodcastListViewModel, String, void>(
        (genre, _) => PodcastListViewModel(
      getPodcastsByGenreUseCase: sl<GetPodcastsByGenreUseCase>(),
      genre: genre,
    ),
  );

  sl.registerFactoryParam<EpisodeListViewModel, Podcast, void>(
        (podcast, _) => EpisodeListViewModel(
      getEpisodesUseCase: sl<GetEpisodesUseCase>(),
      podcast: podcast,
    ),
  );

  sl.registerLazySingleton<AudioPlayerViewModel>(
        () => AudioPlayerViewModel(audioRepository: sl<AudioRepository>()),
  );
}