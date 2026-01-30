import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/common/mixins/usecase_mixin.dart';
import 'package:leodys/common/utils/no_params.dart';
import '../entities/podcast.dart';
import '../repositories/podcast_repository.dart';


class GetLocalPodcastsUseCase with UseCaseMixin<List<Podcast>, NoParams> {
  final PodcastRepository repository;

  GetLocalPodcastsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Podcast>>> execute(NoParams params) async {
    return await repository.getLocalPodcasts();
  }
}
