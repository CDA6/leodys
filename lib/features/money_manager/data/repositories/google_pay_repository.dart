import 'package:pay/pay.dart';

/// Repository pour gérer les paiements Google Pay
class GooglePayRepository {
  /// Crée un élément de paiement pour Google Pay
  PaymentItem createPaymentItem(double amount) {
    return PaymentItem(
      label: 'Total',
      amount: amount.toStringAsFixed(2),
      status: PaymentItemStatus.final_price,
    );
  }
}