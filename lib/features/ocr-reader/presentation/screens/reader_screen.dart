import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../viewmodels/reader_viewmodel.dart';
import '../widgets/text_type_selector.dart';
import '../widgets/ocr_result_display.dart';

class ReaderScreen extends StatelessWidget {
  const ReaderScreen({super.key});
  static const route = '/ocr-reader';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => context.read<ReaderViewModel>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lecture de texte'),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<ReaderViewModel>(
            builder: (context, viewModel, child) {
              return Column(
                children: [
                  TextTypeSelector(
                    selectedType: viewModel.selectedTextType,
                    onTypeChanged: viewModel.setTextType,
                  ),
                  const SizedBox(height: 16),
                  _buildActionButtons(context, viewModel),
                  const SizedBox(height: 16),
                  Expanded(
                    child: OcrResultDisplay(
                      selectedImage: viewModel.selectedImage,
                      ocrResult: viewModel.ocrResult,
                      isProcessing: viewModel.isProcessing,
                      textType: viewModel.selectedTextType,
                    ),
                  ),
                  if (viewModel.errorMessage != null)
                    _buildErrorMessage(viewModel.errorMessage!),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ReaderViewModel viewModel) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: viewModel.isProcessing
              ? null
              : () => viewModel.pickImage(ImageSource.camera),
          icon: const Icon(Icons.camera_alt),
          label: const Text('Prendre une photo'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: viewModel.isProcessing
              ? null
              : () => viewModel.pickImage(ImageSource.gallery),
          icon: const Icon(Icons.image),
          label: const Text('Sélectionner une photo'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
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
                message,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}