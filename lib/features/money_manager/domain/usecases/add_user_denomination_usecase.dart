import '../models/currency_denomination.dart';
import '../models/cash_payment_state.dart';

/// Use case pour ajouter une dénomination donnée par l'utilisateur
class AddUserDenominationUseCase {
  /// Ajoute une unité donnée par l'utilisateur et recalcule l'état
  CashPaymentState execute(CashPaymentState currentState) {
    final currentDenom = currentState.currentDenomination;
    if (currentDenom == null) return currentState;

    final updatedDenoms = List<CurrencyDenomination>.from(currentState.denominations);
    final newUserGiven = currentDenom.userGiven + 1;

    updatedDenoms[currentState.currentDenominationIndex] =
        currentDenom.copyWith(userGiven: newUserGiven);

    final newGivenAmount = currentState.givenAmount + currentDenom.value;
    final newRemainingAmount = _roundToTwoDecimals(
      currentState.targetAmount - newGivenAmount
    );

    // Si l'utilisateur a donné assez pour cette dénomination ou a dépassé le montant cible
    bool shouldMoveToNext = newUserGiven >= currentDenom.count || newRemainingAmount <= 0;
    int newIndex = shouldMoveToNext
        ? currentState.currentDenominationIndex + 1
        : currentState.currentDenominationIndex;

    // Vérifier si le paiement est complet
    bool isComplete = newGivenAmount >= currentState.targetAmount;
    double changeAmount = isComplete
        ? _roundToTwoDecimals(newGivenAmount - currentState.targetAmount)
        : 0;

    return currentState.copyWith(
      denominations: updatedDenoms,
      givenAmount: newGivenAmount,
      remainingAmount: newRemainingAmount > 0 ? newRemainingAmount : 0,
      currentDenominationIndex: newIndex,
      isComplete: isComplete,
      changeAmount: changeAmount,
    );
  }

  /// Arrondit à 2 décimales pour éviter les problèmes de précision
  double _roundToTwoDecimals(double value) {
    return (value * 100).round() / 100;
  }
}