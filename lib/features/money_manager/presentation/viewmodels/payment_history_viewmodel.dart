import 'package:flutter/material.dart';
import '../../domain/models/payment_transaction.dart';
import '../../data/repositories/payment_repository.dart';

/// ViewModel pour l'historique des paiements
class PaymentHistoryViewModel extends ChangeNotifier {
  final PaymentRepository _repository;
  List<PaymentTransaction> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  PaymentHistoryViewModel(this._repository);

  List<PaymentTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasTransactions => _transactions.isNotEmpty;

  /// Charge l'historique des transactions
  Future<void> loadTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await _repository.getAllTransactions();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement de l\'historique';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  /// Efface tout l'historique
  Future<void> clearAll() async {
    await _repository.clearAll();
    _transactions = [];
    notifyListeners();
  }
}