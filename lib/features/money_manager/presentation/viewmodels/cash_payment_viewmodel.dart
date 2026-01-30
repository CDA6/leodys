import 'package:flutter/material.dart';
import '../../domain/models/cash_payment_state.dart';
import '../../domain/usecases/calculate_optimal_change_usecase.dart';
import '../../domain/usecases/skip_denomination_usecase.dart';
import '../../domain/usecases/add_user_denomination_usecase.dart';

/// ViewModel pour gérer le processus de paiement en liquide
class CashPaymentViewModel extends ChangeNotifier {
  final CalculateOptimalChangeUseCase _calculateOptimalChangeUseCase;
  final SkipDenominationUseCase _skipDenominationUseCase;
  final AddUserDenominationUseCase _addUserDenominationUseCase;
  CashPaymentState? _state;

  CashPaymentViewModel({
    CalculateOptimalChangeUseCase? calculateOptimalChangeUseCase,
    SkipDenominationUseCase? skipDenominationUseCase,
    AddUserDenominationUseCase? addUserDenominationUseCase,
  })  : _calculateOptimalChangeUseCase = calculateOptimalChangeUseCase ?? CalculateOptimalChangeUseCase(),
        _skipDenominationUseCase = skipDenominationUseCase ?? SkipDenominationUseCase(),
        _addUserDenominationUseCase = addUserDenominationUseCase ?? AddUserDenominationUseCase();

  CashPaymentState? get state => _state;
  bool get isInitialized => _state != null;
  bool get isComplete => _state?.isComplete ?? false;

  /// Initialise le processus de paiement
  void initializePayment(double amount) {
    _state = _calculateOptimalChangeUseCase.execute(amount);
    notifyListeners();
  }

  /// L'utilisateur ajoute une unité de la dénomination actuelle
  void addDenomination() {
    if (_state == null) return;
    _state = _addUserDenominationUseCase.execute(_state!);
    notifyListeners();
  }

  /// L'utilisateur n'a pas la dénomination actuelle
  void skipDenomination() {
    if (_state == null) return;
    _state = _skipDenominationUseCase.execute(_state!);
    notifyListeners();
  }

  /// Réinitialise le processus
  void reset() {
    _state = null;
    notifyListeners();
  }

  /// Récapitulatif des billets/pièces donnés
  String getSummary() {
    if (_state == null) return '';

    final buffer = StringBuffer();
    for (var denom in _state!.denominations) {
      if (denom.userGiven > 0) {
        buffer.writeln('${denom.type} de ${denom.displayValue} : ${denom.userGiven}');
      }
    }

    if (_state!.changeAmount > 0) {
      buffer.writeln('\nMonnaie à rendre : ${_state!.changeAmount.toStringAsFixed(2)}€');
    }

    return buffer.toString();
  }
}