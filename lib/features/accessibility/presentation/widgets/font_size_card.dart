import 'package:flutter/material.dart';

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Taille',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${fontSize.toInt()} pt',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.text_fields, size: 16),
                Expanded(
                  child: Slider(
                    value: fontSize,
                    min: minFontSize,
                    max: maxFontSize,
                    divisions: 16,
                    label: '${fontSize.toInt()}',
                    onChanged: (value) {
                      onFontSizeChanged(value);
                    },
                  ),
                ),
                const Icon(Icons.text_fields, size: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }

}