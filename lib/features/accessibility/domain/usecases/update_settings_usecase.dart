import 'package:dartz/dartz.dart';
import 'package:leodys/common/mixins/usecase_mixin.dart';

import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/features/accessibility/domain/entities/settings.dart';
import 'package:leodys/features/accessibility/domain/repositories/accessibility_repository.dart';

class UpdateSettingsUseCase with UseCaseMixin<void, Settings> {
  final AccessibilityRepository repository;

  UpdateSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> execute(Settings settings) async {
    return await repository.saveSettings(settings);
  }
}