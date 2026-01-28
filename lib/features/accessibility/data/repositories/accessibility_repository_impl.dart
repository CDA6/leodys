import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';

import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/common/mixins/repository_mixin.dart';
import 'package:leodys/features/accessibility/domain/entities/settings.dart';
import 'package:leodys/features/accessibility/domain/repositories/accessibility_repository.dart';
import 'package:leodys/features/accessibility/data/datasources/local_storage_datasource.dart';
import 'package:leodys/features/accessibility/data/models/settings_model.dart';

class AccessibilityRepositoryImpl with RepositoryMixin implements AccessibilityRepository {
  final LocalStorageDatasource localStorageDatasource;

  AccessibilityRepositoryImpl(this.localStorageDatasource);

  @override
  Future<Either<Failure, Settings>> getSettings() async {
    return execute('getSettings', () async {
      try {
        final model = await localStorageDatasource.getSettings();
        return Right(model?.toEntity() ?? const Settings());
      } on HiveError catch (e) {
        return Left(CacheFailure('Erreur de lecture: $e'));
      }
    });
  }

  @override
  Future<Either<Failure, void>> saveSettings(Settings settings) async {
    return execute('saveSettings', () async {
      try {
        final model = SettingsModel.fromEntity(settings);
        await localStorageDatasource.saveSettings(model);
        return const Right(null);
      } on HiveError catch (e) {
        return Left(CacheFailure('Erreur de lecture: $e'));
      }
    });
  }

  @override
  Future<Either<Failure, void>> resetSettings() async {
    return execute('resetSettings', () async {
      try {
        await localStorageDatasource.deleteSettings();
        return const Right(null);
      } on HiveError catch (e) {
        return Left(CacheFailure('Erreur de lecture: $e'));
      }
    });
  }
}