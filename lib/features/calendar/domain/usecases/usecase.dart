/// Interface générique pour tous les Use Cases
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Utilisé quand un Use Case ne prend aucun paramètre
class NoParams {
  const NoParams();
}