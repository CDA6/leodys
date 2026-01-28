import 'dart:io';
import 'package:flutter/material.dart';
import 'package:leodys/common/theme/theme_context_extension.dart';
import 'package:leodys/features/ocr-reader/domain/entities/ocr_result.dart';

class OcrResultScreen extends StatelessWidget {
  final File image;
  final OcrResult ocrResult;

  const OcrResultScreen({
    super.key,
    required this.image,
    required this.ocrResult,
  });

  static const route = '/ocr-result';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat de l\'analyse'),
      ),
      body: Column(
        children: [
          // Image
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Image.file(
              image,
              fit: BoxFit.contain,
            ),
          ),

          // Texte
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colorScheme.outline),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  ocrResult.text,
                  style: TextStyle(
                    fontSize: context.baseFontSize,
                    height: context.lineHeight,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),

          // Boutons d'action en bas
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implémenter ttf
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Center(child: Text('Fonctionnalité à venir...')),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Lire le texte'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                      backgroundColor: context.colorScheme.primaryContainer,
                      foregroundColor: context.colorScheme.onPrimaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Bouton retour
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Nouvelle analyse'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                      backgroundColor: context.colorScheme.surfaceContainerHighest,
                      foregroundColor: context.colorScheme.onSurfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: context.colorScheme.outline,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 72),

              ],
            ),
          ),
        ],
      ),
    );
  }
}