import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import '../entities/episode.dart';
import '../entities/podcast.dart';

abstract class PodcastRepository {

  Future<Either<Failure, List<Podcast>>> getLocalPodcasts();

  Future<Either<Failure, List<Podcast>>> getPodcastsByGenre(String genre);

  Future<Either<Failure, Podcast>> addPodcast({
    required String title,
    required String genre,
    required String rssUrl,
    String imageUrl = '',
  });

  Future<Either<Failure, void>> deletePodcast(String id);


  Future<Either<Failure, List<Episode>>> getEpisodes(String rssUrl);
}
