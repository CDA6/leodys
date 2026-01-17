class OcrResult {
  final String text;
  final bool isEmpty;

  const OcrResult({
    required this.text,
    required this.isEmpty,
  });

  factory OcrResult.empty() {
    return const OcrResult(
      text: 'Aucun texte détecté',
      isEmpty: true,
    );
  }

  factory OcrResult.withText(String text) {
    return OcrResult(
      text: text,
      isEmpty: text.trim().isEmpty,
    );
  }
}