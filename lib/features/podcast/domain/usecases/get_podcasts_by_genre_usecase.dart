import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/common/mixins/usecase_mixin.dart';
import '../entities/podcast.dart';
import '../repositories/podcast_repository.dart';


class GetPodcastsByGenreUseCase with UseCaseMixin<List<Podcast>, String> {
  final PodcastRepository repository;

  GetPodcastsByGenreUseCase(this.repository);

  @override
  Future<Either<Failure, List<Podcast>>> execute(String genre) async {
    return await repository.getPodcastsByGenre(genre);
  }
}
