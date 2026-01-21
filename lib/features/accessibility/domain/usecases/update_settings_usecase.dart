import 'package:dartz/dartz.dart';
import 'package:leodys/common/mixins/usecase_mixin.dart';

import '../../../../common/errors/failures.dart';
import '../entities/settings.dart';
import '../repositories/accessibility_repository.dart';

class UpdateSettingsUseCase with UseCaseMixin<void, Settings> {
  final AccessibilityRepository repository;

  UpdateSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> execute(Settings settings) async {
    return await repository.saveSettings(settings);
  }
}