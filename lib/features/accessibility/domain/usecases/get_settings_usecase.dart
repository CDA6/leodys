import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/common/mixins/usecase_mixin.dart';
import 'package:leodys/common/utils/no_params.dart';

import 'package:leodys/features/accessibility/domain/entities/settings.dart';
import 'package:leodys/features/accessibility/domain/repositories/accessibility_repository.dart';

class GetSettingsUseCase with UseCaseMixin<Settings, NoParams> {
  final AccessibilityRepository repository;

  GetSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, Settings>> execute(NoParams params) async {
    return await repository.getSettings();
  }
}