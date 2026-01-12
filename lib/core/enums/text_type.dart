enum TextType {
  printed('Imprimé', 'Hors-ligne'),
  handwritten('Manuscrit', 'Nécessite Internet');

  final String label;
  final String subtitle;

  const TextType(this.label, this.subtitle);
}