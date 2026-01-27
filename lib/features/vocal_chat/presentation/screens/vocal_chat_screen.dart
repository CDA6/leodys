import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/vocal_chat_viewmodel.dart';
import '../widgets/mic_button.dart';

/// Écran principal du chat vocal.
///
/// Interface minimale avec un indicateur d'état et un bouton microphone.
/// L'historique de conversation est effacé à la sortie de l'écran.
class VocalChatScreen extends StatefulWidget {
  static const String route = '/vocal_chat';

  const VocalChatScreen({super.key});

  @override
  State<VocalChatScreen> createState() => _VocalChatScreenState();
}

class _VocalChatScreenState extends State<VocalChatScreen> {
  @override
  void initState() {
    super.initState();
    // Initialiser le ViewModel après le premier build
    Future.microtask(() => context.read<VocalChatViewModel>().initialize());
  }

  @override
  void dispose() {
    // Effacer l'historique à la sortie de l'écran
    context.read<VocalChatViewModel>().clearHistory();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Vocal'),
      ),
      body: Consumer<VocalChatViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              // Indicateur d'état central
              Expanded(
                child: Center(
                  child: _buildStatusIndicator(viewModel),
                ),
              ),

              // Transcription en cours (visible uniquement pendant l'écoute)
              if (viewModel.isListening &&
                  viewModel.currentTranscription.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    viewModel.currentTranscription,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Bouton microphone
              Padding(
                padding: const EdgeInsets.all(32),
                child: MicButton(
                  isListening: viewModel.isListening,
                  isDisabled: viewModel.isProcessing || viewModel.isSpeaking,
                  onPressed: viewModel.startListening,
                  onReleased: viewModel.stopListeningAndProcess,
                ),
              ),

              // Message d'erreur
              if (viewModel.hasError)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: viewModel.resetError,
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

              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  /// Construit l'indicateur d'état selon le statut actuel.
  Widget _buildStatusIndicator(VocalChatViewModel viewModel) {
    if (viewModel.isProcessing) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Traitement en cours...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      );
    }

    if (viewModel.isSpeaking) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.volume_up, size: 48, color: Colors.blue.shade400),
          const SizedBox(height: 16),
          const Text(
            'Lecture en cours...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: viewModel.stopSpeaking,
            icon: const Icon(Icons.stop),
            label: const Text('Arrêter'),
          ),
        ],
      );
    }

    if (viewModel.isListening) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mic, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 16),
          const Text(
            'Parlez maintenant...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      );
    }

    // État idle
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.mic_none, size: 48, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        const Text(
          'Appuyez pour parler',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }
}
