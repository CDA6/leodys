import '../models/currency_denomination.dart';
import '../models/cash_payment_state.dart';

/// Use case pour calculer la combinaison optimale de billets et pièces
class CalculateOptimalChangeUseCase {
  /// Calcule la combinaison optimale de billets et pièces pour un montant donné
  ///
  /// Algorithme Greedy (glouton) optimisé :
  /// - Ne retourne que les dénominations avec count > 0
  /// - Évite de proposer des billets de 500€, 200€ pour de petits montants
  CashPaymentState execute(double amount) {
    final state = CashPaymentState.initial(amount);
    final allDenominations = _getEuroDenominations();
    final usefulDenominations = <CurrencyDenomination>[];

    double remaining = amount;

    for (var denomination in allDenominations) {
      if (remaining >= denomination.value) {
        // Algorithme Greedy : prend le maximum d'unités possibles
        int count = (remaining / denomination.value).floor();

        if (count > 0) {
          // Ne garde que les dénominations utiles (count > 0)
          denomination.count = count;
          usefulDenominations.add(denomination);
          remaining = _roundToTwoDecimals(remaining - (count * denomination.value));
        }
      }
    }

    return state.copyWith(denominations: usefulDenominations);
  }

  /// Retourne la liste des dénominations Euro (billets et pièces)
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