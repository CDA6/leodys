import 'currency_denomination.dart';

/// Représente l'état du processus de paiement en liquide
class CashPaymentState {
  final double targetAmount;
  final double remainingAmount;
  final double givenAmount;
  final List<CurrencyDenomination> denominations;
  final int currentDenominationIndex;
  final bool isComplete;
  final double changeAmount;

  CashPaymentState({
    required this.targetAmount,
    required this.remainingAmount,
    required this.givenAmount,
    required this.denominations,
    this.currentDenominationIndex = 0,
    this.isComplete = false,
    this.changeAmount = 0,
  });

  factory CashPaymentState.initial(double amount) {
    return CashPaymentState(
      targetAmount: amount,
      remainingAmount: amount,
      givenAmount: 0,
      denominations: getEuroDenominations(),
    );
  }

  /// Donne la monnaie courante
  CurrencyDenomination? get currentDenomination {
    if (currentDenominationIndex < denominations.length) {
      return denominations[currentDenominationIndex];
    }
    return null;
  }

  bool get hasMoreDenominations {
    return currentDenominationIndex < denominations.length - 1;
  }

  CashPaymentState copyWith({
    double? targetAmount,
    double? remainingAmount,
    double? givenAmount,
    List<CurrencyDenomination>? denominations,
    int? currentDenominationIndex,
    bool? isComplete,
    double? changeAmount,
  }) {
    return CashPaymentState(
      targetAmount: targetAmount ?? this.targetAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      givenAmount: givenAmount ?? this.givenAmount,
      denominations: denominations ?? this.denominations,
      currentDenominationIndex: currentDenominationIndex ?? this.currentDenominationIndex,
      isComplete: isComplete ?? this.isComplete,
      changeAmount: changeAmount ?? this.changeAmount,
    );
  }
}