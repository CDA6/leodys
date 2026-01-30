import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/common/mixins/usecase_mixin.dart';
import 'package:leodys/common/utils/no_params.dart';
import '../repositories/audio_repository.dart';


class PauseResumeUseCase with UseCaseMixin<void, NoParams> {
  final AudioRepository repository;

  PauseResumeUseCase(this.repository);

  @override
  Future<Either<Failure, void>> execute(NoParams params) async {
    return await repository.pauseResume();
  }
}
