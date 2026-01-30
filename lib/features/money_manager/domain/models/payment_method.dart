/// Énumération des méthodes de paiement disponibles
enum PaymentMethod {
  googlePay,
  cash,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.googlePay:
        return 'Google Pay';
      case PaymentMethod.cash:
        return 'Paiement en liquide';
    }
  }
}