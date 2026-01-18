import '../utils/app_logger.dart';

mixin class DataSourceMixin<T> {
  String get _sourceName => runtimeType.toString();

  /// Exécute une opération de datasource avec logging automatique.
  ///
  /// Utilisez cette méthode pour wrapper toutes vos opérations.
  ///
  /// [methodName] Le nom de la méthode pour le logging (ex: 'getUser').
  /// [method] La fonction contenant l'appel API/BDD.
  /// [params] Les paramètres de la méthode.
  ///
  /// Retourne le résultat ou relance les exceptions.
  Future<T> execute<P extends Object>(
      String methodName,
      P params,
      Future<T> Function(P) method)
  async {
    AppLogger().trace('[$_sourceName.$methodName] Entrée - params: $params');

    try {
      final result = await method(params);
      AppLogger().trace('[$_sourceName.$methodName] Sortie - Succès');
      return result;
    } catch (e, stackTrace) {
      AppLogger().error('[$_sourceName.$methodName] Erreur: $e', stackTrace);
      rethrow;
    }
  }
}