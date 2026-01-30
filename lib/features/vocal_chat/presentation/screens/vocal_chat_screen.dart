import 'package:flutter/material.dart';
import 'package:leodys/common/theme/state_color_extension.dart';
import 'package:leodys/common/theme/theme_context_extension.dart';
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
                        color: context.stateColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: context.stateColors.error),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: context.stateColors.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              viewModel.errorMessage ?? 'Une erreur est survenue',
                              style: TextStyle(
                                color: context.stateColors.error,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Icon(Icons.close, color: context.stateColors.error, size: 18),
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
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Traitement en cours...',
            style: TextStyle(fontSize: 16, color: context.colorScheme.primary),
          ),
        ],
      );
    }

    if (viewModel.isSpeaking) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.volume_up, size: 48, color: context.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Lecture en cours...',
            style: TextStyle(fontSize: 16, color: context.colorScheme.primary),
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
          Icon(Icons.mic, size: 48, color: context.stateColors.error),
          const SizedBox(height: 16),
          Text(
            'Parlez maintenant...',
            style: TextStyle(fontSize: 16, color: context.colorScheme.error),
          ),
        ],
      );
    }

    // État idle
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.mic_none, size: 48, color: context.colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          'Appuyez pour parler',
          style: TextStyle(fontSize: 16, color: context.colorScheme.primary),
        ),
      ],
    );
  }
}
