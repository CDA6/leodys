import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/repositories/network_status_repository.dart';

/// Implémentation concrète du repository réseau
/// basée sur le plugin connectivity_plus.
class NetworkStatusRepositoryImpl implements NetworkStatusRepository {

  final Connectivity _connectivity = Connectivity();

  @override
  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  @override
  Stream<bool> onConnectionChanged() {
    return _connectivity.onConnectivityChanged.map(
          (result) => result != ConnectivityResult.none,
    );
  }
}
