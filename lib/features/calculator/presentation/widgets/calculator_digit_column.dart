import 'package:flutter/material.dart';

/// Widget pour afficher un chiffre avec son étiquette
class DigitColumn extends StatelessWidget {
  final String character;
  final String label;
  final double blockWidth;
  final double blockHeight;

  const DigitColumn({
    super.key,
    required this.character,
    required this.label,
    required this.blockWidth,
    required this.blockHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: blockWidth,
      height: blockHeight,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(6), // angles arrondis
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown, //reduit automatiquement si besoin
            child: Text(
              character,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36, //taille du texte dans les blocs
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox( // texte de l'étiquette
            width: blockWidth - 2,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}