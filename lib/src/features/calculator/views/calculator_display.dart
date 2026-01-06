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
          // Historique
          if (history.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: history
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          e,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ))
                  .toList(),
            ),

          // Affichage en colonnes
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
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
              style: const TextStyle(color: Colors.white70, fontSize: 16),
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
              children: _buildQuantityDots(display),
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
            style: TextStyle(color: Colors.red, fontSize: 28),
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

    final List<Widget> cols = [];
    for (int ti = 0; ti < tokens.length; ti++) {
      final tok = tokens[ti];
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
      if (posFromRight % 3 == 0 && posFromRight != 0) {
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
  List<Widget> _buildQuantityDots(String display) {
    if (display == 'Erreur') return [const Text('')];

    double? val = double.tryParse(display.replaceAll(',', '.'));
    int qty = 0;
    if (val != null) {
      qty = val.abs().floor();
    }

    int shown = qty.clamp(0, 20);
    List<Widget> dots = [];
    for (int i = 0; i < shown; i++) {
      dots.add(const Icon(Icons.circle, size: 8, color: Colors.white));
    }
    if (qty > 20) {
      dots.add(Text(
        ' +${qty - 20}',
        style: const TextStyle(color: Colors.white70),
      ));
    }
    return dots;
  }
}