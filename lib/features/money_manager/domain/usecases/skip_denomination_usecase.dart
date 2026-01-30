import '../models/currency_denomination.dart';
import '../models/cash_payment_state.dart';

/// Use case pour gérer le cas où l'utilisateur saute une dénomination
class SkipDenominationUseCase {
  /// Ajuste le calcul quand l'utilisateur ne peut pas fournir une dénomination
  CashPaymentState execute(CashPaymentState currentState) {
    final currentDenom = currentState.currentDenomination;
    if (currentDenom == null) return currentState;

    // Marquer que l'utilisateur ne donne rien pour cette dénomination
    final updatedDenoms = List<CurrencyDenomination>.from(currentState.denominations);
    updatedDenoms[currentState.currentDenominationIndex] =
        currentDenom.copyWith(count: 0, userGiven: 0);

    // Recalculer avec TOUTES les dénominations possibles pour le montant restant
    final allDenominations = _getEuroDenominations();
    final remaining = currentState.remainingAmount;

    // Trouver l'index de la dénomination actuelle dans la liste complète
    final currentValueIndex = allDenominations.indexWhere(
      (d) => d.value == currentDenom.value
    );

    // Si on est sur la dernière dénomination (0.01€), on ne peut plus rien faire
    // Le montant restant ne peut pas être payé avec la monnaie disponible
    if (currentValueIndex >= allDenominations.length - 1) {
      return currentState.copyWith(
        denominations: updatedDenoms,
        currentDenominationIndex: currentState.currentDenominationIndex + 1,
      );
    }

    // Recalculer pour les dénominations suivantes
    double tempRemaining = remaining;
    final newUsefulDenoms = <CurrencyDenomination>[];

    // Garder les dénominations déjà traitées
    for (int i = 0; i <= currentState.currentDenominationIndex; i++) {
      if (i < updatedDenoms.length) {
        newUsefulDenoms.add(updatedDenoms[i]);
      }
    }

    // Calculer pour les dénominations suivantes (à partir de la liste complète)
    for (int i = currentValueIndex + 1; i < allDenominations.length; i++) {
      final denom = allDenominations[i];
      if (tempRemaining >= denom.value) {
        int count = (tempRemaining / denom.value).floor();
        if (count > 0) {
          newUsefulDenoms.add(denom.copyWith(count: count));
          tempRemaining = _roundToTwoDecimals(tempRemaining - (count * denom.value));
        }
      }
    }

    return currentState.copyWith(
      denominations: newUsefulDenoms,
      currentDenominationIndex: currentState.currentDenominationIndex + 1,
    );
  }

  /// Retourne la liste complète des dénominations Euro
  List<CurrencyDenomination> _getEuroDenominations() {
    return [
      CurrencyDenomination(value: 500.0, isBill: true),
      CurrencyDenomination(value: 200.0, isBill: true),
      CurrencyDenomination(value: 100.0, isBill: true),
      CurrencyDenomination(value: 50.0, isBill: true),
      CurrencyDenomination(value: 20.0, isBill: true),
      CurrencyDenomination(value: 10.0, isBill: true),
      CurrencyDenomination(value: 5.0, isBill: true),
      CurrencyDenomination(value: 2.0, isBill: false),
      CurrencyDenomination(value: 1.0, isBill: false),
      CurrencyDenomination(value: 0.50, isBill: false),
      CurrencyDenomination(value: 0.20, isBill: false),
      CurrencyDenomination(value: 0.10, isBill: false),
      CurrencyDenomination(value: 0.05, isBill: false),
      CurrencyDenomination(value: 0.02, isBill: false),
      CurrencyDenomination(value: 0.01, isBill: false),
    ];
  }

  /// Arrondit à 2 décimales pour éviter les problèmes de précision
  double _roundToTwoDecimals(double value) {
    return (value * 100).round() / 100;
  }
}