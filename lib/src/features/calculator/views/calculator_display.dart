import 'package:flutter/material.dart';
import '../models/calculator_helpers.dart';
import 'calculator_widgets.dart';

/// Widget d'affichage de la calculatrice
/// Contient l'historique, l'affichage des chiffres, le texte en français et les points
class CalculatorDisplay extends StatelessWidget {
  final String display;
  final List<String> history;

  const CalculatorDisplay({
    Key? key,
    required this.display,
    required this.history,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Historique todo deplacer vers le bouton historique
          // if (history.isNotEmpty)
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.end,
            //   children: history
            //       .map((e) => Text(
            //               e,
            //               style: const TextStyle(
            //                 color: Colors.white54,
            //                 fontSize: 18,
            //               ),
            //             ),
            //           )
            //       .toList(),
            // ),

          // Affichage en colonnes
          FittedBox( /// Permet de réduire l'affichage automatiquement si trop grand
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildDigitColumns(display),
            ),
          ),

          const SizedBox(height: 8),

          // Ligne en toutes lettres
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              CalculatorHelpers.numberToWordsFromDisplay(display),
              style: const TextStyle(color: Colors.white70, fontSize: 20),
              textAlign: TextAlign.right,
            ),
          ),

          const SizedBox(height: 8),

          // Ligne de points (quantité)
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 4,
              runSpacing: 4,
              children: _buildQuantityDots(display)
                  .map((dot) => FittedBox(
                          fit: BoxFit.contain, // .scaleDown,
                          child: Text(
                          dot,
                          style: const TextStyle(color: Colors.white70, fontSize: 20),
                          ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit les colonnes de chiffres avec espacement
  List<Widget> _buildDigitColumns(String display) {
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
      ));
      if (posFromRight % 3 == 0 && posFromRight != 0) { ///calcul de la position de la colonne pour savoir si ecart tout les 3 colonnes
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
      ));
      for (int i = 0; i < decPart.length; i++) {
        String ch = decPart[i];
        cols.add(DigitColumn(
          character: ch,
          label: CalculatorHelpers.decimalPlaceName(i + 1),
          blockWidth: CalculatorHelpers.blockWidth,
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

    int thousands = qty ~/ 1000; /// on récupère le nombre de milliers
    int hundreds = (qty % 1000) ~/ 100; /// on récupère le nombre de centaines
    int tens = (qty % 100) ~/ 10; /// on récupère le nombre de dizaines
    int units = qty % 10; /// on récupère le nombre d'unités

    List<String> dots = [];

    if (qty >= 1000000) { /// limite pour l'affichage (pour éviter bug)
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
      }
      dots.add(' ');
      for (int i = 0; i < tens; i++) {
        dots.add('❚');
      }
      dots.add(' ');
      for (int i = 0; i < units; i++) {
        dots.add('●');
      }
    }

    return dots;
  }
}