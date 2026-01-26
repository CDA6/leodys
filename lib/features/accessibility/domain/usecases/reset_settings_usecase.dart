import 'package:dartz/dartz.dart';

import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/common/mixins/usecase_mixin.dart';
import 'package:leodys/common/utils/no_params.dart';
import 'package:leodys/features/accessibility/domain/repositories/accessibility_repository.dart';

class ResetSettingsUseCase with UseCaseMixin<void, NoParams>{
  final AccessibilityRepository repository;

  ResetSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> execute(NoParams params) async {
    return await repository.resetSettings();
  }
}