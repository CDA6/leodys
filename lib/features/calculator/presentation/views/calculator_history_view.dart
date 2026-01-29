import 'package:flutter/material.dart';
import '../viewmodels/calculator_viewmodel.dart';

class HistoryDialog extends StatelessWidget {
  final CalculatorViewModel viewModel;

  const HistoryDialog({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Récupérer l'historique depuis HiveService via le ViewModel
    final history = viewModel.getHistory();

    return AlertDialog(
      title: Semantics(
        header: true,
        child: const Text('Historique des calculs'),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: history.isEmpty //Si hitorique vide on affiche un message
            ? Semantics(
                label: 'Aucun calcul dans l\'historique',
                child: const Center(
                  child: Text(
                    'Aucun calcul dans l\'historique',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ) //sinon on affiche l'historique
            : Semantics(
                label: 'Liste de ${history.length} calcul${history.length > 1 ? 's' : ''}',
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: history.length,
                  itemBuilder: (BuildContext context, int index) {
                    // Affiche les derniers calculs en premier
                    final reversedIndex = history.length - 1 - index;
                    final calculation = history[reversedIndex];
                    return Semantics(
                      label: 'Calcul ${index + 1}: $calculation',
                      child: ListTile(
                        title: Text(
                          calculation,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
      actions: [
        Semantics(
          label: 'Effacer tout l\'historique',
          hint: 'Supprimer tous les calculs de l\'historique',
          button: true,
          enabled: true,
          child: TextButton(
            onPressed: () async {
              viewModel.clearHistory();
              Navigator.pop(context); // Ferme la fenetre
            },
            child: const Text('Effacer l\'historique'),
          ),
        ),
        Semantics(
          label: 'Fermer la fenêtre d\'historique',
          hint: 'Revenir à la calculatrice',
          button: true,
          enabled: true,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ),
      ],
    );
  }
}