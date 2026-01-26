import 'package:dartz/dartz.dart';
import '../errors/failures.dart';
import '../utils/app_logger.dart';

mixin UseCaseMixin<Type, Params> {

  /// Exécute le use case avec logging automatique.
  ///
  /// Cette méthode est appelée automatiquement quand vous utilisez
  /// le use case comme une fonction : `myUseCase(params)`
  ///
  /// Ne surchargez JAMAIS cette méthode. Implémentez [execute] à la place.
  Future<Either<Failure, Type>> call(Params params) async {
    final useCaseName = runtimeType.toString();

    AppLogger().trace('[$useCaseName] Entrée - params: $params');

    try {
      final result = await execute(params);

      result.fold(
            (failure) => AppLogger().trace('[$useCaseName] Sortie - Échec: $failure'),
            (success) => AppLogger().trace('[$useCaseName] Sortie - Succès: $success'),
      );

      return result;
    } catch (e, stackTrace) {
      AppLogger().error('[$useCaseName] Exception non gérée: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Implémente la logique métier du use case.
  ///
  /// Cette méthode DOIT être implémentée par toutes les classes filles.
  ///
  /// [params] Les paramètres nécessaires à l'exécution du use case.
  ///
  /// Retourne :
  /// - [Right] avec le résultat en cas de succès
  /// - [Left] avec un [Failure] en cas d'erreur métier
  Future<Either<Failure, Type>> execute(Params params);
}