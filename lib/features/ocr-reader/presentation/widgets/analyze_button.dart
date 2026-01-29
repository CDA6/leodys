import 'package:flutter/material.dart';
import 'package:leodys/common/theme/theme_context_extension.dart';

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
            ? SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: context.colorScheme.onPrimaryContainer,
          ),
        )
            : const Icon(Icons.play_arrow),
        label: Text('Analyser le texte'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: context.colorScheme.primaryContainer,
          foregroundColor: context.colorScheme.onPrimaryContainer,
          disabledBackgroundColor:  Colors.grey.withValues(alpha: 0.1),
          disabledForegroundColor:  Colors.grey.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}