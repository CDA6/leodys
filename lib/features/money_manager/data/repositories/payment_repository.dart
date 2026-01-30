import 'package:hive/hive.dart';
import '../../domain/models/payment_transaction.dart';

/// Repository pour gérer la persistance des transactions de paiement
class PaymentRepository {
  static const String _boxName = 'payment_transactions';
  Box<PaymentTransaction>? _box;

  /// Initialise la box Hive
  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<PaymentTransaction>(_boxName);
    }
  }

  /// Sauvegarde une transaction
  Future<void> saveTransaction(PaymentTransaction transaction) async {
    await init();
    await _box!.put(transaction.id, transaction);
  }

  /// Récupère toutes les transactions
  Future<List<PaymentTransaction>> getAllTransactions() async {
    await init();
    return _box!.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Tri par date décroissante
  }

  /// Supprime toutes les transactions
  Future<void> clearAll() async {
    await init();
    await _box!.clear();
  }

  /// Ferme la box
  Future<void> close() async {
    await _box?.close();
  }
}