import 'package:flutter/material.dart';
import 'package:leodys/common/theme/theme_context.dart';

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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: context.colorScheme.outline,
          width: 1,
        ),
      ),
      color: context.colorScheme.onSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Text(
                        'Espacement des lettres',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: context.colorScheme.primary,
                        ),
                      ),
                      Text(
                        '${letterSpacing.toStringAsFixed(1)} px',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: context.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Slider(
              inactiveColor: context.colorScheme.secondary,
              value: letterSpacing,
              min: minLetterSpacing,
              max: maxLetterSpacing,
              divisions: ((maxLetterSpacing - minLetterSpacing) * 10).toInt(),
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