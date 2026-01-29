import 'package:flutter/material.dart';

class TextToSpeechCard extends StatelessWidget {
  final bool textToSpeechEnabled;
  final ValueChanged<bool> toggleTextToSpeech;

  const TextToSpeechCard({
    super.key,
    required this.textToSpeechEnabled,
    required this.toggleTextToSpeech
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        title: const Text(
          'Activer la synthèse vocale',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text(
          'Lit le contenu à voix haute (maintenir appuyé sur le texte)',
        ),
        value: textToSpeechEnabled,
        onChanged: (value) {
          toggleTextToSpeech(value);
        },
      ),
    );
  }
}