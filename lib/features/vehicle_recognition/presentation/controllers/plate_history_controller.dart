import 'package:flutter/foundation.dart';
import '../../domain/models/plate_scan.dart';
import '../../domain/repositories/plate_history_repository.dart';

/// Controller chargé de gérer l’historique
/// des reconnaissances de plaques réussies.
///
/// Il expose un état simple à l’UI
/// et délègue toute la logique au repositories.
class PlateHistoryController extends ChangeNotifier {

  final PlateHistoryRepository repository;

  // Vriables privées
  List<PlateScan> _history = [];
  bool _isLoading = false;

  // getters
  List<PlateScan> get history => _history;
  bool get isLoading => _isLoading;

  PlateHistoryController(this.repository);

  /// Charge l’ensemble des scans de plaques enregistrés.
  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    _history = await repository.getAllPlateScans();

    _isLoading = false;
    notifyListeners();
  }

  /// Supprime un scan de l’historique à partir de la plaque.
  Future<void> deleteByPlate(String plate) async {
    await repository.deletePlateScan(plate);
    await loadHistory();
  }

  /// Recharge un scan précis à partir de la plaque.
  ///
  /// Utile si tu veux afficher un détail.
  Future<PlateScan?> getByPlate(String plate) {
    return repository.getByPlate(plate);
  }

  /// Vide l’état local (sans toucher au stockage).
  ///
  /// Utile lors d’un changement d’écran ou logout.
  void clearLocal() {
    _history = [];
    notifyListeners();
  }
}
