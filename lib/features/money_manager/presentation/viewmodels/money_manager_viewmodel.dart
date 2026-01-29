import 'package:flutter/material.dart';
import '../../domain/models/payment_method.dart';
import '../../domain/models/payment_transaction.dart';
import '../../data/repositories/payment_repository.dart';

/// ViewModel principal
class MoneyManagerViewModel extends ChangeNotifier {
  final PaymentRepository _repository;

  String _amountInput = '';
  PaymentMethod? _selectedMethod;

  MoneyManagerViewModel(this._repository);

  // Getters
  String get amountInput => _amountInput;
  PaymentMethod? get selectedMethod => _selectedMethod;

  double? get amount {
    try {
      return double.parse(_amountInput.replaceAll(',', '.'));
    } catch (e) {
      return null;
    }
  }

  bool get isValid {
    final amt = amount;
    return amt != null && amt > 0 && _selectedMethod != null;
  }

  // Setters
  void setAmount(String value) {
    _amountInput = value;
    notifyListeners();
  }

  void setPaymentMethod(PaymentMethod method) {
    _selectedMethod = method;
    notifyListeners();
  }

  void reset() {
    _amountInput = '';
    _selectedMethod = null;
    notifyListeners();
  }

  /// Sauvegarde une transaction
  Future<void> saveTransaction({
    required double amount,
    required PaymentMethod method,
    required bool isSuccess,
    String? details,
  }) async {
    final transaction = PaymentTransaction.create(
      amount: amount,
      paymentMethod: method,
      isSuccess: isSuccess,
      details: details,
    );
    await _repository.saveTransaction(transaction);
  }
}