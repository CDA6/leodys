import 'package:dartz/dartz.dart';
import 'package:leodys/features/accessibility/domain/entities/settings.dart';

import '../../../../common/errors/failures.dart';
import '../../../../common/mixins/usecase_mixin.dart';
import '../../../../common/utils/no_params.dart';
import '../repositories/accessibility_repository.dart';

class ResetSettingsUseCase with UseCaseMixin<void, NoParams>{
  final AccessibilityRepository repository;

  ResetSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> execute(NoParams params) async {
    return await repository.resetSettings();
  }
}