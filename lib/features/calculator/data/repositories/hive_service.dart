import 'package:hive/hive.dart';

/// Classe pour sauvegarder et récupérer l'historique de la calculette
class HiveService {
  // Box de string pour historique
  late Box<String> _historyBox;

  /// Constructeur qui récupère la box
  HiveService() {
    _historyBox = Hive.box('calculator_history');
  }

  /// Sauvegarde une entrée dans l'historique
  Future<void> saveEntry(String entry) async {
    await _historyBox.add(entry);
  }

  /// Récupère les entrées de l'historique
  List<String> getEntries() {
    return _historyBox.values.toList();
  }

  /// Vide l'historique
  Future<void> clearHistory() async {
    await _historyBox.clear();
  }
}