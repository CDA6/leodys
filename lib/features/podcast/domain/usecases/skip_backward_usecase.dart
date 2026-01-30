import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/common/mixins/usecase_mixin.dart';
import '../repositories/audio_repository.dart';


class SkipBackwardUseCase with UseCaseMixin<void, Duration> {
  final AudioRepository repository;

  SkipBackwardUseCase(this.repository);

  @override
  Future<Either<Failure, void>> execute(Duration amount) async {
    return await repository.skipBackward(amount);
  }
}
