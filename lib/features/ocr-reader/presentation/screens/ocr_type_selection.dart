import 'package:flutter/material.dart';
import '../widgets/ocr_type_card.dart';
import 'printed_text_reader_screen.dart';
import 'handwritten_text_reader_screen.dart';

class OcrTypeSelectionScreen extends StatelessWidget {
  const OcrTypeSelectionScreen({super.key});
  static const route = '/ocr-reader';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecture de texte'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Quel type de texte souhaitez-vous analyser ?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            OcrTypeCard(
              title: 'Texte numérique',
              subtitle: 'Typographies simples',
              icon: Icons.keyboard,
              color: Colors.blue,
              badge: 'Hors-ligne',
              badgeColor: Colors.blue.shade700,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrintedTextReaderScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            OcrTypeCard(
              title: 'Texte manuscrit',
              subtitle: 'Notes écrites à la main',
              icon: Icons.edit,
              color: Colors.purple,
              badge: 'Nécessite Internet',
              badgeColor: Colors.purple.shade700,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HandwrittenTextReaderScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}