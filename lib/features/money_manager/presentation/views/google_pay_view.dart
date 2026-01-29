import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import '../../domain/models/payment_method.dart';
import '../../domain/models/payment_transaction.dart';
import '../../data/repositories/payment_repository.dart';
import 'payment_confirmation_view.dart';

class GooglePayView extends StatefulWidget {
  final double amount;

  const GooglePayView({super.key, required this.amount});

  @override
  State<GooglePayView> createState() => _GooglePayViewState();
}

class _GooglePayViewState extends State<GooglePayView> {
  final PaymentRepository _paymentRepo = PaymentRepository();
  late final Future<PaymentConfiguration> _gpayConfigFuture;  // Ajout 1

  @override
  void initState() {
    super.initState();
    _gpayConfigFuture = PaymentConfiguration.fromAsset('google_pay_config.json');
  }

  void _onGooglePayResult(Map<String, dynamic> result) async {
    // Paiement réussi
    final transaction = PaymentTransaction.create(
      amount: widget.amount,
      paymentMethod: PaymentMethod.googlePay,
      isSuccess: true,
      details: 'Paiement Google Pay réussi',
    );
    await _paymentRepo.saveTransaction(transaction);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentConfirmationView(
            amount: widget.amount,
            method: PaymentMethod.googlePay,
            isSuccess: true,
          ),
        ),
      );
    }
  }

  void _onGooglePayError(Object? error) async {
    // Paiement échoué
    final transaction = PaymentTransaction.create(
      amount: widget.amount,
      paymentMethod: PaymentMethod.googlePay,
      isSuccess: false,
      details: 'Erreur: ${error.toString()}',
    );
    await _paymentRepo.saveTransaction(transaction);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de paiement: ${error.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      Navigator.pop(context);
    }
  }

  PaymentItem _createPaymentItem(double amount) {
    return PaymentItem(
      label: 'Total',
      amount: amount.toStringAsFixed(2),
      status: PaymentItemStatus.final_price,
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentItem = _createPaymentItem(widget.amount);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bouton retour (inchangé)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(height: 32),
                Semantics(
                  label: 'Paiement Google Pay',
                  child: Icon(Icons.payment, size: 80, color: Theme.of(context).colorScheme.primary),  // Icon plus précis
                ),
                const SizedBox(height: 32),
                Semantics(
                  label: 'Montant à payer: ${widget.amount.toStringAsFixed(2)} euros',
                  child: Column(children: [
                    ExcludeSemantics(child: Text('Montant à payer', style: Theme.of(context).textTheme.titleLarge)),
                    const SizedBox(height: 8),
                    ExcludeSemantics(child: Text('${widget.amount.toStringAsFixed(2)}€', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary))),
                  ]),
                ),
                const SizedBox(height: 48),
                // Remplace le GooglePayButton par ça (Ajout 3)
                FutureBuilder<PaymentConfiguration>(
                  future: _gpayConfigFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Text('Erreur config: ${snapshot.error ?? 'Inconnue'}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.red), textAlign: TextAlign.center);
                    }
                    return Semantics(
                      button: true,
                      label: 'Payer ${widget.amount.toStringAsFixed(2)} euros avec Google Pay',
                      child: SizedBox(
                        width: double.infinity,
                        child: GooglePayButton(
                          paymentConfiguration: snapshot.data!,
                          paymentItems: [paymentItem],
                          type: GooglePayButtonType.pay,
                          margin: const EdgeInsets.only(top: 15.0),
                          onPaymentResult: _onGooglePayResult,
                          onError: _onGooglePayError,
                          loadingIndicator: const Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Appuyez sur le bouton Google Pay pour continuer',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}