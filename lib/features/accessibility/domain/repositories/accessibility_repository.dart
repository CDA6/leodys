import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';

import 'package:leodys/features/accessibility/domain/entities/settings.dart';

abstract class AccessibilityRepository {
  Future<Either<Failure, Settings>> getSettings();
  Future<Either<Failure, void>> saveSettings(Settings settings);
  Future<Either<Failure, void>> resetSettings();
}