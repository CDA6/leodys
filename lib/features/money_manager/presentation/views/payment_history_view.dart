import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/payment_history_viewmodel.dart';
import '../../data/repositories/payment_repository.dart';
import '../../domain/models/payment_method.dart';

/// représente la vue de l'historique des paiements
class PaymentHistoryView extends StatelessWidget {
  const PaymentHistoryView({super.key});

  static const route = '/payment_history';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          PaymentHistoryViewModel(PaymentRepository())..loadTransactions(),
      child: const _PaymentHistoryContent(),
    );
  }
}

class _PaymentHistoryContent extends StatelessWidget {
  const _PaymentHistoryContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PaymentHistoryViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Builder(
          builder: (context) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    label: 'Erreur de chargement',
                    child: const Icon(Icons.error_outline, size: 80, color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    liveRegion: true,
                    child: Text(viewModel.errorMessage!),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: viewModel.loadTransactions,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (!viewModel.hasTransactions) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Semantics(
                      label: 'Historique vide',
                      child: Icon(
                        Icons.receipt_long,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Semantics(
                      header: true,
                      child: Text(
                        'Aucun paiement enregistré',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                     SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        // bouton retour
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          '/money_manager',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Retour'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: viewModel.transactions.length,
                  // Liste des transactions
                  itemBuilder: (context, index) {
                    final transaction = viewModel.transactions[index];
                    return _TransactionCard(
                      date: transaction.date,
                      amount: transaction.amount,
                      method: transaction.method,
                      isSuccess: transaction.isSuccess,
                      details: transaction.details,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        // bouton effacer l'historique
                        onPressed: () => _showDeleteConfirmation(context, viewModel),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Effacer l\'historique'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        // bouton retour
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          '/money_manager',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Retour'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      ),
    );
  }

  /// Affiche une boîte de dialogue de confirmation avant d'effacer l'historique
  void _showDeleteConfirmation(
    BuildContext context,
    PaymentHistoryViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer'),
        content: const Text(
          'Effacer tout l\'historique des paiements ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              viewModel.clearAll();
              Navigator.pop(context);
            },
            child: const Text('Effacer'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }
}

/// Carte représentant une transaction
class _TransactionCard extends StatelessWidget {
  final DateTime date;
  final double amount;
  final PaymentMethod method;
  final bool isSuccess;
  final String? details;

  const _TransactionCard({
    required this.date,
    required this.amount,
    required this.method,
    required this.isSuccess,
    this.details,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');
    final statusText = isSuccess ? 'réussi' : 'échoué';
    final semanticLabel = 'Paiement de ${amount.toStringAsFixed(2)} euros par ${method.displayName}, $statusText, le ${dateFormat.format(date)}';

    return Semantics(
      label: semanticLabel,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ExcludeSemantics(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSuccess
                  ? Colors.green.shade100
                  : Colors.red.shade100,
              child: Icon(
                _getMethodIcon(),
                color: isSuccess ? Colors.green : Colors.red,
              ),
            ),
            title: Row(
              children: [
                Text(
                  '${amount.toStringAsFixed(2)}€',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(width: 8),
                if (!isSuccess)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Échec',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(method.displayName),
                Text(
                  dateFormat.format(date),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (details != null && details!.isNotEmpty) // détails des transaction
                  Text(
                    details!,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            isThreeLine: true,
          ),
        ),
      ),
    );
  }

  /// Retourne l'icône correspondant au paiment ( carte ou liquide )
  IconData _getMethodIcon() {
    switch (method) {
      case PaymentMethod.googlePay:
        return Icons.phone_android;
      case PaymentMethod.cash:
        return Icons.euro_symbol;
    }
  }
}