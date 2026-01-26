import 'package:flutter/material.dart';
import '../models/calculator_helpers.dart';
import 'calculator_widgets.dart';

/// Widget d'affichage de la calculatrice
/// Contient l'affichage des chiffres, le texte en français et les points
class CalculatorDisplay extends StatelessWidget {
  final String display;

  const CalculatorDisplay({
    Key? key,
    required this.display,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Génère une description vocale du display pour les lecteurs d'écran
    String displayDescription = _getDisplayDescription(display);

    // Widget de superposition
    return Stack(
      children: [
        // Semantics pour l'ensemble de l'affichage
        Semantics(
          label: 'Affichage de la calculatrice',
          value: displayDescription,
          hint: 'Appuyer pour activer la synthèse vocale',
          button: true,
          enabled: true,
          child: GestureDetector( // Detect l'appuie sur l'écran pour TTS
            onTap: () {
              //todo tts
            },
            child: Container(
              width: double.infinity,
              height: 200,
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                // Affichage en colonnes
                FittedBox(
                  /// Permet de réduire l'affichage automatiquement si trop grand
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: _buildDigitColumns(display),
                  ),
                ),

                const SizedBox(height: 6),

                // Ligne en toutes lettres avec coloration
                Align(
                  alignment: Alignment.centerRight,
                  child: RichText(
                    textAlign: TextAlign.right,
                    text: TextSpan(
                      style: const TextStyle(fontSize: 18),
                      children: CalculatorHelpers.numberToWordsSegments(display)
                          .map((segment) => TextSpan(
                                text: segment.text,
                                style: TextStyle(color: segment.color),
                              ))
                          .toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // Ligne de points (quantité)
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 4,
                    runSpacing: 4,
                    children: _buildQuantityDots(display)
                        .map((dot) => FittedBox(
                              fit: BoxFit.contain,
                              child: Text(
                                dot,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 18),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        ),

        // Icône TTS (haut à gauche)
        Positioned(
          top: 12,
          left: 12,
          child: ExcludeSemantics( // car on a deja un Semantics pour le display
            child: Icon(
              Icons.volume_up,
              color: Colors.white.withValues(alpha: 0.3), // blacn transparent
              size: 32,
            ),
          ),
        ),
      ],
    );
  }

  /// Génère une description vocale pour les lecteurs d'écran
  /// Utilise numberToWordsSegments() existante pour la conversion
  String _getDisplayDescription(String display) {
    if (display == 'Erreur') {
      return 'Erreur de calcul';
    }
    if (display.isEmpty) {
      return 'Affichage vide';
    }

    // Utilise la méthode existante qui convertit déjà tout en français
    final segments = CalculatorHelpers.numberToWordsSegments(display);

    // Concatène tous les segments de texte
    return segments.map((segment) => segment.text).join('').trim();
  }

  /// Construit les colonnes de chiffres avec espacement
  List<Widget> _buildDigitColumns(String display) {
    // Si on a une erreur
    if (display == 'Erreur') {
      return [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(border: Border.all(color: Colors.white24)),
          child: const Text(
            'Erreur',
            style: TextStyle(color: Colors.red, fontSize: 24),
          ),
        )
      ];
    }

    // Si l'affichage est vide
    if (display.isEmpty) return [];

    // Tokeniser en nombres et opérateurs
    final List<String> tokens = [];
    int i = 0;
    while (i < display.length) {
      final ch = display[i];
      if ((ch == '+' || ch == '×' || ch == '÷') ||
          (ch == '-' && i > 0 && RegExp(r'[0-9.]').hasMatch(display[i - 1]))) {
        tokens.add(ch);
        i++;
      } else {
        int start = i;
        if (display[i] == '-') i++;
        while (i < display.length && RegExp(r'[0-9.]').hasMatch(display[i])) {
          i++;
        }
        tokens.add(display.substring(start, i));
      }
    }

    // Parcours les tokens pour construire els objets a afficher
    final List<Widget> cols = [];
    for (int ti = 0; ti < tokens.length; ti++) {
      final tok = tokens[ti];
      // Si on a un opérateur
      if (tok.length == 1 && ['+', '-', '×', '÷'].contains(tok)) {
        cols.add(const SizedBox(width: 12));
        cols.add(OperatorBlock(
          operator: tok,
          blockWidth: CalculatorHelpers.blockWidth,
          blockHeight: CalculatorHelpers.blockHeight,
        ));
        cols.add(const SizedBox(width: 12));
        continue;
      }
      cols.addAll(_buildColumnsForNumber(tok));
    }

    return cols;
  }

  /// Construit les colonnes pour un nombre
  List<Widget> _buildColumnsForNumber(String s) {
    if (s.isEmpty) return [];

    bool negative = s.startsWith('-');
    if (negative) s = s.substring(1);

    List<String> parts = s.split('.');
    String intPart = parts[0];
    String decPart = parts.length > 1 ? parts[1] : '';

    if (intPart.isEmpty) intPart = '0';

    List<Widget> cols = [];
    int len = intPart.length;
    for (int i = 0; i < len; i++) {
      int posFromRight = len - 1 - i;
      String ch = intPart[i];
      cols.add(DigitColumn(
        character: ch,
        label: CalculatorHelpers.placeName(posFromRight),
        blockWidth: CalculatorHelpers.blockWidth,
        blockHeight: CalculatorHelpers.blockHeight,
      ));
      if (posFromRight % 3 == 0 && posFromRight != 0) { //calcul de la position de la colonne pour savoir si ecart tout les 3 colonnes
        cols.add(const SizedBox(width: 12));
      }
    }

    // Décimales
    if (decPart.isNotEmpty) {
      cols.add(const SizedBox(width: 12));
      cols.add(DigitColumn(
        character: ',',
        label: 'virgule',
        blockWidth: CalculatorHelpers.blockWidth,
        blockHeight: CalculatorHelpers.blockHeight,
      ));

      // Limite le nombre de décimales à 5
      if (decPart.length > CalculatorHelpers.maxDecimals) {
        decPart = decPart.substring(0, CalculatorHelpers.maxDecimals);
      }

      for (int i = 0; i < decPart.length; i++) {
        String ch = decPart[i];
        cols.add(DigitColumn(
          character: ch,
          label: CalculatorHelpers.decimalPlaceName(i + 1),
          blockWidth: CalculatorHelpers.blockWidth,
          blockHeight: CalculatorHelpers.blockHeight,
        ));
      }
    }

    if (negative) {
      cols.insert(
          0,
          DigitColumn(
            character: '-',
            label: 'signe',
            blockWidth: CalculatorHelpers.blockWidth,
            blockHeight: CalculatorHelpers.blockHeight,
          ));
    }

    return cols;
  }

  /// Construit les points représentant la quantité
  ///  🧊 vaut 1000
  /// 🔲 vaut 100
  /// ❚ vaut 10
  /// ● vaut 1
  List<String> _buildQuantityDots(String display) {
    if (display == 'Erreur') return [];

    double? val = double.tryParse(display.replaceAll(',', '.'));
    int qty = 0;
    if (val != null) {
      qty = val.abs().floor();
    }

    int thousands = qty ~/ 1000; // on récupère le nombre de milliers
    int hundreds = (qty % 1000) ~/ 100; // on récupère le nombre de centaines
    int tens = (qty % 100) ~/ 10; // on récupère le nombre de dizaines
    int units = qty % 10; // on récupère le nombre d'unités

    List<String> dots = [];

    if (qty >= 1000000) { // limite pour l'affichage (pour éviter bug)
      dots.add('⚠️ : Nombre trop grand'); // Avertissement si la quantité est trop grande
    } else {
      if (thousands > 10) {
        dots.add('$thousands🧊');
      } else {
        for (int i = 0; i < thousands; i++) {
          dots.add('🧊');
        }
      }
      dots.add(' ');
      for (int i = 0; i < hundreds; i++) {
        dots.add('🔲');
        if (i%4==0 && i>0) {
          dots.add(' '); // espace tous les 5 blocs
        }
      }
      dots.add(' ');
      for (int i = 0; i < tens; i++) {
        dots.add('❚');
        if (i%4==0 && i>0) {
          dots.add(' '); // espace tous les 5 blocs
        }
      }
      dots.add(' ');
      for (int i = 0; i < units; i++) {
        dots.add('●');
        if (i%4==0 && i>0) {
          dots.add(' '); // espace tous les 5 blocs
        }
      }
    }

    return dots;
  }
}