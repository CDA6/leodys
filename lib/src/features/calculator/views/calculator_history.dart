import 'package:flutter/material.dart';
import '../viewmodels/calculator_viewmodel.dart';

class HistoryDialog extends StatelessWidget {
  final CalculatorViewModel viewModel;

  const HistoryDialog({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final history = viewModel.state.history;

    return AlertDialog(
      title: const Text('Historique des calculs'),
      content: SizedBox(
        width: double.maxFinite,
        child: history.isEmpty //Si hitorique vide on affiche un message
            ? const Center(
                child: Text(
                  'Aucun calcul dans l\'historique',
                  style: TextStyle(color: Colors.grey),
                ),
              ) //sinon on affiche l'historique
            : ListView.builder(
                shrinkWrap: true,
                itemCount: history.length,
                itemBuilder: (BuildContext context, int index) {
                  final reversedIndex = history.length - 1 - index;
                  return ListTile(
                    title: Text(
                      history[reversedIndex],
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}