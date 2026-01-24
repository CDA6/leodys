import '../repositories/network_status_repository.dart';

/// Cas métier simple permettant de connaître
/// l’état actuel de la connexion réseau.
class IsNetworkAvailableUsecase {

  final NetworkStatusRepository repository;

  IsNetworkAvailableUsecase(this.repository);

  Future<bool> execute() {
    return repository.isConnected();
  }
}
