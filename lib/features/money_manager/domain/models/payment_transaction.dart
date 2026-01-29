import 'package:hive/hive.dart';
import 'payment_method.dart';

part 'payment_transaction.g.dart';

/// Modèle représentant une transaction de paiement
@HiveType(typeId: 7)
class PaymentTransaction {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String paymentMethod;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final bool isSuccess;

  @HiveField(5)
  final String? details;

  PaymentTransaction({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.date,
    required this.isSuccess,
    this.details,
  });

  factory PaymentTransaction.create({
    required double amount,
    required PaymentMethod paymentMethod,
    required bool isSuccess,
    String? details,
  }) {
    return PaymentTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      paymentMethod: paymentMethod.name,
      date: DateTime.now(),
      isSuccess: isSuccess,
      details: details,
    );
  }

  PaymentMethod get method {
    return paymentMethod == 'googlePay'
        ? PaymentMethod.googlePay
        : PaymentMethod.cash;
  }
}