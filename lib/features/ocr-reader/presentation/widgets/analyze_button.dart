import 'package:flutter/material.dart';

class AnalyzeButton extends StatelessWidget{
  final bool canAnalyze;
  final bool isProcessing;
  final VoidCallback? onPressed;
  final String processingText;

  const AnalyzeButton({
    super.key,
    required this.canAnalyze,
    required this.isProcessing,
    required this.onPressed,
    required this.processingText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canAnalyze ? onPressed : null,
        icon: isProcessing
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Icon(Icons.play_arrow),
        label: Text(
          !canAnalyze && !isProcessing
              ? 'Veuillez sélectionner une image'
              : isProcessing ? processingText : 'Analyser le texte',
        ),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}