import 'package:flutter/material.dart';
import '../../domain/models/payment_method.dart';
import 'money_manager_view.dart';
import 'payment_history_view.dart';

class PaymentConfirmationView extends StatelessWidget {
  final double amount;
  final PaymentMethod method;
  final bool isSuccess;
  final double? changeAmount;

  const PaymentConfirmationView({
    super.key,
    required this.amount,
    required this.method,
    required this.isSuccess,
    this.changeAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    label: isSuccess ? 'Paiement réussi' : 'Paiement échoué',
                    child: Icon(
                      isSuccess ? Icons.check_circle : Icons.error,
                      size: 100,
                      color: isSuccess ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Semantics(
                    header: true,
                    child: Text(
                      isSuccess ? 'Paiement réussi' : 'Paiement échoué',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Semantics(
                    label: 'Récapitulatif du paiement',
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _InfoRow(
                              label: 'Montant',
                              value: '${amount.toStringAsFixed(2)}€',
                              semanticValue: '${amount.toStringAsFixed(2)} euros',
                            ),
                            const Divider(height: 24),
                            _InfoRow(
                              label: 'Méthode',
                              value: method.displayName,
                            ),
                            if (changeAmount != null && changeAmount! > 0) ...[
                              const Divider(height: 24),
                              _InfoRow(
                                label: 'Monnaie rendue',
                                value: '${changeAmount!.toStringAsFixed(2)}€',
                                semanticValue: '${changeAmount!.toStringAsFixed(2)} euros',
                                valueColor: Colors.orange.shade700,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PaymentHistoryView(),
                        ),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('Voir l\'historique'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.popUntil(context, ModalRoute.withName(MoneyManagerView.route));
                    },

                    icon: const Icon(Icons.home),
                    label: const Text('Retour à l\'accueil'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String? semanticValue;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.semanticValue,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: ${semanticValue ?? value}',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ExcludeSemantics(
            child: Text(label, style: Theme.of(context).textTheme.titleMedium),
          ),
          ExcludeSemantics(
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}