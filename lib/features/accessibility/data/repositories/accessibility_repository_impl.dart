import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:leodys/features/accessibility/data/models/settings_model.dart';

import '../../../../common/errors/failures.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/accessibility_repository.dart';
import '../datasources/local_storage_datasource.dart';

class AccessibilityRepositoryImpl implements AccessibilityRepository {
  final LocalStorageDatasource localStorageDatasource;

  AccessibilityRepositoryImpl(this.localStorageDatasource);

  @override
  Future<Either<Failure, Settings>> getSettings() async {
    try {
      final model = await localStorageDatasource.getSettings();
      return Right(model?.toEntity() ?? const Settings());
    } on HiveError catch (e) {
      return Left(CacheFailure('Erreur de lecture: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSettings(Settings settings) async {
    try {
      final model = SettingsModel.fromEntity(settings);
      await localStorageDatasource.saveSettings(model);
      return const Right(null);
    } on HiveError catch (e) {
      return Left(CacheFailure('Erreur de lecture: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resetSettings() async {
    try {
      await localStorageDatasource.deleteSettings();
      return const Right(null);
    } on HiveError catch (e) {
      return Left(CacheFailure('Erreur de lecture: $e'));
    }
  }
}