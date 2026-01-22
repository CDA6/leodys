import 'package:flutter/material.dart';

class LineHeightCard extends StatelessWidget {
  final double lineHeight;
  final double minLineHeight;
  final double maxLineHeight;
  final ValueChanged<double> onUpdateLineHeight;

  const LineHeightCard({
    super.key,
    required this.lineHeight,
    required this.minLineHeight,
    required this.maxLineHeight,
    required this.onUpdateLineHeight
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
                  'Hauteur de ligne',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${lineHeight.toStringAsFixed(1)}x',
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
              'Améliore la lisibilité',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Slider(
              value: lineHeight,
              min: minLineHeight,
              max: maxLineHeight,
              divisions: 15,
              label: lineHeight.toStringAsFixed(1),
              onChanged: (value) {
                onUpdateLineHeight(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}