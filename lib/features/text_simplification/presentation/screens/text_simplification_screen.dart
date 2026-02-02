import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/text_simplification_viewmodel.dart';
import '../widgets/simplification_result_card.dart';

/// Ecran principal de simplification de texte pour dyslexiques.
class TextSimplificationScreen extends StatefulWidget {
  static const String route = '/text_simplification';

  const TextSimplificationScreen({super.key});

  @override
  State<TextSimplificationScreen> createState() =>
      _TextSimplificationScreenState();
}

class _TextSimplificationScreenState extends State<TextSimplificationScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Charger l'historique apres le premier build
    Future.microtask(() {
      if (!mounted) return;
      final viewModel = context.read<TextSimplificationViewModel>();
      viewModel.loadHistory();
      _textController.text = viewModel.inputText;
    });

    _textController.addListener(() {
      context.read<TextSimplificationViewModel>().setInputText(_textController.text);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simplification de texte'),
      ),
      body: Consumer<TextSimplificationViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              // Zone de saisie
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _textController,
                      maxLines: 5,
                      minLines: 3,
                      enabled: !viewModel.isProcessing,
                      decoration: InputDecoration(
                        hintText: 'Collez ou tapez le texte a simplifier...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        suffixIcon: _textController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _textController.clear();
                                  viewModel.reset();
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: viewModel.isProcessing
                            ? null
                            : () => viewModel.simplifyText(),
                        icon: viewModel.isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.auto_fix_high),
                        label: Text(
                          viewModel.isProcessing
                              ? 'Simplification en cours...'
                              : 'Simplifier',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Message d'erreur
              if (viewModel.hasError)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: viewModel.clearError,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              viewModel.errorMessage ?? 'Une erreur est survenue',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Icon(Icons.close, color: Colors.red.shade700, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),

              // Resultat courant
              if (viewModel.hasResult && viewModel.currentResult != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SimplificationResultCard(
                    item: viewModel.currentResult!,
                    showOriginal: true,
                  ),
                ),

              // Separateur avec titre Historique
              if (viewModel.history.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Icon(Icons.history, size: 20, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'Historique',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
              ],

              // Liste historique
              Expanded(
                child: viewModel.isLoadingHistory
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.history.isEmpty
                        ? const Center(
                            child: Text(
                              'Aucune simplification dans l\'historique',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 16),
                            itemCount: viewModel.history.length,
                            itemBuilder: (context, index) {
                              final item = viewModel.history[index];
                              // Ne pas afficher l'item courant dans la liste
                              if (viewModel.currentResult?.id == item.id) {
                                return const SizedBox.shrink();
                              }
                              return SimplificationResultCard(
                                item: item,
                                onTap: () => viewModel.selectFromHistory(item),
                                onDelete: () => _confirmDelete(context, viewModel, item.id),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    TextSimplificationViewModel viewModel,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Voulez-vous supprimer cette simplification ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.deleteItem(id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
