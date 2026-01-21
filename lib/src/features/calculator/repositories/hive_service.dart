import 'package:hive_ce/hive_ce.dart';

/// Classe pour sauvegarder et récupérer l'historique de la calculette
/// Note: La box doit être ouverte AVANT la création de ce service (dans calculator_view.dart)
class HiveService {
  // Box de liste de string pour historique
  // Calcul complet + version speech
  late Box<String> _historyBox;

  /// Constructeur qui récupère la box
  HiveService() {
    _historyBox = Hive.box('calculator_history');
  }

  /// Sauvegarde une nouvelle entrée dans l'historique
  Future<void> saveEntry(String entry) async {
    await _historyBox.add(entry);
  }

  /// Récupère les entrées de l'historique
  List<String> getEntries() {
    return _historyBox.values.toList();
  }
}