import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/common/mixins/repository_mixin.dart';
import '../../domain/entities/episode.dart';
import '../../domain/entities/podcast.dart';
import '../../domain/repositories/podcast_repository.dart';
import '../datasources/podcast_local_datasource.dart';
import '../datasources/rss_remote_datasource.dart';
import '../models/podcast_model.dart';

// implémentation qui coordonne le local et le web
class PodcastRepositoryImpl with RepositoryMixin implements PodcastRepository {
  final PodcastLocalDataSource localDataSource;
  final RssRemoteDataSource remoteDataSource;

  PodcastRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<Podcast>>> getLocalPodcasts() async {
    try {
      // 1. On essaie de récupérer les données
      final models = await localDataSource.getAllPodcasts();
      final entities = models.map((m) => m.toEntity(localDataSource.getKey(m).toString())).toList();

      return Right(entities);
    } catch (e) {

      return Left(CacheFailure('Erreur locale : $e'));
    }
  }

  @override
  Future<Either<Failure, List<Podcast>>> getPodcastsByGenre(String genre) async {
    try {
      final models = await localDataSource.getPodcastsByGenre(genre);
      final entities = models.map((m) => m.toEntity(localDataSource.getKey(m).toString())).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erreur filtre genre : $e'));
    }
  }

  @override
  Future<Either<Failure, Podcast>> addPodcast({required String title, required String genre, required String rssUrl, String imageUrl = ''}) async {
    try {
      final model = PodcastModel(title: title, genre: genre, rssUrl: rssUrl, imageUrl: imageUrl);
      final saved = await localDataSource.addPodcast(model);

      return Right(saved.toEntity(localDataSource.getKey(saved).toString()));
    } catch (e) {

      return Left(CacheFailure('Erreur ajout : $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePodcast(String id) async {
    try {
      final key = int.tryParse(id) ?? id;
      await localDataSource.deletePodcast(key);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erreur suppression : $e'));
    }
  }

  @override
  Future<Either<Failure, List<Episode>>> getEpisodes(String rssUrl) async {
    try {
      final models = await remoteDataSource.fetchEpisodes(rssUrl);
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(NetworkFailure('Erreur internet : $e'));
    }
  }
}