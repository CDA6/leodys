import 'package:flutter/material.dart';

class LetterSpacingCard extends StatelessWidget {
  final double letterSpacing;
  final double minLetterSpacing;
  final double maxLetterSpacing;
  final ValueChanged<double> onLetterSpacingChanged;

  const LetterSpacingCard({
    super.key,
    required this.letterSpacing,
    required this.minLetterSpacing,
    required this.maxLetterSpacing,
    required this.onLetterSpacingChanged
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Espacement des lettres',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${letterSpacing.toStringAsFixed(1)} px',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Recommandé pour la dyslexie',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Slider(
              value: letterSpacing,
              min: minLetterSpacing,
              max: maxLetterSpacing,
              divisions: 10,
              label: letterSpacing.toStringAsFixed(1),
              onChanged: (value) {
                onLetterSpacingChanged(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}