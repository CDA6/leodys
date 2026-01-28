import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leodys/features/ocr-reader/presentation/viewmodels/printed_text_viewmodel.dart';
import 'package:leodys/features/ocr-reader/presentation/widgets/analyze_button.dart';
import 'package:leodys/features/ocr-reader/presentation/widgets/build_error_message.dart';
import 'package:leodys/features/ocr-reader/presentation/widgets/image_picker_section.dart';
import '../../../../common/widget/global_appbar.dart';
import 'ocr_result_screen.dart';

class PrintedTextReaderScreen extends StatelessWidget {
  const PrintedTextReaderScreen({super.key});
  static const route = '/printed-text-reader';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(
        title: 'Texte numérique',
        showAuthActions: false,
        actions: [
          Consumer<PrintedTextViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.selectedImage != null) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Réinitialiser',
                  onPressed: viewModel.clearImage,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<PrintedTextViewModel>(
        builder: (context, viewModel, child) {
          // Navigation automatique vers l'écran de résultat
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.ocrResult != null && viewModel.selectedImage != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OcrResultScreen(
                    image: viewModel.selectedImage!,
                    ocrResult: viewModel.ocrResult!
                  ),
                ),
              ).then((_) {
                viewModel.clearImage();
              });
            }
          });

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Section de sélection d'image
                ImagePickerSection(
                  selectedImage: viewModel.selectedImage,
                  isProcessing: viewModel.isProcessing,
                  onCameraPressed: viewModel.pickImageFromCamera,
                  onGalleryPressed: viewModel.pickImageFromGallery,
                ),

                const SizedBox(height: 24),

                // Bouton d'analyse
                AnalyzeButton(
                    canAnalyze: viewModel.canAnalyze,
                    isProcessing: viewModel.isProcessing,
                    onPressed: viewModel.analyzeImage,
                    processingText: 'Analyse en cours...'
                ),

                // Messages d'erreur
                if (viewModel.errorMessage != null) ...[
                  const SizedBox(height: 20),
                  BuildErrorMessage(viewModel.errorMessage!),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}