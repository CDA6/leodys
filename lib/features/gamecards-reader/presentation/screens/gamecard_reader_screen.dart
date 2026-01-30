import 'package:flutter/material.dart';
import 'package:leodys/common/theme/state_color_extension.dart';
import 'package:leodys/common/widget/button_action.dart';
import 'package:provider/provider.dart';
import '../../../../common/widget/image_picker_section.dart';
import '../viewmodels/gamecard_reader_viewmodel.dart';
import '../widgets/card_result_section.dart';

class GamecardReaderScreen extends StatelessWidget {
  const GamecardReaderScreen({super.key});

  static const route = '/gamecards-reader';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détecteur de cartes'),
      ),
      body: Consumer<GamecardReaderViewModel>(
        builder: (context, viewModel, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Section sélection d'image
                ImagePickerSection(
                  selectedImage: viewModel.selectedImage,
                  isProcessing: viewModel.isProcessing,
                  onCameraPressed: viewModel.pickImageFromCamera,
                  onGalleryPressed: viewModel.pickImageFromGallery,
                ),

                const SizedBox(height: 24),

                // Bouton d'analyse
                ButtonAction(
                    canAnalyze: viewModel.selectedImage != null,
                    isProcessing: viewModel.isProcessing,
                    onPressed: viewModel.analyzeImage,
                    defaultText: 'Analyser',
                    processingText: 'Analyse en cours...'
                ),

                const SizedBox(height: 24),

                // Message d'erreur
                if (viewModel.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.stateColors.error.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: context.stateColors.error),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: context.stateColors.error),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            viewModel.errorMessage!,
                            style: TextStyle(color: context.stateColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Résultats de détection
                if (viewModel.detectedCards.isNotEmpty)
                  CardResultsSection(
                    cards: viewModel.detectedCards,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}