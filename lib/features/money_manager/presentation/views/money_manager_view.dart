import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../domain/models/payment_method.dart';
import '../viewmodels/money_manager_viewmodel.dart';
import '../../data/repositories/payment_repository.dart';
import 'google_pay_view.dart';
import 'cash_payment_view.dart';
import 'payment_history_view.dart';

/// Vue principale
class MoneyManagerView extends StatelessWidget {
  const MoneyManagerView({super.key});

  static const route = '/money_manager';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MoneyManagerViewModel(PaymentRepository()),
      child: const _MoneyManagerContent(),
    );
  }
}

/// Contenu de la vue
class _MoneyManagerContent extends StatelessWidget {
  const _MoneyManagerContent({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MoneyManagerViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement avec Google Pay ou avec de la monnaie.'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Section: Saisie du montant
            Semantics(
              label: 'Section saisie du montant à payer',
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              'Montant à payer',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Semantics(
                            button: true,
                            label: 'Voir l\'historique des paiements',
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushNamed(context, PaymentHistoryView.route);
                              },
                              icon: const Icon(Icons.history),
                              tooltip: 'Voir l\'historique',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Semantics(
                        textField: true,
                        label: 'Champ de saisie du montant en euros',
                        child: TextField(
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Montant',
                            prefixIcon: const Icon(Icons.euro),
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: viewModel.setAmount,
                        ),
                      ),
                      if (viewModel.amount != null && viewModel.amount! > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Semantics(
                            liveRegion: true,
                            label: 'Montant saisi: ${viewModel.amount!.toStringAsFixed(2)} euros',
                            child: ExcludeSemantics(
                              child: Text(
                                'Montant: ${viewModel.amount!.toStringAsFixed(2)}€',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),



            // Méthode de paiement
            Semantics(
              label: 'Section choix de la méthode de paiement',
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          'Méthode de paiement',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _PaymentMethodOption(
                        method: PaymentMethod.googlePay,
                        icon: Icons.phone_android,
                        isSelected: viewModel.selectedMethod == PaymentMethod.googlePay,
                        onTap: defaultTargetPlatform == TargetPlatform.android
                            ? () => viewModel.setPaymentMethod(PaymentMethod.googlePay)
                            : null, // Désactivé sous Windows
                        isEnabled: defaultTargetPlatform == TargetPlatform.android,
                      ),
                      const SizedBox(height: 12),
                      _PaymentMethodOption(
                        method: PaymentMethod.cash,
                        icon: Icons.euro_symbol,
                        isSelected: viewModel.selectedMethod == PaymentMethod.cash,
                        onTap: () => viewModel.setPaymentMethod(PaymentMethod.cash),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Bouton de validation
            ElevatedButton(
              onPressed: viewModel.isValid ? () => _handlePayment(context, viewModel) : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('Continuer'),
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _handlePayment(BuildContext context, MoneyManagerViewModel viewModel) {
    if (viewModel.selectedMethod == PaymentMethod.googlePay) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GooglePayView(amount: viewModel.amount!),
        ),
      );
    } else if (viewModel.selectedMethod == PaymentMethod.cash) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CashPaymentView(amount: viewModel.amount!),
        ),
      );
    }
  }
}

class _PaymentMethodOption extends StatelessWidget {
  final PaymentMethod method;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isEnabled;

  const _PaymentMethodOption({
    required this.method,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final String statusText = isSelected ? 'sélectionné' : 'non sélectionné';
    final String enabledText = isEnabled ? '' : ', non disponible sous Windows';

    return Semantics(
      button: true,
      enabled: isEnabled,
      selected: isSelected,
      label: '${method.displayName}, $statusText$enabledText',
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: ExcludeSemantics(
          child: Opacity(
            opacity: isEnabled ? 1.0 : 0.5,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 32,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.displayName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                        ),
                        if (!isEnabled)
                          Text(
                            'Non disponible sous Windows',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.red.shade700,
                                ),
                          ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
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