import 'package:dartz/dartz.dart';

import '../errors/failures.dart';
import '../utils/app_logger.dart';

mixin RepositoryMixin {
  String get _repositoryName => runtimeType.toString();

  /// Exécute une opération de repository avec logging automatique.
  ///
  /// Utilisez cette méthode pour wrapper toutes vos opérations.
  ///
  /// [methodName] Le nom de la méthode pour le logging (ex: 'getUser').
  /// [operation] La fonction contenant la logique métier.
  ///
  /// Retourne le résultat de l'opération ou relance les exceptions.
  Future<Either<Failure, T>> execute<T>(
      String methodName,
      Future<Either<Failure, T>> Function() operation)
  async {
    AppLogger().trace('[$_repositoryName.$methodName] Entrée');

    try {
      final result = await operation();
      result.fold(
            (failure) => AppLogger().trace('[$_repositoryName.$methodName] Sortie - Échec: $failure'),
            (success) => AppLogger().trace('[$_repositoryName.$methodName] Sortie - Succès'),
      );
      return result;
    } catch (e, stackTrace) {
      AppLogger().error('[$_repositoryName.$methodName] Exception non gérée: $e', stackTrace: stackTrace);
      rethrow;
    }
  }
}