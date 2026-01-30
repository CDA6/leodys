import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/common/mixins/usecase_mixin.dart';
import '../entities/episode.dart';
import '../repositories/podcast_repository.dart';


class GetEpisodesUseCase with UseCaseMixin<List<Episode>, String> {
  final PodcastRepository repository;

  GetEpisodesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Episode>>> execute(String rssUrl) async {
    return await repository.getEpisodes(rssUrl);
  }
}
