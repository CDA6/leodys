import 'package:flutter/material.dart';

import 'package:leodys/common/theme/theme_context_extension.dart';

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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: context.colorScheme.outline,
          width: 1,
        ),
      ),
      color: context.colorScheme.surfaceContainerHighest,
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
                        'Hauteur de ligne',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: context.colorScheme.primary
                        ),
                      ),
                      Text(
                        '${lineHeight.toStringAsFixed(1)} px',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Slider(
              inactiveColor: context.colorScheme.primary.withValues(alpha: 0.1),
              value: lineHeight,
              min: minLineHeight,
              max: maxLineHeight,
              divisions: ((maxLineHeight - minLineHeight) * 10).toInt(),
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