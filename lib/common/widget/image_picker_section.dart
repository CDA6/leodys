import 'dart:io';
import 'package:flutter/material.dart';
import 'package:leodys/common/theme/theme_context_extension.dart';

class ImagePickerSection extends StatelessWidget {
  final File? selectedImage;
  final bool isProcessing;
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;

  const ImagePickerSection({
    super.key,
    required this.selectedImage,
    required this.isProcessing,
    required this.onCameraPressed,
    required this.onGalleryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (selectedImage == null) ...[
          _buildEmptyState(context),
          const SizedBox(height: 24),
        ] else ...[
          _buildImagePreview(),
          const SizedBox(height: 16),
        ],
        _buildActionButtons(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colorScheme.outline,
          style: BorderStyle.solid,
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 64,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 12),
            Text(
              'Aucune image sélectionnée',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Prenez une photo ou sélectionnez-en une',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          selectedImage!,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: isProcessing ? null : onCameraPressed,
          icon: Icon(Icons.camera_alt, color: context.colorScheme.onPrimaryContainer),
          label: Text('Appareil photo', style: TextStyle(fontSize: context.baseFontSize, color: context.colorScheme.onPrimaryContainer)),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colorScheme.primaryContainer,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        const SizedBox(height: 24),

        ElevatedButton.icon(
          onPressed: isProcessing ? null : onGalleryPressed,
          icon: Icon(Icons.image, color: context.colorScheme.onPrimaryContainer),
          label: Text('Galerie', style: TextStyle(fontSize: context.baseFontSize, color: context.colorScheme.onPrimaryContainer)),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colorScheme.primaryContainer,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}