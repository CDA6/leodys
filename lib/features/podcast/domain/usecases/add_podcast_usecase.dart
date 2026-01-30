import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/common/mixins/usecase_mixin.dart';
import '../entities/podcast.dart';
import '../repositories/podcast_repository.dart';


class AddPodcastParams {
  final String title;
  final String genre;
  final String rssUrl;
  final String imageUrl;

  const AddPodcastParams({
    required this.title,
    required this.genre,
    required this.rssUrl,
    this.imageUrl = '',
  });

  @override
  String toString() =>
      'AddPodcastParams(title: $title, genre: $genre, rssUrl: $rssUrl)';
}


class AddPodcastUseCase with UseCaseMixin<Podcast, AddPodcastParams> {
  final PodcastRepository repository;

  AddPodcastUseCase(this.repository);

  @override
  Future<Either<Failure, Podcast>> execute(AddPodcastParams params) async {
    return await repository.addPodcast(
      title: params.title,
      genre: params.genre,
      rssUrl: params.rssUrl,
      imageUrl: params.imageUrl,
    );
  }
}
