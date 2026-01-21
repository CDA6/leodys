import 'package:flutter/material.dart';
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Police de caractères',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: currentFontFamily,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
                  style: TextStyle(fontFamily: font),
                ),
              ))
                  .toList(),
              onChanged: onFontSelected,
            ),
            const SizedBox(height: 8),
            Text(
              '💡 OpenDyslexic et Lexend sont recommandées pour la dyslexie',
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}