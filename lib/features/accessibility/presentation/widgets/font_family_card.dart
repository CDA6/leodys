import 'package:flutter/material.dart';
import 'package:leodys/common/theme/theme_context_extension.dart';

class FontFamilyCard extends StatelessWidget {
  final String currentFontFamily;
  final List<String> availableFonts;
  final ValueChanged<String?> onFontSelected;

  const FontFamilyCard({
    super.key,
    required this.currentFontFamily,
    required this.availableFonts,
    required this.onFontSelected,
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
            Text(
              'Police de caractères',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: context.colorScheme.primary
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: currentFontFamily,
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: availableFonts
                  .map((font) => DropdownMenuItem(
                value: font,
                child: Text(
                  font,
                  style: TextStyle(color: context.colorScheme.secondary),
                ),
              ))
                  .toList(),
              onChanged: onFontSelected,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}