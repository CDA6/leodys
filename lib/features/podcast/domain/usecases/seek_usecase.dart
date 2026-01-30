import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/common/mixins/usecase_mixin.dart';
import '../repositories/audio_repository.dart';


class SeekUseCase with UseCaseMixin<void, Duration> {
  final AudioRepository repository;

  SeekUseCase(this.repository);

  @override
  Future<Either<Failure, void>> execute(Duration position) async {
    return await repository.seek(position);
  }
}
