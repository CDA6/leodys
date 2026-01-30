import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/common/mixins/usecase_mixin.dart';
import '../repositories/audio_repository.dart';


class PlayEpisodeParams {
  final String url;
  final String title;
  final String? imageUrl;

  const PlayEpisodeParams({
    required this.url,
    required this.title,
    this.imageUrl,
  });

  @override
  String toString() => 'PlayEpisodeParams(title: $title, url: $url)';
}


class PlayEpisodeUseCase with UseCaseMixin<void, PlayEpisodeParams> {
  final AudioRepository repository;

  PlayEpisodeUseCase(this.repository);

  @override
  Future<Either<Failure, void>> execute(PlayEpisodeParams params) async {
    return await repository.playEpisode(
      url: params.url,
      title: params.title,
      imageUrl: params.imageUrl,
    );
  }
}
