/// Contrat permettant de connaître l’état de la connexion réseau.
/// (Wi-Fi, mobile, plugin, mock, etc.).
abstract class NetworkStatusRepository {

  /// Indique si une connexion est actuellement valable
  Future<bool> isConnected();

  /// Stream émettant un événement à chaque changement de connectivité.
  Stream<bool> onConnectionChanged();
}
