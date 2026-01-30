import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/common/mixins/usecase_mixin.dart';
import '../repositories/audio_repository.dart';


class SkipForwardUseCase with UseCaseMixin<void, Duration> {
  final AudioRepository repository;

  SkipForwardUseCase(this.repository);

  @override
  Future<Either<Failure, void>> execute(Duration amount) async {
    return await repository.skipForward(amount);
  }
}
