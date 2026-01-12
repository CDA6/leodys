import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/ocr_result.dart';
import '../../../../core/enums/text_type.dart';

class OcrResultDisplay extends StatelessWidget {
  final File? selectedImage;
  final OcrResult? ocrResult;
  final bool isProcessing;
  final TextType textType;

  const OcrResultDisplay({
    super.key,
    required this.selectedImage,
    required this.ocrResult,
    required this.isProcessing,
    required this.textType,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedImage == null) {
      return Center(
        child: Text(
          'Aucune image sélectionnée',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImagePreview(),
          const SizedBox(height: 16),
          if (isProcessing) _buildLoadingIndicator(),
          if (!isProcessing && ocrResult != null) _buildResultText(),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(selectedImage!, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(
            textType == TextType.printed
                ? 'Analyse en cours (hors-ligne)...'
                : 'Analyse en cours (en ligne)...\nCela peut prendre quelques secondes',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Texte détecté :',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            _buildEngineBadge(),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: SelectableText(
            ocrResult!.text,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEngineBadge() {
    final isPrinted = textType == TextType.printed;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isPrinted ? Colors.green.shade100 : Colors.purple.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isPrinted ? 'ML Kit' : 'OCR.space',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isPrinted ? Colors.green.shade800 : Colors.purple.shade800,
        ),
      ),
    );
  }
}