import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/payment_method.dart';
import '../../domain/models/payment_transaction.dart';
import '../../domain/models/currency_denomination.dart';
import '../viewmodels/cash_payment_viewmodel.dart';
import '../../data/repositories/payment_repository.dart';
import 'payment_confirmation_view.dart';

/// Vue pour le paiement en liquide
class CashPaymentView extends StatelessWidget {
  final double amount;

  const CashPaymentView({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CashPaymentViewModel()..initializePayment(amount),
      child: const _CashPaymentContent(),
    );
  }
}

class _CashPaymentContent extends StatelessWidget {
  const _CashPaymentContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CashPaymentViewModel>();
    final state = viewModel.state;

    if (state == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (viewModel.isComplete) {
      return _CompletionView(state: state);
    }

    final currentDenom = state.currentDenomination;
    if (currentDenom == null) {
      // Plus de dénominations disponibles, montant insuffisant
      return _InsufficientPaymentView(state: state);
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Bouton annuler
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(height: 32),
                // Montant restant
                Semantics(
                  label: 'Montant à payer: ${state.targetAmount.toStringAsFixed(2)} euros. Montant restant: ${state.remainingAmount.toStringAsFixed(2)} euros',
                  child: Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ExcludeSemantics(
                        child: Column(
                          children: [
                            Text(
                              'Montant à payer',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${state.targetAmount.toStringAsFixed(2)}€',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const Divider(height: 24),
                            Text(
                              'Montant restant',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${state.remainingAmount.toStringAsFixed(2)}€',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Dénomination actuelle
                Semantics(
                  label: '${currentDenom.type} de ${currentDenom.displayValue}. Nombre suggéré: ${currentDenom.count}. Déjà donné: ${currentDenom.userGiven}',
                  child: SizedBox(
                    height: 320,
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: ExcludeSemantics(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Image de la dénomination (billet ou pièce)
                              ClipRRect(
                                //borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  currentDenom.imagePath,
                                  height: 100,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback sur l'icône si l'image n'est pas trouvée
                                    return Icon(
                                      currentDenom.isBill
                                          ? Icons.receipt_long
                                          : Icons.monetization_on,
                                      size: 80,
                                      color: Theme.of(context).colorScheme.secondary,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                currentDenom.type,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentDenom.displayValue,
                                style: Theme.of(context).textTheme.headlineLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nombre suggéré: ${currentDenom.count}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Déjà donné: ${currentDenom.userGiven}',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        button: true,
                        label: 'Je n\'ai pas de ${currentDenom.type.toLowerCase()} de ${currentDenom.displayValue}',
                        child: ElevatedButton.icon(
                          onPressed: viewModel.skipDenomination,
                          icon: const Icon(Icons.close),
                          label: const Text('Je n\'ai pas'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Semantics(
                        button: true,
                        label: 'Ajouter un ${currentDenom.type.toLowerCase()} de ${currentDenom.displayValue}',
                        child: ElevatedButton.icon(
                          onPressed: viewModel.addDenomination,
                          icon: const Icon(Icons.add),
                          label: const Text('+1'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Récapitulatif
                if (state.givenAmount > 0)
                  Semantics(
                    label: 'Montant déjà donné: ${state.givenAmount.toStringAsFixed(2)} euros',
                    child: Card(
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ExcludeSemantics(
                              child: Text(
                                'Montant déjà donné: ${state.givenAmount.toStringAsFixed(2)}€',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompletionView extends StatelessWidget {
  final dynamic state;

  const _CompletionView({required this.state});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<CashPaymentViewModel>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                Semantics(
                  label: 'Paiement complet',
                  child: const Icon(Icons.check_circle, size: 80, color: Colors.green),
                ),
                const SizedBox(height: 24),
                Semantics(
                  header: true,
                  child: Text(
                    'Paiement complet',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                Semantics(
                  label: 'Récapitulatif: Montant donné ${state.givenAmount.toStringAsFixed(2)} euros, Montant à payer ${state.targetAmount.toStringAsFixed(2)} euros${state.changeAmount > 0 ? ', Monnaie à rendre ${state.changeAmount.toStringAsFixed(2)} euros' : ''}',
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ExcludeSemantics(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Récapitulatif',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const Divider(height: 24),
                            Text(viewModel.getSummary()),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Montant donné:'),
                                Text(
                                  '${state.givenAmount.toStringAsFixed(2)}€',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Montant à payer:'),
                                Text(
                                  '${state.targetAmount.toStringAsFixed(2)}€',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (state.changeAmount > 0) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Monnaie à rendre:'),
                                  Text(
                                    '${state.changeAmount.toStringAsFixed(2)}€',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade700,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Annuler le paiement'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _confirmPayment(context, state),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Confirmer le paiement'),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Future<void> _confirmPayment(BuildContext context, dynamic state) async {
    final paymentRepo = PaymentRepository();
    final transaction = PaymentTransaction.create(
      amount: state.targetAmount,
      paymentMethod: PaymentMethod.cash,
      isSuccess: true,
      details: context.read<CashPaymentViewModel>().getSummary(),
    );
    await paymentRepo.saveTransaction(transaction);

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentConfirmationView(
            amount: state.targetAmount,
            method: PaymentMethod.cash,
            isSuccess: true,
            changeAmount: state.changeAmount,
          ),
        ),
      );
    }
  }
}

class _InsufficientPaymentView extends StatelessWidget {
  final dynamic state;

  const _InsufficientPaymentView({required this.state});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<CashPaymentViewModel>();

    // Trouver la plus petite dénomination supérieure au montant restant
    final suggestedDenom = _findSmallestHigherDenomination(state.remainingAmount);
    final changeAmount = suggestedDenom != null
        ? (suggestedDenom.value - state.remainingAmount).toStringAsFixed(2)
        : '0.00';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Bouton retour en haut


                  const SizedBox(height: 32),

                  // Récapitulatif montant
                  Semantics(
                    label: 'Montant restant à payer: ${state.remainingAmount.toStringAsFixed(2)} euros',
                    child: Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ExcludeSemantics(
                          child: Column(
                            children: [
                              Text(
                                'Montant restant à payer',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${state.remainingAmount.toStringAsFixed(2)}€',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Proposition de dénomination supérieure
                  if (suggestedDenom != null)
                    Semantics(
                      label: 'Suggestion: Donnez ${suggestedDenom.displayValue}, monnaie à rendre $changeAmount euros',
                      child: Card(
                        color: Colors.orange.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Image de la dénomination suggérée
                              ExcludeSemantics(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    suggestedDenom.imagePath,
                                    height: 80,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.lightbulb_outline,
                                        size: 48,
                                        color: Colors.orange,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Vous n\'avez pas l\'appoint ?',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Donnez ${suggestedDenom.displayValue}',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Monnaie à rendre : $changeAmount€',
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _giveHigherDenomination(
                                    context,
                                    viewModel,
                                    suggestedDenom.value,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text('Donner cette somme'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  if (suggestedDenom == null) ...[
                    Semantics(
                      label: 'Erreur: Paiement impossible',
                      child: const Center(
                        child: Icon(Icons.error_outline, size: 80, color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Semantics(
                      header: true,
                      child: Text(
                        'Paiement impossible',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Semantics(
                      label: 'Il manque encore ${state.remainingAmount.toStringAsFixed(2)} euros',
                      child: ExcludeSemantics(
                        child: Text(
                          'Il manque encore ${state.remainingAmount.toStringAsFixed(2)}€',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Annuler le paiement'),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Trouve la plus petite dénomination supérieure au montant restant
  CurrencyDenomination? _findSmallestHigherDenomination(double amount) {
    final denominations = [
      CurrencyDenomination(value: 0.02, isBill: false),
      CurrencyDenomination(value: 0.05, isBill: false),
      CurrencyDenomination(value: 0.10, isBill: false),
      CurrencyDenomination(value: 0.20, isBill: false),
      CurrencyDenomination(value: 0.50, isBill: false),
      CurrencyDenomination(value: 1.0, isBill: false),
      CurrencyDenomination(value: 2.0, isBill: false),
      CurrencyDenomination(value: 5.0, isBill: true),
      CurrencyDenomination(value: 10.0, isBill: true),
      CurrencyDenomination(value: 20.0, isBill: true),
      CurrencyDenomination(value: 50.0, isBill: true),
    ];

    for (final denom in denominations) {
      if (denom.value > amount) {
        return denom;
      }
    }
    return null;
  }

  /// Donne une dénomination supérieure et termine le paiement
  void _giveHigherDenomination(
    BuildContext context,
    CashPaymentViewModel viewModel,
    double denomValue,
  ) {
    final newGivenAmount = state.givenAmount + denomValue;
    final changeAmount = ((newGivenAmount - state.targetAmount) * 100).round() / 100;

    // Naviguer vers la confirmation avec la monnaie à rendre
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentConfirmationView(
          amount: state.targetAmount,
          method: PaymentMethod.cash,
          isSuccess: true,
          changeAmount: changeAmount,
        ),
      ),
    );

    // Sauvegarder la transaction
    final paymentRepo = PaymentRepository();
    paymentRepo.saveTransaction(
      PaymentTransaction.create(
        amount: state.targetAmount,
        paymentMethod: PaymentMethod.cash,
        isSuccess: true,
        details: '${viewModel.getSummary()}\nMonnaie rendue: ${changeAmount.toStringAsFixed(2)}€',
      ),
    );
  }
}