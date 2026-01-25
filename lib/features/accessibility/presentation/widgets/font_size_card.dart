import 'package:flutter/material.dart';

import '../../../../common/theme/theme_context.dart';

class FontSizeCard extends StatelessWidget {
  final double fontSize;
  final double minFontSize;
  final double maxFontSize;
  final ValueChanged<double> onFontSizeChanged;

  const FontSizeCard({
    super.key,
    required this.fontSize,
    required this.minFontSize,
    required this.maxFontSize,
    required this.onFontSizeChanged
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Taille',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: context.colorScheme.primary,
                  ),
                ),
                Text(
                  '${fontSize.toInt()} px',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    inactiveColor: context.colorScheme.primary.withValues(alpha: 0.1),
                    value: fontSize,
                    min: minFontSize,
                    max: maxFontSize,
                    divisions: (maxFontSize - minFontSize).toInt(),
                    label: '${fontSize.toInt()}',
                    onChanged: (value) {
                      onFontSizeChanged(value);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}